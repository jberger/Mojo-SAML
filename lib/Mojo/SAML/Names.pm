package Mojo::SAML::Names;

use Mojo::Base -strict;
use Carp ();
use Exporter 'import';

our @EXPORT_OK = (qw/binding nameid_format/);

my %binding_aliases = (
  SOAP => 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP',
  'HTTP-Redirect' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
  'HTTP-POST' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
);
my @bindings = values %binding_aliases;
my %valid_bindings; @valid_bindings{@bindings} = (1) x @bindings;

sub binding {
  my ($in, $lax) = @_;
  return $binding_aliases{$in} if exists $binding_aliases{$in};
  return $in if $valid_bindings{$in} || $lax;
  Carp::croak "$in is not a valid binding (or alias)";
}


my %nameid_format_aliases = (
  unspecified => 'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified',
  emailAddress => 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',
  X509SubjectName => 'urn:oasis:names:tc:SAML:1.1:nameid-format:X509SubjectName',
  WindowsDomainQualifiedName => 'urn:oasis:names:tc:SAML:1.1:nameid-format:WindowsDomainQualifiedName',
  kerberos => 'urn:oasis:names:tc:SAML:2.0:nameid-format:kerberos',
  entity => 'urn:oasis:names:tc:SAML:2.0:nameid-format:entity',
  persistent => 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent',
  transient => 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient',
);
my @nameid_formats = values %binding_aliases;
my %valid_nameid_formats; @valid_nameid_formats{@nameid_formats} = (1) x @nameid_formats;

sub nameid_format {
  my ($in, $lax) = @_;
  return $nameid_format_aliases{$in} if exists $nameid_format_aliases{$in};
  return $in if $valid_nameid_formats{$in} || $lax;
  Carp::croak "$in is not a valid nameid format";
}

1;

