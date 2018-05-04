package Mojo::SAML::Document::AssertionConsumerService;

use Mojo::Base 'Mojo::SAML::Document';

use Mojo::SAML::Names;

has template => sub { shift->build_template(<<'XML') };
%= tag AssertionConsumerService => $self->tag_attrs
XML

has index => sub { Carp::croak 'index is required' };
has [qw/response_location is_default/];
has binding => sub { Carp::croak 'binding is required' };
has location => sub { Carp::croak 'location is required' };

sub tag_attrs {
  my $self = shift;
  my $binding = $self->binding;
  my @attrs = (
    xmlns => 'urn:oasis:names:tc:SAML:2.0:metadata',
    index => $self->index,
    Location => $self->location,
    Binding => Mojo::SAML::Names::binding($binding),
  );

  if (defined(my $res = $self->response_location)) {
    push @attrs, ResponseLocation => $res;
  }

  if (defined(my $default = $self->is_default)) {
    push @attrs, isDefault => $default ? 'true' : 'false';
  }

  return @attrs;
}

1;

