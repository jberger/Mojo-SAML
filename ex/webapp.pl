use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use Mojolicious::Lite;

use Crypt::OpenSSL::RSA;
use Crypt::OpenSSL::X509;
use Data::GUID;
use Mojo::File 'path';
use Mojo::SAML ':docs';
use Mojo::SAML::IdP;
use Mojo::Util;

my $config = app->plugin('Config');

my $key = Crypt::OpenSSL::RSA->new_private_key(path($config->{SAML}{key})->slurp);
my $cert = Crypt::OpenSSL::X509->new_from_string(path($config->{SAML}{cert})->slurp);
my $idp = Mojo::SAML::IdP->new->from_file($config->{SAML}{idp});
my $entity_id = $config->{SAML}{entity_id};
my $location = $config->{SAML}{location};

my $key_info = KeyInfo->new(cert => $cert);
my $key_desc = KeyDescriptor->new(
  key_info => $key_info,
  use => 'signing',
);
my $post = AssertionConsumerService->new(
  index    => 0,
  binding  => 'HTTP-POST',
  location => $location,
);
my $redir = AssertionConsumerService->new(
  index    => 1,
  binding  => 'HTTP-Redirect',
  location => $location,
);
my $sp = SPSSODescriptor->new(
  key_descriptors => [$key_desc],
  assertion_consumer_services => [$post, $redir],
  nameid_format => [qw/unspecified/],
);
my $entity = EntityDescriptor->new(
  id => 'abcde',
  entity_id => $entity_id,
  descriptors => [$sp],
  key => $key,
  key_info => $key_info,
);
my $my_meta = "$entity";
die 'Does not verify' unless Mojo::SAML::XML::verify($my_meta);

get '/saml/descriptor' => { text => $my_meta, format => 'xml' };

any '/saml' => sub {
  my $c = shift;
  my $text = Mojo::Util::b64_decode($c->param('SAMLResponse'));
  $c->render(text => $text, format => 'xml');
};

helper build_auth_req => sub {
  my $c = shift;
  $c->session->{target} = $c->req->url;
  my $url = $idp->location_for(SingleSignOnService => 'HTTP-Redirect');
  my $req = AuthnRequest->new(
    issuer => $c->config->{SAML}{entity_id},
    assertion_consumer_service_index => 0,
    is_passive => 0,
    nameid_policy => NameIDPolicy->new(format => 'unspecified'),
    destination => "$url",
  );
  $url->query(SAMLRequest => $req->to_string_deflate);

  my  $sign_requests = 1;
  if ($sign_requests) {
    $url->query({SigAlg => 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256'});
    $key->use_sha256_hash;
    my $val = $url->query->to_string;
    my $sig = $key->sign($val);
    $url->query({Signature => Mojo::Util::b64_encode($sig, '')});
  }

  $c->redirect_to($url);
};

get '/private' => sub {
  my $c = shift;
  return $c->build_auth_req
    unless $c->session->{username};
  $c->render(text => 'PRIVATE!');
};

app->start;
