package Mojo::SAML::Document::KeyInfo;

use Mojo::Base 'Mojo::SAML::Document';

use Mojo::Template;

my $isa = sub {
  my ($obj, $class) = @_;
  Scalar::Util::blessed($obj) && $obj->isa($class);
};

has template => sub { shift->build_template(<<'XML') };
<KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
  % if (my $name = $self->name) {
  <KeyName><%= $name %></KeyName>
  % }
  <X509Data>
    <X509Certificate><%= $self->x509_string // '' %></X509Certificate>
  </X509Data>
</KeyInfo>
XML

has 'cert';
has 'name';

sub x509_string {
  my $self = shift;
  return undef unless my $cert = $self->cert;

  my $text = $cert->$isa('Crypt::OpenSSL::X509') ? $cert->as_string : undef;

  Carp::croak 'Unknown cert object type'
    unless defined $text;

  $text =~ s/-----[^-]*-----//gm;
  $text =~ s/[\r\n]//g;
  return Mojo::Util::trim($text);
}

1;

