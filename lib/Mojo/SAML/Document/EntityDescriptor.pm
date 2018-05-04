package Mojo::SAML::Document::EntityDescriptor;

use Mojo::Base 'Mojo::SAML::Document';

use Mojo::XMLSig;
use Mojo::SAML::Document::Signature;

use Crypt::OpenSSL::Random;

has template => sub { shift->build_template(<<'XML') };
%= tag EntityDescriptor => $self->tag_attrs, begin
  % if ($self->key) {
    %= Mojo::SAML::Document::Signature->new(references => [$self->id], key_info => $self->key_info)
  % }
  % for my $desc (@{ $self->descriptors }) {
  <%= $desc %>
  % }
% end
XML

has entity_id => sub { Carp::croak 'entity_id is required' };
has [qw/key key_info id valid_until cache_duration/];
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
  if ($self->key && !$self->id) {
    my $id = unpack 'H*', Crypt::OpenSSL::Random::random_pseudo_bytes(16);
    $self->id($id);
  }
}

sub after_render {
  my ($self, $xml) = @_;
  return Mojo::XMLSig::sign("$xml", $self->key);
}


1;

