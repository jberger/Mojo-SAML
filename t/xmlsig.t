use Mojo::Base -strict;

use Mojo::XMLSig;
use Mojo::File 'path';
use Mojo::Util;

use Test::More;

subtest 'existing document' => sub {
  my $req = path('t/keycloak_saml_response.xml')->slurp;
  ok Mojo::XMLSig::has_signature($req), 'sample request has signature';
  ok Mojo::XMLSig::verify($req), 'sample request verifies itself';
};

subtest 'create document, sign, and verify' => sub {
  my $cert = path('t/test.cer')->slurp;
  my $x509 = Crypt::OpenSSL::X509->new_from_string($cert);
  my $pub  = Crypt::OpenSSL::RSA->new_public_key($x509->pubkey);
  my $key  = Crypt::OpenSSL::RSA->new_private_key(path('t/test.key')->slurp);

  $cert = Mojo::XMLSig::trim_cert($cert);

  my $xml = <<"XML";
<Thing ID="abc123"><ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
  <ds:SignedInfo>
    <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#" />
    <ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1" />
    <ds:Reference URI="#abc123">
      <ds:Transforms>
        <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" />
        <ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#" />
      </ds:Transforms>
      <ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1" />
      <ds:DigestValue></ds:DigestValue>
    </ds:Reference>
  </ds:SignedInfo>
  <ds:SignatureValue></ds:SignatureValue>
    <KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
  <X509Data>
    <X509Certificate>$cert</X509Certificate>
  </X509Data>
</KeyInfo>

</ds:Signature>

  <Important>Cool Stuff</Important>
</Thing>
XML

  my $signed = Mojo::XMLSig::sign($xml, $key);
  ok $signed, 'A document was returned';
  ok Mojo::XMLSig::has_signature($signed), 'the document has a signature';
  ok Mojo::XMLSig::verify($signed), 'the signature verifies by itself';
  ok Mojo::XMLSig::verify($signed, $pub), 'the signature verifies using the public key from the cert';

  subtest 'alter the document' => sub {
    my $warn = '';
    local $SIG{__WARN__} = sub { $warn .= $_[0] };
    ok $signed =~ s/Cool Stuff/Very Neat Stuff/, 'substitution was made';
    ok !Mojo::XMLSig::verify($signed), 'the signature no longer verifies';
    ok !Mojo::XMLSig::verify($signed, $pub), 'the signature no longer verifies using the public key from the cert';
    ok $warn, 'warnings were issued';
  };
};

