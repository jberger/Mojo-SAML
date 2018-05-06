package Mojo::SAML;

use Mojo::Base -strict;

use constant ();
use Exporter 'import';
use Mojo::Util;

our @doc_types = (qw/
  KeyInfo KeyDescriptor Organization ContactPerson
  AssertionConsumerService SPSSODescriptor EntityDescriptor
  AuthnRequest NameIDPolicy
/);

for my $type (@doc_types) {
  my $package = "Mojo::SAML::Document::$type";
  require(Mojo::Util::class_to_path($package));
  constant->import($type => $package);
}

our %EXPORT_TAGS = (
  'docs' => [ @doc_types ],
);
our @EXPORT_OK = @doc_types;

1;

