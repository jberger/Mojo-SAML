package Mojo::SAML;

use Mojo::Base -strict;

our $VERSION = '0.01';
$VERSION = eval $VERSION;

use constant ();
use Exporter 'import';
use Mojo::Util;

our @doc_types = (qw/
  KeyInfo KeyDescriptor Organization ContactPerson
  AssertionConsumerService SPSSODescriptor EntityDescriptor
  AuthnRequest NameIDPolicy Signature
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

=head1 NAME

Mojo::SAML - A SAML2 toolkit using the Mojo toolkit

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SOURCE REPOSITORY

L<http://github.com/jberger/Mojo-SAML>

=head1 AUTHOR

Joel Berger, E<lt>joel.a.berger@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018 by Joel Berger
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
