package Mojo::SAML::Document::AuthnRequest;

use Mojo::Base 'Mojo::SAML::Document';

use Mojo::SAML::Names;

has template => sub { shift->build_template(<<'XML') };
%= tag 'samlp:AuthnRequest' => $self->tag_attrs => begin
  % if (defined(my $issuer = $self->issuer)) {
  <saml:Issuer><%= $issuer %></saml:Issuer>
  % }
  % if (my $policy = $self->nameid_policy) {
  <%= $policy %>
  % }
  <samlp:RequestedAuthnContext Comparison="exact">
    <saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport</saml:AuthnContextClassRef>
  </samlp:RequestedAuthnContext>
% end
XML

has id => sub { 'MOJOSAML_' . shift->get_guid };
has issue_instant => sub { shift->get_instant };
has [qw/
  assertion_consumer_service_index assertion_consumer_service_url
  protocol_binding provider_name destination
  is_passive force_authn issuer nameid_policy
/];

sub before_render {
  my $self = shift;
  my $idx = defined $self->assertion_consumer_service_index;
  my $url = defined $self->assertion_consumer_service_url;
  if ($idx && $url) {
    Carp::croak 'Cannot specify both index and url for AssertionConsumerService';
  } elsif (!($idx || $url)) {
    $self->assertion_consumer_service_index(0);
  }
}

sub tag_attrs {
  my $self = shift;
  my @attrs = (
    'xmlns:samlp' => 'urn:oasis:names:tc:SAML:2.0:protocol',
    'xmlns:saml'  => 'urn:oasis:names:tc:SAML:2.0:assertion',
    Version => '2.0',
    ID => $self->id,
    IssueInstant => $self->issue_instant,
  );

  if (defined(my $idx = $self->assertion_consumer_service_index)) {
    push @attrs, AssertionConsumerServiceIndex => $idx;
  }
  if (defined(my $url = $self->assertion_consumer_service_url)) {
    push @attrs, AssertionConsumerServiceURL => $url;
  }
  if (defined(my $binding = $self->protocol_binding)) {
    push @attrs, ProtocolBinding => Mojo::SAML::Names::binding($binding);
  }
  if (defined(my $dest = $self->destination)) {
    push @attrs, Destination => $dest;
  }

  if (defined(my $force = $self->force_authn)) {
    push @attrs, ForceAuthn => $force ? 'true' : 'false';
  }
  if (defined(my $passive = $self->is_passive)) {
    push @attrs, IsPassive => $passive ? 'true' : 'false';
  }

  return @attrs;
}

1;

