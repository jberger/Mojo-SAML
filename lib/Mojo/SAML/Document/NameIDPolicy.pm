package Mojo::SAML::Document::NameIDPolicy;

use Mojo::Base 'Mojo::SAML::Document';

use Mojo::SAML::Names;

has template => sub { shift->build_template(<<'XML') };
%= tag NameIDPolicy => $self->tag_attrs
XML

has [qw/format sp_name_qualifier allow_create/];

sub tag_attrs {
  my $self = shift;
  my @attrs = (
    xmlns => 'urn:oasis:names:tc:SAML:2.0:protocol',
  );
  if (defined(my $format = $self->format)) {
    push @attrs, Format => Mojo::SAML::Names::nameid_format($format);
  }
  if (defined(my $qual = $self->sp_name_qualifier)) {
    push @attrs, SPNameQualifier => $qual;
  }
  if (defined(my $create = $self->allow_create)) {
    push @attrs, AllowCreate => $create ? 'true' : 'false';
  }
  return @attrs;
}

1;

