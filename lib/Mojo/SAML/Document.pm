package Mojo::SAML::Document;

use Mojo::Base -base;

use Carp ();
use Mojolicious;
use Mojo::ByteStream;
use Mojo::Template;

use overload bool => sub {1}, '""' => sub { $_[0]->to_string }, fallback => 1;

has template => sub { die 'template is required' };

sub before_render { }
sub after_render  { $_[1] }

{
  my $mojo = Mojolicious->new;
  package Mojo::SAML::TemplateSandbox;
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

sub to_string {
  my $self = shift;
  $self->before_render;
  my $output = Mojo::ByteStream->new($self->template->process($self));
  $self->after_render($output);
}

1;


