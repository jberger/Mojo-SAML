package Mojo::SAML::Document::Signature;

use Mojo::Base 'Mojo::SAML::Document';

use Mojo::SAML::Document::KeyInfo;

has template => sub { shift->build_template(<<'XML') };
<ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
  <ds:SignedInfo>
    <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
    <ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>
    % for my $ref (@{ $self->references }) {
    %= tag 'ds:Reference' => URI => "#$ref" => begin
      <ds:Transforms>
        <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
        <ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
      </ds:Transforms>
      <ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>
      <ds:DigestValue></ds:DigestValue>
    </ds:Reference>
    % end
    % }
  </ds:SignedInfo>
  <ds:SignatureValue></ds:SignatureValue>
  % if (my $info = $self->key_info) {
    <%= $info %>
  % }
</ds:Signature>
XML

has 'key_info';
has references => sub { [] };


sub before_render {
  my $self = shift;
  for my $method (qw/references/) {
    Carp::croak "$method cannot be empty" unless @{$self->$method};
  }
}


1;

