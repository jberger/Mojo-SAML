package Mojo::XMLSig;

use Mojo::Base -strict;

use Carp ();
use Digest::SHA;
use Mojo::DOM;
use Mojo::Util;
use XML::CanonicalizeXML;

my $isa = sub {
  my ($obj, $class) = @_;
  Scalar::Util::blessed($obj) && $obj->isa($class);
};
my %ns = (ds => 'http://www.w3.org/2000/09/xmldsig#');

my %actions = (
  # xml
  'http://www.w3.org/2000/09/xmldsig#enveloped-signature' => \&_enveloped_signature,

  # canonical
  'http://www.w3.org/TR/2001/REC-xml-c14n-20010315' => _mk_canon(0,0),
  'http://www.w3.org/TR/2001/REC-xml-c14n-20010315#WithComments' => _mk_canon(0,1),
  'http://www.w3.org/2006/12/xml-c14n11' => _mk_canon(2,0),
  'http://www.w3.org/2006/12/xml-c14n11#WithComments' => _mk_canon(2,1),
  'http://www.w3.org/2001/10/xml-exc-c14n#' => _mk_canon(1,0),
  'http://www.w3.org/2001/10/xml-exc-c14n#WithComments' => _mk_canon(1,1),

  # encoding
  'http://www.w3.org/2000/09/xmldsig#base64' => sub { Mojo::Util::b64_encode(shift, '') },

  # digest
  'http://www.w3.org/2000/09/xmldsig#sha1'  => sub { _get_digest(sha1 => @_) },
  'http://www.w3.org/2001/04/xmlenc#sha256' => sub { _get_digest(sha256 => @_) },
  'http://www.w3.org/2001/04/xmldsig-more#sha224' => sub { _get_digest(sha224 => @_) },
  'http://www.w3.org/2001/04/xmldsig-more#sha384' => sub { _get_digest(sha384 => @_) },
  'http://www.w3.org/2001/04/xmlenc#sha512' => sub { _get_digest(sha512 => @_) },

  # sign
  'http://www.w3.org/2000/09/xmldsig#rsa-sha1' => sub { _rsa(sha1 => @_) },
  'http://www.w3.org/2001/04/xmldsig-more#rsa-sha224' => sub { _rsa(sha224 => @_) },
  'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256' => sub { _rsa(sha256 => @_) },
  'http://www.w3.org/2001/04/xmldsig-more#rsa-sha384' => sub { _rsa(sha384 => @_) },
  'http://www.w3.org/2001/04/xmldsig-more#rsa-sha512' => sub { _rsa(sha512 => @_) },
);

sub clean_cert {
  my $cert = shift;
  $cert =~ s/\n//g;
  $cert = Mojo::Util::trim $cert;
  $cert = Mojo::Util::b64_encode(Mojo::Util::b64_decode($cert), "\n");
  $cert = Mojo::Util::trim $cert;
  $cert = "-----BEGIN CERTIFICATE-----\n$cert\n-----END CERTIFICATE-----\n";
  return $cert;
}

sub digest { _digest(0, @_) }

sub has_signature {
  my $dom = shift;
  $dom = _dom($dom)
    unless $dom->isa('Mojo::DOM');
  return !!$dom->at('ds|Signature ds|SignatureValue:not(:empty)', %ns);
}

sub sign {
  my ($xml, $key) = @_;
  _signature(0, _digest(0, $xml), $key);
}

sub verify {
  my $dom = shift;
  my $ret = eval { _digest(1, $dom); 1 };
  warn "$@" if $@;
  return 0 unless $ret;
  $ret = eval { _signature(1, $dom); 1 };
  warn "$@" if $@;
  return $ret ? 1 : 0;
}

my $set_algo = sub {
  my ($key, $algo) = @_;
  Carp::croak 'Key must be an instance of Crypt::OpenSSL::RSA'
    unless $key->$isa('Crypt::OpenSSL::RSA');
  Carp::croak 'Unsupported RSA algorithm'
    unless my $method = $key->can("use_${algo}_hash");
  $key->$method;
  return $key;
};

