use Mojo::Base -strict;

use Mojo::SAML::IdP;

my $idp = Mojo::SAML::IdP->new->from_url('https://keycloak.jberger.pl/auth/realms/master/protocol/saml/descriptor');

say $idp->entity_id;
say $idp->location_for('SingleSignOnService', 'HTTP-POST');
say $idp->key_for('signing');
say $idp->name_id_format('transient');
say $idp->default_id_format;

say $idp->validate_signature;

