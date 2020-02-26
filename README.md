# tls-cert-generator

A tool to help create CAs and issue certificates with them for testing.

This tool is 90% complete.  Intermdiate CA isn't implemented yet so don't use it.  As I'm the only known user, the remaining 10% is not a priority.  If you are using this tool let me know and I'll add it to my TODO list.

## Notes

These are notes to help grok what is going on with TLS certs.

Basic steps:

1.  Create root CA
    1.  Generate new RSA key
    2.  Generate crt from key
2.  Create intermediate CA
    1.  Generate new RSA key
    2.  Generate crt from key
    3.  Sign crt with root CA
3.  Create server certificates
    1.  Generate new RSA key
    2.  Generate crt from key
    3.  Sign crt with CA
    4.  Create PEM file by catting server.key and server.crt into same file
4.  Create client certificates
    1.  Generate new RSA key
    2.  Generate crt from key
    3.  Sign crt with CA
    4.  Create PEM file by catting client.key and client.crt into same file
