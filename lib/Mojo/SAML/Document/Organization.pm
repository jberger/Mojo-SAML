package Mojo::SAML::Document::Organization;

use Mojo::Base 'Mojo::SAML::Document';

has [qw/display_names names urls/] => sub { [] };

has template => sub { shift->build_template(<<'XML') };
<Organization xmlns="urn:oasis:names:tc:SAML:2.0:metadata">
  % for my $name (@{ $self->names }) {
  <OrganizationName xml:lang="en"><%= $name %></OrganizationName>
  % }
  % for my $dn (@{ $self->display_names }) {
  <OrganizationDisplayName xml:lang="en"><%= $dn %></OrganizationDisplayName>
  % }
  % for my $url(@{ $self->urls }) {
  <OrganizationURL xml:lang="en"><%= $url %></OrganizationURL>
  % }
</Organization>
XML

sub before_render {
  my $self = shift;
  for my $method (qw/display_names names urls/) {
    Carp::croak "$method cannot be empty" unless @{$self->$method};
  }
}

1;

