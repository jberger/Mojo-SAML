package Mojo::SAML::Document::EntityDescriptor;

use Mojo::Base 'Mojo::SAML::Document';

use Mojo::XMLSig;
use Mojo::SAML::Document::Signature;

has template => sub { shift->build_template(<<'XML') };
%= tag EntityDescriptor => $self->tag_attrs, begin
  % for my $desc (@{ $self->descriptors }) {
  <%= $desc %>
  % }
% end
XML

has entity_id => sub { Carp::croak 'entity_id is required' };
has [qw/id valid_until cache_duration/];
has descriptors => sub { [] };

sub tag_attrs {
  my $self = shift;
  my @attrs = (
    xmlns => 'urn:oasis:names:tc:SAML:2.0:metadata',
    entityID => $self->entity_id,
  );
  if (defined(my $id = $self->id)) {
    push @attrs, ID => $id;
  }
  if (defined(my $valid = $self->valid_until)) {
    push @attrs, validUntil => $valid;
  }
  if (defined(my $cache = $self->cache_duration)) {
    push @attrs, cacheDuration => $cache;
  }

  return @attrs;
}

sub before_render {
  my $self = shift;
  for my $method (qw/descriptors/) {
    Carp::croak "$method cannot be empty" unless @{$self->$method};
  }
}

1;