sub _digest {
  my ($verify, $dom) = @_;
  $dom = _dom($dom)
    unless $dom->isa('Mojo::DOM');
  Carp::croak 'No Signature section found'
    unless my $sig = $dom->at('ds|Signature', %ns);

  my $refs = $sig->find('ds|Reference', %ns);
  Carp::croak 'Nothing to verify'
    unless $refs->size;

  $refs->each(sub{
    my $ref = shift;
    my $uri = $ref->{URI};
    Carp::croak "Cannot process references other than ID. Got: $uri"
      unless $uri =~ s/^#//;

    my $clone = _dom($dom);
    Carp::croak "Cannot find element ID=$uri"
      unless my $elem = $clone->at(qq![ID="$uri"]!);

    $ref->find('ds|Transforms > ds|Transform', %ns)->each(sub{
      my $trans = shift->{Algorithm};
      $elem = _do_action($trans, $elem);
      Carp::croak "Transform $trans resulted in no value"
        unless defined $elem && length "$elem";
    });

    Carp::croak 'No DigestMethod was defined'
      unless my $algo = $ref->at('ds|DigestMethod', %ns);
    my $digest = _do_action($algo->{Algorithm}, "$elem");

    my $value = $ref->at('ds|DigestValue', %ns);

    if ($value) {
      if ($value->matches(':empty') && !$verify) {
        $value->content($digest);
      } else {
        $value = Mojo::Util::trim($value->text);
        Carp::croak "Existing digest '$value' does not equal calculated value '$digest'"
          unless $value eq $digest;
      }
    } else {
      # Originally this method could create the tag, but I want to enforce that
      # the structure come from the document itself

      Carp::croak "No DigestValue exists"; # if $verify;
      #my $tag = $ref->tag;
      #$tag =~ s/Reference/DigestValue/; # preserve prefix
      #$ref->append_content("<$tag>$digest</$tag>");
    }
  });

  return $dom;
}

sub _do_action {
  my $action = shift;
  Carp::croak "Action $action not understood"
    unless my $code = $actions{$action};
  return $code->(@_);
}

sub _dom { Mojo::DOM->new->xml(1)->parse("$_[0]") }

sub _get_digest {
  my ($algo, $content) = @_;
  my $digest = Digest::SHA->can("${algo}_base64")->($content);
  while (length($digest) % 4) { $digest .= '=' }
  return $digest;
}

sub _enveloped_signature {
  my $dom = shift;
  my $sig = $dom->at('ds|Signature', %ns);
  $sig ? $sig->remove : warn 'No Signature was removed';
  return $dom;
}

sub _mk_canon {
  my ($ex, $comment) = @_;
  return sub { XML::CanonicalizeXML::canonicalize("$_[0]", '<XPath>(//. | //@* | //namespace::*)</XPath>', '', $ex, $comment) };
}

sub _rsa {
  my ($algo, $verify, $text, $dom, $key) = @_;
  return $verify ? _verify_rsa($algo, $text, $dom, $key) : _sign_rsa($algo, $text, $dom, $key);
}

sub _sign_rsa {
  my ($algo, $text, $dom, $key) = @_;
  $key->$set_algo($algo);

  Carp::croak 'No X509Certificate element found for cert storage'
    unless my $elem = $dom->at('ds|KeyInfo > ds|X509Data > ds|X509Certificate', %ns);
  return Mojo::Util::b64_encode($key->sign(Mojo::Util::trim $text), '');
}

sub _signature {
  my ($verify, $dom, $key) = @_;
  $dom = _dom($dom)
    unless $dom->$isa('Mojo::DOM');
  Carp::croak 'No Signature section found'
    unless my $elem = $dom->at('ds|Signature', %ns);

  Carp::croak 'Nothing to verify'
    unless $elem->find('ds|Reference > ds|DigestValue:not(:empty)', %ns)->size;

  Carp::croak 'No CanonicalizationMethod is specified'
    unless my $c_method = $elem->at('ds|CanonicalizationMethod[Algorithm]', %ns)->{Algorithm};
  Carp::croak 'No SignatureMethod is specified'
    unless my $s_method = $elem->at('ds|SignatureMethod[Algorithm]', %ns)->{Algorithm};

  my $siginfo = $elem->at('ds|SignedInfo', %ns);

  # inject namespace if necessary
  if ($siginfo->tag =~ /^([^:]+):/) {
    my $prefix = $1;
    my $ns = $siginfo->namespace;
    $siginfo = _dom($siginfo);
    $siginfo->at(':root')->attr("xmlns:$prefix" => $ns);
  }

  my $canon = _do_action($c_method, $siginfo);
  my $value = _do_action($s_method, $verify, $canon, $elem, $key);

  unless ($verify) {
    Carp::croak 'No SignatureValue present'
      unless my $sig = $dom->at('ds|SignatureValue', %ns);
    $sig->content($value);
  }

  return $dom;
}

sub _verify_rsa {
  my ($algo, $text, $dom, $key) = @_;
  unless ($key) {
    Carp::croak 'No X509Certificate element found for cert storage'
      unless my $elem = $dom->at('ds|KeyInfo > ds|X509Data > ds|X509Certificate:not(:empty)', %ns);
    my $cert = clean_cert($elem->text);

    require Crypt::OpenSSL::X509;
    require Crypt::OpenSSL::RSA;
    $cert = Crypt::OpenSSL::X509->new_from_string($cert);
    $key  = Crypt::OpenSSL::RSA->new_public_key($cert->pubkey);
  }

  $key->$set_algo($algo);
  Carp::croak 'No SignatureValue present'
    unless my $sig = $dom->at('ds|SignatureValue:not(:empty)', %ns);
  $sig = Mojo::Util::b64_decode($sig->text);

  Carp::croak 'Signature does not verify'
    unless $key->verify($text, $sig);

  return $sig;
}

1;


