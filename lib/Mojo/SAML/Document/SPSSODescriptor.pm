package Mojo::SAML::Document::SPSSODescriptor;

use Mojo::Base 'Mojo::SAML::Document';

has template => sub { shift->build_template(<<'XML') };
<%
  my @attrs = (
    xmlns => 'urn:oasis:names:tc:SAML:2.0:metadata',
    protocolSupportEnumeration => 'urn:oasis:names:tc:SAML:2.0:protocol',
    AuthnRequestsSigned  => $self->authn_requests_signed  ? 'true' : 'false',
    WantAssertionsSigned => $self->want_assertions_signed ? 'true' : 'false',
  );
%>
%= tag SPSSODescriptor => @attrs => begin
  % for my $desc (@{ $self->key_descriptors }) {
  <%= $desc %>
  % }
  % for my $format (@{ $self->nameid_format }) {
  <NameIDFormat><%= nameid_format($format) %></NameIDFormat>
  % }
  % for my $service (@{ $self->assertion_consumer_services }) {
  <%= $service %>
  % }
% end
XML

has [qw/authn_requests_signed want_assertions_signed/] => 0;
has [qw/key_descriptors assertion_consumer_services nameid_format/] => sub { [] };

sub before_render {
  my $self = shift;
  for my $method (qw/assertion_consumer_services/) {
    Carp::croak "$method cannot be empty" unless @{$self->$method};
  }
}

1;

