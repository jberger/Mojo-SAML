package Mojo::SAML::Document::KeyDescriptor;

use Mojo::Base 'Mojo::SAML::Document';

has template => sub { shift->build_template(<<'XML') };
% my @attrs = (xmlns => 'urn:oasis:names:tc:SAML:2.0:metadata');
% if (my $use = $self->use) { push @attrs, (use => $use) }
%= tag KeyDescriptor => @attrs => begin
  <%= $self->key_info %>
% end
XML

has key_info => sub { Carp::croak 'key_info is required' };
has 'use';

1;

