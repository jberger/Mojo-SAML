package Mojo::SAML::Document;

use Mojo::Base -base;

use Carp ();
use Data::GUID ();
use Mojolicious;
use Mojo::ByteStream;
use Mojo::Date;
use Mojo::Template;
use Mojo::XMLSig;

use overload bool => sub {1}, '""' => sub { $_[0]->to_string }, fallback => 1;

has [qw/sign_with_key insert_signature/];
has template => sub { die 'template is required' };

my $isa = sub {
  my ($obj, $class) = @_;
  Scalar::Util::blessed($obj) && $obj->isa($class);
};
sub _dom { Mojo::DOM->new->xml(1)->parse("$_[0]") }

sub before_render { }
sub after_render  {
  my ($self, $xml) = @_;
  if (my $sig = $self->insert_signature) {
    $xml = $self->after_render_insert_signature($xml, $sig);
  }
  if (my $key = $self->sign_with_key) {
    $xml = $self->after_render_sign($xml, $key);
  }
  return "$xml";
}

sub after_render_insert_signature {
  my ($self, $dom, $sig) = @_;
  Carp::croak 'Signature must be a Mojo::SAML::Document::Signature'
    unless $sig->$isa('Mojo::SAML::Document::Signature');

  $dom = _dom($dom) unless $dom->$isa('Mojo::DOM');
  my $root = $dom->at(':root');
  unless (@{ $sig->references }) {
    my $id = $root->{ID};
    unless ($id) {
      $id = $self->get_guid;
      $root->attr(ID => $id);
    }
    $sig->references([$id]);
  }
  $root->prepend_content("$sig");
  return $dom;
}

sub after_render_sign {
  my ($self, $xml, $key) = @_;
  return Mojo::XMLSig::sign("$xml", $key);
}


{
  my $mojo = Mojolicious->new;
  package Mojo::SAML::TemplateSandbox;
  use Mojo::SAML::Names qw/binding nameid_format/;
  sub tag { $mojo->tag(@_) }
}

sub build_template {
  my ($self, $text) = @_;
  Mojo::Template->new(
    autoescape => 1,
    namespace  => 'Mojo::SAML::TemplateSandbox',
    prepend    => 'my $self = shift',
  )->parse($text);
}

sub get_guid { Data::GUID->guid_string }
sub get_instant { Mojo::Date->new->to_datetime }

sub to_string_deflate {
  require Compress::Raw::Zlib;
  my $zlib = Compress::Raw::Zlib::Deflate->new;
  my $string = shift->to_string;
  my $compressed;
  Carp::croak 'Compress failed'
    unless $zlib->deflate($string, $compressed) == Compress::Raw::Zlib::Z_OK();
  Carp::croak 'Compress failed'
    unless $zlib->flush($compressed) == Compress::Raw::Zlib::Z_OK();

  return Mojo::Util::b64_encode($compressed, '');
}

sub to_string {
  my $self = shift;
  $self->before_render;
  my $output = $self->template->process($self);
  $output = $self->after_render($output);
  return Mojo::ByteStream->new($output);
}

1;


