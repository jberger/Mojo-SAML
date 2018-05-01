package Mojo::SAML;

our @doc_types;
BEGIN {
  @doc_types = (qw/
    KeyInfo KeyDescriptor Organization ContactPerson
    AssertionConsumerService SPSSODescriptor EntityDescriptor
  /);

  for my $type (@doc_types) {
    my $package = "Mojo::SAML::Document::$type";
    eval "require $package";
    die $@ if $@;
    *{$type} = sub () { $package };
  }
}

use Mojo::Base -strict;

use Exporter 'import';
our %EXPORT_TAGS = (
  'docs' => [ @doc_types ],
);
our @EXPORT_OK = (@doc_types);

1;

