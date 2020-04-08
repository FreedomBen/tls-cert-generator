#!/usr/bin/env bash

set -e

generate_user ()
{
  echo "Generating key for user '$1'"
  openssl genrsa -out "enduser-certs/${1}.key" 4096

  echo "Generating CSR for user '$1'"
  openssl req -new -key "enduser-certs/${1}.key" -out "enduser-certs/${1}.csr" -subj '/CN=localhost/O=Acme/C=US/ST=ID'

  echo "Signing CSR for user '$1'"
  openssl ca -batch -config ca.conf -notext -in "enduser-certs/${1}.csr" -out "enduser-certs/${1}.crt"

  #openssl ca -config ca.conf -gencrl -keyfile intermediate1.key -cert intermediate1.crt -out intermediate1.crl.pem
  #openssl crl -inform PEM -in intermediate1.crl.pem -outform DER -out intermediate1.crl

  echo "Generating trust chain for user '$1'"
  if [ -f intermediate1.crt ]; then
    cat intermediate1.crt ../root/rootca.crt > "enduser-certs/${1}.chain"
  else
    cp rootca.crt "enduser-certs/${1}.chain"
  fi

  echo "Verifying cert for user '$1'"
  openssl verify -CAfile "enduser-certs/${1}.chain" "enduser-certs/${1}.crt"
  #openssl verify -crl_check -CAfile "enduser-certs/${1}.crl.chain" "enduser-certs/${1}.crt"
}

if [ -z "$1" ] || [[ $1 =~ ^--?h ]]; then
  echo "Add subjectAltNames and purposes to ca.conf, then pass directory name to output to"
  exit 1
fi

if [ -d "${1}" ] && ! [[ "$2" =~ -?-f(orce)? ]]; then
  echo "Output dir exists.  Pass -f|--force as second param to continue anyway"
  exit 1
fi

mkdir -p "${1}/root/"
cd "${1}/root/"
cp ../../ca.conf ./

# Gen root CA
openssl genrsa -out rootca.key 8192
openssl req -new -x509 -days 1826 -key rootca.key -out rootca.crt -subj '/CN=localhost/O=Acme/C=US/ST=ID'

if ! [ -f certindex ]; then
  touch certindex
  echo 1000 > certserial
  echo 1000 > crlnumber
fi

mkdir -p enduser-certs

# Make root direct certs
generate_user "server"
generate_user "client"
generate_user "user1"
generate_user "user2"


# Gen intermediate CA
openssl genrsa -out intermediate1.key 8192
openssl req -new -key intermediate1.key -out intermediate1.csr -subj '/CN=localhost/O=Acme/C=US/ST=ID'
openssl ca -batch -config ca.conf -notext -in intermediate1.csr -out intermediate1.crt

#openssl ca -config ca.conf -gencrl -keyfile rootca.key -cert rootca.crt -out rootca.crl.pem
#openssl crl -inform PEM -in rootca.crl.pem -outform DER -out rootca.crl

mkdir -p ../intermediate1
cp intermediate1.key ../intermediate1
cp intermediate1.crt ../intermediate1
cd ../intermediate1
cp ../../ca.conf ./
sed -i -e 's|rootca|intermediate1|' ca.conf

if ! [ -f certindex ]; then
  touch certindex
  echo 1000 > certserial
  echo 1000 > crlnumber
fi

#openssl ca -config ca.conf -gencrl -keyfile intermediate1.key -cert intermediate1.crt -out intermediate1.crl.pem
#openssl crl -inform PEM -in intermediate1.crl.pem -outform DER -out intermediate1.crl

mkdir -p enduser-certs

generate_user "server"
generate_user "client"
generate_user "user1"
generate_user "user2"
