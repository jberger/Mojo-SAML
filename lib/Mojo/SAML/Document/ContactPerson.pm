package Mojo::SAML::Document::ContactPerson;

use Mojo::Base 'Mojo::SAML::Document';

has template => sub { shift->build_template(<<'XML') };
% my @attrs = (xmlns => 'urn:oasis:names:tc:SAML:2.0:metadata', contactType => $self->type);
%= tag ContactPerson => @attrs => begin
  % if (my $name = $self->given_name) {
  <GivenName><%= $name %></GivenName>
  % }
  % if (my $surname = $self->surname) {
  <SurName><%= $surname %></SurName>
  % }
  % if (my $company = $self->company) {
  <Company><%= $company %></Company>
  % }
  % for my $email (@{ $self->emails }) {
  <EmailAddress>mailto:<%= $email %></EmailAddress>
  % }
  % for my $phone (@{ $self->telephone_numbers }) {
  <TelephoneNumber><%= $phone %></TelephoneNumber>
  % }
% end
XML

has type => sub { Carp::croak 'type is required' };
has [qw/given_name surname company/];
has [qw/emails telephone_numbers/] => sub { [] };

1;

