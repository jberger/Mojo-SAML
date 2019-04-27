use Mojo::Base -strict;

use Mojo::XMLSig;
use Mojo::File 'path';
use Mojo::Util;

use Test::More tests=>3;

my $main='main';
my $src_xml;

# lazy trick to allow for adding more xml chunks to validate
for(my $id=1;$main->can($src_xml="XML_$id");++$id)  {
  my $xml=$main->$src_xml();
  ok(Mojo::XMLSig::verify($xml),"test Mojo::XMLSig::verify XML sample XML_$id");
}
## BELOW THIS LINE IS SAMPLE XML FOR VALIDATION ##


sub XML_1 {
my $xml=q{<samlp:Response xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Destination="https://socmon-dev.corp.chartercom.com/Idp/saml/consumer-post" ID="idH8KwdpaJhOWnNnMKM0atozZVLaw" IssueInstant="2019-04-20T00:15:14Z" Version="2.0"><saml:Issuer>https://login.esso-uat.charter.com:8443/nidp/saml2/metadata</saml:Issuer><samlp:Status><samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"/></samlp:Status><saml:Assertion ID="idTV6qR57CrTJM-kapCSHto9QKcpQ" IssueInstant="2019-04-20T00:15:15Z" Version="2.0"><saml:Issuer>https://login.esso-uat.charter.com:8443/nidp/saml2/metadata</saml:Issuer><ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#"><ds:SignedInfo><CanonicalizationMethod xmlns="http://www.w3.org/2000/09/xmldsig#" Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/><ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/><ds:Reference URI="#idTV6qR57CrTJM-kapCSHto9QKcpQ"><ds:Transforms><ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/><ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/></ds:Transforms><ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/><DigestValue xmlns="http://www.w3.org/2000/09/xmldsig#">aFGVEGqVoZx5wOSez703l81dJWM=</DigestValue></ds:Reference></ds:SignedInfo><SignatureValue xmlns="http://www.w3.org/2000/09/xmldsig#">
D70iZkosc2pk71FRZqnUoMjC1kN10kU30hivx/Aujee1Qd36Ftz/0cJcZX+D8zChXhKm/qWSXnud
dMikBN04OAnXEHC1VGj4JzfqvcXLuVprjRv+xyZ9Ono/aEhF70GgS5HrKPsN9lrVVZzRAlYoN5S1
c8dOWRSF1eZp6+34zVo+bKLe+XqON+cnGlDcGDu+Im4e1wZCc//jz+uon6Ggt6G7d8qeL4kFhCBj
5/CEGeMugc/a+CHd7ItDlWxrBgeTK1dcsCskdln2QtJj43BFbs2WY9S/ocJ/WBq0EH9AxFIjxmUa
3PMygRV7w7S7r+r3eI/hYMLyiShY9qQr+PLVnQ==
</SignatureValue><ds:KeyInfo><ds:X509Data><ds:X509Certificate>
MIIGeTCCBWGgAwIBAgIQDEP6J8wBPirOtNtbOMFM/DANBgkqhkiG9w0BAQsFADBNMQswCQYDVQQG
EwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMScwJQYDVQQDEx5EaWdpQ2VydCBTSEEyIFNlY3Vy
ZSBTZXJ2ZXIgQ0EwHhcNMTgwNTA0MDAwMDAwWhcNMTkwNTA1MTIwMDAwWjCBvDELMAkGA1UEBhMC
VVMxETAPBgNVBAgTCE1pc3NvdXJpMRQwEgYDVQQHEwtTYWludCBMb3VpczEuMCwGA1UEChMlQ2hh
cnRlciBDb21tdW5pY2F0aW9ucyBPcGVyYXRpbmcsIExMQzEzMDEGA1UECxMqQ2hhcnRlciBDb21t
dW5pY2F0aW9ucyBIb2xkaW5nIENvbXBhbnkgTExDMR8wHQYDVQQDDBYqLmVzc28tdWF0LmNoYXJ0
ZXIuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxgEYHKU22bWmcPBsmOHRcgk2
6kbbPwsXSKEASJ44Y1pQecjMUezD9IJ8G2xyTzRawuR3zSNgtl34FBk77Xij4XBMcmpLHYaxQpF1
pobIZ1nEo7BGNkcRJERCg/uFkifdWfXEj5YQeX/90W8rq2dzza+UsI6g0COGdiYphVNqq4pbXA7l
0FcLZpnhNm4Le2KQQOIK1+oqf8AsBtP/j2QKShzhiqcz01BEvOPbVYdr/7aPK7qMhrn6cIhftk6D
i5lmkkqWojh9TBntz0f3Pg3ZYpm2nHGEW5Iykwa01zaGP6Pg61v1kLsQclmhetZ6ORPehjPsxxWq
+4VdF9tIYA5NzwIDAQABo4IC4zCCAt8wHwYDVR0jBBgwFoAUD4BhHIIxYdUvKOeNRji0LOHG2eIw
HQYDVR0OBBYEFBRYgP6tmV8iTA5e6bwAUCVQnsCGMCEGA1UdEQQaMBiCFiouZXNzby11YXQuY2hh
cnRlci5jb20wDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjBr
BgNVHR8EZDBiMC+gLaArhilodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vc3NjYS1zaGEyLWc2LmNy
bDAvoC2gK4YpaHR0cDovL2NybDQuZGlnaWNlcnQuY29tL3NzY2Etc2hhMi1nNi5jcmwwTAYDVR0g
BEUwQzA3BglghkgBhv1sAQEwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29t
L0NQUzAIBgZngQwBAgIwfAYIKwYBBQUHAQEEcDBuMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
aWdpY2VydC5jb20wRgYIKwYBBQUHMAKGOmh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdp
Q2VydFNIQTJTZWN1cmVTZXJ2ZXJDQS5jcnQwCQYDVR0TBAIwADCCAQUGCisGAQQB1nkCBAIEgfYE
gfMA8QB3ALvZ37wfinG1k5Qjl6qSe0c4V5UKq1LoGpCWZDaOHtGFAAABYyzERvkAAAQDAEgwRgIh
ALV1YgPAvUN+xT2WpGiFBWeciqZdH2VP3Wle4NwmwfDDAiEA5XCGvXAoS9qbtuK/d6z2Q0OvCjiy
IDSBhlE85KtCq8gAdgBvU3asMfAxGdiZAKRRFf93FRwR2QLBACkGjbIImjfZEwAAAWMsxEfjAAAE
AwBHMEUCIQD4uh0hnNNTGmOTtxDNWk0bAZ5pQ9vK1X0vJNXv1hg8kAIgYk6UFO+LmGx6BAaPZKhh
VnoWQjjP/fmWYqt251eZQAYwDQYJKoZIhvcNAQELBQADggEBAEu0kAIDjVBrHroXWfhvC0P06Xlc
bHnJnEklvan4BhLChvEh8UYy6QnLohW9EjDJOkcKWg+bh2XwKOpDlnA6adpBJvQl6k5UnI55JmVq
/dkjQfV1ej7oqCvRoPRhkmf6xdPx2qVL0X5jF1ecBCHRPpf9SviBYvx3enW9gr753eZle7REgmW5
rMfpaChH4rIyHNoaGYkWmjcXXcExGjXrfjWV7prq7t2WtV94Cp3cYJluR1lzhTn+xHB+ql4B0RRm
HaFGXmUFaWjiYUK8bHYul+yzweT6tNkyyccMoM3l+JcxL3x/2zrUZ2Kdt4eg68yaW50XAWTUeL56
QHEICoacURM=
</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature><saml:Subject><saml:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified" NameQualifier="https://login.esso-uat.charter.com:8443/nidp/saml2/metadata" SPNameQualifier="https://socmon-dev.corp.chartercom.com">mshipper</saml:NameID><saml:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer"><saml:SubjectConfirmationData NotOnOrAfter="2019-04-20T00:20:15Z" Recipient="https://socmon-dev.corp.chartercom.com/Idp/saml/consumer-post"/></saml:SubjectConfirmation></saml:Subject><saml:Conditions NotBefore="2019-04-20T00:10:15Z" NotOnOrAfter="2019-04-20T00:20:15Z"><saml:AudienceRestriction><saml:Audience>https://socmon-dev.corp.chartercom.com</saml:Audience></saml:AudienceRestriction></saml:Conditions><saml:AuthnStatement AuthnInstant="2019-04-19T22:27:54Z" SessionIndex="idVKIoxjLWnYYmX08J8RPVdyQad44"><saml:AuthnContext><saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:Kerberos</saml:AuthnContextClassRef><saml:AuthnContextDeclRef>https://login.esso-uat.charter.com:8443/nidp/kerberos/vds/uri</saml:AuthnContextDeclRef></saml:AuthnContext></saml:AuthnStatement><saml:AttributeStatement><saml:Attribute xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/sAMAccountName" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"><saml:AttributeValue xsi:type="xs:string">mshipper</saml:AttributeValue></saml:Attribute></saml:AttributeStatement></saml:Assertion></samlp:Response>};

}

sub XML_2 {
q{<samlp:Response xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" Destination="https://socmon-dev.corp.chartercom.com:6018/Idp/saml/consumer-post" ID="id8w3IZdMk6YD1rspzdOfnswMQNIQ" InResponseTo="7d9b5a7b6b8aeedab1f09dfc6077f698" IssueInstant="2019-04-18T17:12:32Z" Version="2.0"><saml:Issuer>https://login.esso-uat.charter.com:8443/nidp/saml2/metadata</saml:Issuer><samlp:Status><samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"/></samlp:Status><saml:Assertion ID="idal6qFSWxe8nmrW632tcLu7ZERzI" IssueInstant="2019-04-18T17:12:33Z" Version="2.0"><saml:Issuer>https://login.esso-uat.charter.com:8443/nidp/saml2/metadata</saml:Issuer><ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#"><ds:SignedInfo><CanonicalizationMethod xmlns="http://www.w3.org/2000/09/xmldsig#" Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/><ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/><ds:Reference URI="#idal6qFSWxe8nmrW632tcLu7ZERzI"><ds:Transforms><ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/><ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/></ds:Transforms><ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/><DigestValue xmlns="http://www.w3.org/2000/09/xmldsig#">HbwOgwYFG4wsn3h/Qh8WrW7Mbfs=</DigestValue></ds:Reference></ds:SignedInfo><SignatureValue xmlns="http://www.w3.org/2000/09/xmldsig#">
avnuDiy+CbGTwbkZ9VKr54NXE/wxEBnFEYaDxZo9+0TEPBj3kcojEQXUAfEfT1Lv65ifBVNkwnV9
PMmB/QemXvy6ZjQIHCM3ituIySzfu9zAgYeN/jE+TdUqfrsb9zwQhPhdv0+Tx3ypdx7d5Eloqd/D
IytbIP71BpEKAcvlts4aWKxf8hNvAeXyYLAGRSlbzY6nkuqdkE55+mU0ZLASIZFpALuWOKVZyDmD
7GJomrK10lbHwJa2q0JPU7QW66+edcHXVmuNXs8m+qfBY4EFMoeA2pNKQwrtCG9TbBrQcyI5aDTJ
l+cEY1CjhGlfEeP9EBqZ80bJ6K6Dy+xQd5sSIA==
</SignatureValue><ds:KeyInfo><ds:X509Data><ds:X509Certificate>
MIIGeTCCBWGgAwIBAgIQDEP6J8wBPirOtNtbOMFM/DANBgkqhkiG9w0BAQsFADBNMQswCQYDVQQG
EwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMScwJQYDVQQDEx5EaWdpQ2VydCBTSEEyIFNlY3Vy
ZSBTZXJ2ZXIgQ0EwHhcNMTgwNTA0MDAwMDAwWhcNMTkwNTA1MTIwMDAwWjCBvDELMAkGA1UEBhMC
VVMxETAPBgNVBAgTCE1pc3NvdXJpMRQwEgYDVQQHEwtTYWludCBMb3VpczEuMCwGA1UEChMlQ2hh
cnRlciBDb21tdW5pY2F0aW9ucyBPcGVyYXRpbmcsIExMQzEzMDEGA1UECxMqQ2hhcnRlciBDb21t
dW5pY2F0aW9ucyBIb2xkaW5nIENvbXBhbnkgTExDMR8wHQYDVQQDDBYqLmVzc28tdWF0LmNoYXJ0
ZXIuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxgEYHKU22bWmcPBsmOHRcgk2
6kbbPwsXSKEASJ44Y1pQecjMUezD9IJ8G2xyTzRawuR3zSNgtl34FBk77Xij4XBMcmpLHYaxQpF1
pobIZ1nEo7BGNkcRJERCg/uFkifdWfXEj5YQeX/90W8rq2dzza+UsI6g0COGdiYphVNqq4pbXA7l
0FcLZpnhNm4Le2KQQOIK1+oqf8AsBtP/j2QKShzhiqcz01BEvOPbVYdr/7aPK7qMhrn6cIhftk6D
i5lmkkqWojh9TBntz0f3Pg3ZYpm2nHGEW5Iykwa01zaGP6Pg61v1kLsQclmhetZ6ORPehjPsxxWq
+4VdF9tIYA5NzwIDAQABo4IC4zCCAt8wHwYDVR0jBBgwFoAUD4BhHIIxYdUvKOeNRji0LOHG2eIw
HQYDVR0OBBYEFBRYgP6tmV8iTA5e6bwAUCVQnsCGMCEGA1UdEQQaMBiCFiouZXNzby11YXQuY2hh
cnRlci5jb20wDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjBr
BgNVHR8EZDBiMC+gLaArhilodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vc3NjYS1zaGEyLWc2LmNy
bDAvoC2gK4YpaHR0cDovL2NybDQuZGlnaWNlcnQuY29tL3NzY2Etc2hhMi1nNi5jcmwwTAYDVR0g
BEUwQzA3BglghkgBhv1sAQEwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29t
L0NQUzAIBgZngQwBAgIwfAYIKwYBBQUHAQEEcDBuMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
aWdpY2VydC5jb20wRgYIKwYBBQUHMAKGOmh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdp
Q2VydFNIQTJTZWN1cmVTZXJ2ZXJDQS5jcnQwCQYDVR0TBAIwADCCAQUGCisGAQQB1nkCBAIEgfYE
gfMA8QB3ALvZ37wfinG1k5Qjl6qSe0c4V5UKq1LoGpCWZDaOHtGFAAABYyzERvkAAAQDAEgwRgIh
ALV1YgPAvUN+xT2WpGiFBWeciqZdH2VP3Wle4NwmwfDDAiEA5XCGvXAoS9qbtuK/d6z2Q0OvCjiy
IDSBhlE85KtCq8gAdgBvU3asMfAxGdiZAKRRFf93FRwR2QLBACkGjbIImjfZEwAAAWMsxEfjAAAE
AwBHMEUCIQD4uh0hnNNTGmOTtxDNWk0bAZ5pQ9vK1X0vJNXv1hg8kAIgYk6UFO+LmGx6BAaPZKhh
VnoWQjjP/fmWYqt251eZQAYwDQYJKoZIhvcNAQELBQADggEBAEu0kAIDjVBrHroXWfhvC0P06Xlc
bHnJnEklvan4BhLChvEh8UYy6QnLohW9EjDJOkcKWg+bh2XwKOpDlnA6adpBJvQl6k5UnI55JmVq
/dkjQfV1ej7oqCvRoPRhkmf6xdPx2qVL0X5jF1ecBCHRPpf9SviBYvx3enW9gr753eZle7REgmW5
rMfpaChH4rIyHNoaGYkWmjcXXcExGjXrfjWV7prq7t2WtV94Cp3cYJluR1lzhTn+xHB+ql4B0RRm
HaFGXmUFaWjiYUK8bHYul+yzweT6tNkyyccMoM3l+JcxL3x/2zrUZ2Kdt4eg68yaW50XAWTUeL56
QHEICoacURM=
</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature><saml:Subject><saml:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified" NameQualifier="https://login.esso-uat.charter.com:8443/nidp/saml2/metadata" SPNameQualifier="https://socmon-dev.corp.chartercom.com:6018">mshipper</saml:NameID><saml:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer"><saml:SubjectConfirmationData InResponseTo="7d9b5a7b6b8aeedab1f09dfc6077f698" NotOnOrAfter="2019-04-18T17:17:33Z" Recipient="https://socmon-dev.corp.chartercom.com:6018/Idp/saml/consumer-post"/></saml:SubjectConfirmation></saml:Subject><saml:Conditions NotBefore="2019-04-18T17:07:33Z" NotOnOrAfter="2019-04-18T17:17:33Z"><saml:AudienceRestriction><saml:Audience>https://socmon-dev.corp.chartercom.com:6018</saml:Audience></saml:AudienceRestriction></saml:Conditions><saml:AuthnStatement AuthnInstant="2019-04-18T15:03:09Z" SessionIndex="idUEEbejj9bf9GtpZ2-WNT-20MrS8"><saml:AuthnContext><saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:Kerberos</saml:AuthnContextClassRef><saml:AuthnContextDeclRef>https://login.esso-uat.charter.com:8443/nidp/kerberos/vds/uri</saml:AuthnContextDeclRef></saml:AuthnContext></saml:AuthnStatement><saml:AttributeStatement><saml:Attribute xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/sAMAccountName" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"><saml:AttributeValue xsi:type="xs:string">mshipper</saml:AttributeValue></saml:Attribute></saml:AttributeStatement></saml:Assertion></samlp:Response>};
}

sub XML_3 {
 q{<samlp:Response xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="_8e8dc5f69a98cc4c1ff3427e5ce34606fd672f91e6" Version="2.0" IssueInstant="2014-07-17T01:01:48Z" Destination="http://sp.example.com/demo1/index.php?acs" InResponseTo="ONELOGIN_4fee3b046395c4e751011e97f8900b5273d56685">
  <saml:Issuer>http://idp.example.com/metadata.php</saml:Issuer>
  <samlp:Status>
    <samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"/>
  </samlp:Status>
  <saml:Assertion xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" ID="pfxd646decc-0bca-56d8-a0a5-949948fd2d42" Version="2.0" IssueInstant="2014-07-17T01:01:48Z">
    <saml:Issuer>http://idp.example.com/metadata.php</saml:Issuer><ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
  <ds:SignedInfo><ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
    <ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>
  <ds:Reference URI="#pfxd646decc-0bca-56d8-a0a5-949948fd2d42"><ds:Transforms><ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/><ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/></ds:Transforms><ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/><ds:DigestValue>lMma2qw+T6bkAmEi7adZPXaXdG0=</ds:DigestValue></ds:Reference></ds:SignedInfo><ds:SignatureValue>FkgMbx1rcqHI/d7Otmd6CJaHhavrUxHiVjxBas/sFjm5I89CItpqhcKOHAZXr3RuVcSNt12czbgwPLM0I4Zi0vvtb2dt+xcjy/cNnjOATLq6ujifCGLe6pU9A0TdOHKb7azd5OcE7XdeMVRi3vYfGpngCr7Ux1xYsHL/Q2Hfh7Q=</ds:SignatureValue>
<ds:KeyInfo><ds:X509Data><ds:X509Certificate>MIICajCCAdOgAwIBAgIBADANBgkqhkiG9w0BAQ0FADBSMQswCQYDVQQGEwJ1czETMBEGA1UECAwKQ2FsaWZvcm5pYTEVMBMGA1UECgwMT25lbG9naW4gSW5jMRcwFQYDVQQDDA5zcC5leGFtcGxlLmNvbTAeFw0xNDA3MTcxNDEyNTZaFw0xNTA3MTcxNDEyNTZaMFIxCzAJBgNVBAYTAnVzMRMwEQYDVQQIDApDYWxpZm9ybmlhMRUwEwYDVQQKDAxPbmVsb2dpbiBJbmMxFzAVBgNVBAMMDnNwLmV4YW1wbGUuY29tMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDZx+ON4IUoIWxgukTb1tOiX3bMYzYQiwWPUNMp+Fq82xoNogso2bykZG0yiJm5o8zv/sd6pGouayMgkx/2FSOdc36T0jGbCHuRSbtia0PEzNIRtmViMrt3AeoWBidRXmZsxCNLwgIV6dn2WpuE5Az0bHgpZnQxTKFek0BMKU/d8wIDAQABo1AwTjAdBgNVHQ4EFgQUGHxYqZYyX7cTxKVODVgZwSTdCnwwHwYDVR0jBBgwFoAUGHxYqZYyX7cTxKVODVgZwSTdCnwwDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQ0FAAOBgQByFOl+hMFICbd3DJfnp2Rgd/dqttsZG/tyhILWvErbio/DEe98mXpowhTkC04ENprOyXi7ZbUqiicF89uAGyt1oqgTUCD1VsLahqIcmrzgumNyTwLGWo17WDAa1/usDhetWAMhgzF/Cnf5ek0nK00m0YZGyc4LzgD0CROMASTWNg==</ds:X509Certificate></ds:X509Data></ds:KeyInfo></ds:Signature>
    <saml:Subject>
      <saml:NameID SPNameQualifier="http://sp.example.com/demo1/metadata.php" Format="urn:oasis:names:tc:SAML:2.0:nameid-format:transient">_ce3d2948b4cf20146dee0a0b3dd6f69b6cf86f62d7</saml:NameID>
      <saml:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer">
        <saml:SubjectConfirmationData NotOnOrAfter="2024-01-18T06:21:48Z" Recipient="http://sp.example.com/demo1/index.php?acs" InResponseTo="ONELOGIN_4fee3b046395c4e751011e97f8900b5273d56685"/>
      </saml:SubjectConfirmation>
    </saml:Subject>
    <saml:Conditions NotBefore="2014-07-17T01:01:18Z" NotOnOrAfter="2024-01-18T06:21:48Z">
      <saml:AudienceRestriction>
        <saml:Audience>http://sp.example.com/demo1/metadata.php</saml:Audience>
      </saml:AudienceRestriction>
    </saml:Conditions>
    <saml:AuthnStatement AuthnInstant="2014-07-17T01:01:48Z" SessionNotOnOrAfter="2024-07-17T09:01:48Z" SessionIndex="_be9967abd904ddcae3c0eb4189adbe3f71e327cf93">
      <saml:AuthnContext>
        <saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:Password</saml:AuthnContextClassRef>
      </saml:AuthnContext>
    </saml:AuthnStatement>
    <saml:AttributeStatement>
      <saml:Attribute Name="uid" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic">
        <saml:AttributeValue xsi:type="xs:string">test</saml:AttributeValue>
      </saml:Attribute>
      <saml:Attribute Name="mail" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic">
        <saml:AttributeValue xsi:type="xs:string">test@example.com</saml:AttributeValue>
      </saml:Attribute>
      <saml:Attribute Name="eduPersonAffiliation" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic">
        <saml:AttributeValue xsi:type="xs:string">users</saml:AttributeValue>
        <saml:AttributeValue xsi:type="xs:string">examplerole1</saml:AttributeValue>
      </saml:Attribute>
    </saml:AttributeStatement>
  </saml:Assertion>
</samlp:Response>}; 
}