subtest 'verify document with namespaces in the root element' => sub {
    my $xml = <<'XML';
<?xml version="1.0"?>
<ns0:Response xmlns:ns0="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:ns1="urn:oasis:names:tc:SAML:2.0:assertion" xmlns:ns2="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" Destination="http://localhost:3000/spid-sso" ID="id-bs2o9wKTW5kexLCYB" InResponseTo="_08d611cc8979c200343a72acf1f52f59" IssueInstant="2018-07-30T21:56:52Z" Version="2.0"><ns1:Issuer Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">http://localhost:8088</ns1:Issuer><ns0:Status><ns0:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"/></ns0:Status><ns1:Assertion ID="id-JN5Kf0KOaQie49Idv" IssueInstant="2018-07-30T21:56:52Z" Version="2.0"><ns1:Issuer Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">http://localhost:8088</ns1:Issuer><ns2:Signature Id="Signature2"><ns2:SignedInfo><ns2:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/><ns2:SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha512"/><ns2:Reference URI="#id-JN5Kf0KOaQie49Idv"><ns2:Transforms><ns2:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/><ns2:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/></ns2:Transforms><ns2:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha512"/><ns2:DigestValue>heIcI5GfoGcKs8IfXmg0dCDDyLy+HwL+hoeP6upE7RHqdPu2O0/TIzKvNu6zZoio
QEuBzFvHrc6MI12L+zac0A==</ns2:DigestValue></ns2:Reference></ns2:SignedInfo><ns2:SignatureValue>ql3d/EaUGmtc1PvYQo6kvgF0BLBRKlAWGsIspvb52dyWN/x//gjgQ8aV3m6hWFk4
S/uvmXtaTixSv+wX4+o0s3cF0z6LdZvcIhwoUj7xONJ6Lck7M3HVnnQI+9CaVLsx
MBOIMsnnPg7JNhOsmmfc7t0pvLHEgNY7zLB2rxaHxxpFcQFEDUZ80EOjxkkwVHlm
dYbDLyRthW4mOftZHU3BP25t39NmfVtWsCi0GNV6XEdY9+lwXvNk52FGiYdqKheP
2LDKLJyevt4LLhFSVPLQYjPoGseAdRceCFegYLbE0Iuf4WQ0fLkp14QTwrAFZVgM
Nn1wnCg9WyNwclhWnQWyEA==</ns2:SignatureValue><ns2:KeyInfo><ns2:X509Data><ns2:X509Certificate>MIICtDCCAZwCCQDQQ+FCxgMN6jANBgkqhkiG9w0BAQsFADAcMQswCQYDVQQGEwJJVDENMAsGA1UEBwwEUm9tYTAeFw0xODA2MjYxMDM5MzBaFw0xOTA2MjYxMDM5MzBaMBwxCzAJBgNVBAYTAklUMQ0wCwYDVQQHDARSb21hMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAudciVxyXnPvTt2r8+3wE9DsibXu9fZwHjji0rOE7FJj8fm/2rE0/GfDNyymGv7LHx9vKO8p1Ot4cl0ou/bR70PtJW9tM2ssyWPmHQXmBX84FB/IuuOitABEtc3/HsWOyAA23XanCGpv6j6CW8TRjO+bi7nQnW3y/rLuCoTkBihH4QGA0bkg8he56BSa3sAPnyO3VLavlYv3yYCQDqR+r2UM1f8gNPTlE5UIQzOYPXv1w/YrrFhEx7xUYPh1J2e4J6xRRbZqzvB74QF0t0A0XueCITXLuVQ5eQ1rIWFAL1nwMqWvep+3HvDpq0K8nzGFjnut6ElfyyhPp8+/H0zBOkQIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQBw4mfH+WtR/etTVWK1Jy9DXWxAazFViQcVBualTuleRSHZjCv/nyv4YbyFlTNarDI+LF+iG2rCABxgY40L6FpN9Gnsa5wijuKs0E6ZAvJ/rYfrYkE8wd0y8Z23VeoXD/m8OhwcysMtyM10GxZUtEBnpXDAhAFFDyAACfxAQy+/5u1u5dI0189AFk2EcqcSuA9pQWbzhswlQaSQFBU1nabIU2SwDPfHMwLFVrJdH09RuMSKM4IBNzCiLj5KgqepdFO3+8e0ewiwo8imhTYaTDR3ZXQaTNQt99fhT/LOMUcCR4hH14Cn72X7xTPK7hTz4p1D3uXfKT/o1qiql2PAjfl8</ns2:X509Certificate></ns2:X509Data></ns2:KeyInfo></ns2:Signature><ns1:Subject><ns1:NameID Format="urn:oasis:names:tc:SAML:2.0:nameid-format:transient" NameQualifier="http://localhost:8088" SPNameQualifier="https://www.prova.it/">af3affa32ef1269d39c35ed4b19e1764801cbeae6ad6192e42181dcc895da42a</ns1:NameID><ns1:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer"><ns1:SubjectConfirmationData InResponseTo="_08d611cc8979c200343a72acf1f52f59" NotOnOrAfter="2018-07-30T22:56:52Z" Recipient="http://localhost:3000/spid-sso"/></ns1:SubjectConfirmation></ns1:Subject><ns1:Conditions NotBefore="2018-07-30T21:56:52Z" NotOnOrAfter="2018-07-30T22:56:52Z"><ns1:AudienceRestriction><ns1:Audience>https://www.prova.it/</ns1:Audience></ns1:AudienceRestriction></ns1:Conditions><ns1:AuthnStatement AuthnInstant="2018-07-30T21:56:52Z" SessionIndex="id-r2jroLsD1m9tT8cTJ"><ns1:AuthnContext><ns1:AuthnContextClassRef>https://www.spid.gov.it/SpidL1</ns1:AuthnContextClassRef><ns1:AuthenticatingAuthority>https://www.spid.gov.it/SpidL1</ns1:AuthenticatingAuthority></ns1:AuthnContext></ns1:AuthnStatement><ns1:AttributeStatement><ns1:Attribute Name="name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic"><ns1:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xsi:type="xs:string">Mario</ns1:AttributeValue></ns1:Attribute><ns1:Attribute Name="fiscalNumber" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic"><ns1:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xsi:type="xs:string">RSOMRO70M20H501X</ns1:AttributeValue></ns1:Attribute><ns1:Attribute Name="familyName" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic"><ns1:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xsi:type="xs:string">Rossi</ns1:AttributeValue></ns1:Attribute><ns1:Attribute Name="dateOfBirth" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic"><ns1:AttributeValue xmlns:xs="http://www.w3.org/2001/XMLSchema" xsi:type="xs:date">1970-01-01</ns1:AttributeValue></ns1:Attribute></ns1:AttributeStatement></ns1:Assertion></ns0:Response>
XML
    
    ok Mojo::XMLSig::verify($xml), 'document is verified';
};

done_testing;

