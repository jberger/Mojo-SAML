package Mojo::SAML::Document;

use Mojo::Base -base;

use Carp ();
use Data::GUID ();
use Mojolicious;
use Mojo::ByteStream;
use Mojo::Date;
use Mojo::Template;

use overload bool => sub {1}, '""' => sub { $_[0]->to_string }, fallback => 1;

has template => sub { die 'template is required' };

sub before_render { }
sub after_render  { $_[1] }

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
  my $output = Mojo::ByteStream->new($self->template->process($self));
  $self->after_render($output);
}

1;


