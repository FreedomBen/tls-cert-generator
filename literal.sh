#!/usr/bin/env bash

set -e

generate_user ()
{
  openssl genrsa -out enduser-certs/${1}.key 4096
  openssl req -new -sha256 -key enduser-certs/${1}.key -out enduser-certs/${1}.csr
  openssl ca -batch -config ca.conf -notext -in enduser-certs/${1}.csr -out enduser-certs/${1}.crt

  openssl ca -config ca.conf -gencrl -keyfile intermediate1.key -cert intermediate1.crt -out intermediate1.crl.pem
  openssl crl -inform PEM -in intermediate1.crl.pem -outform DER -out intermediate1.crl

  cat ../root/rootca.crt intermediate1.crt > enduser-certs/${1}.chain
  openssl verify -CAfile enduser-certs/${1}.chain enduser-certs/${1}.crt
  openssl verify -crl_check -CAfile enduser-certs/${1}.crl.chain enduser-certs/${1}.crt
}

if [ -z "$1" ] || [[ $1 =~ ^--?h ]]; then
  echo "Add subjectAltNames and purposes to ca.conf, then pass directory name to output to"
  exit 1
fi

mkdir -p "${1}/root/"
cd "${1}/root/"
cp ../../ca.conf ./

# Gen root CA
openssl genrsa -aes256 -out rootca.key 8192
openssl req -sha256 -new -x509 -days 1826 -key rootca.key -out rootca.crt

touch certindex
echo 1000 > certserial
echo 1000 > crlnumber

mkdir enduser-certs

# Gen intermediate CA
openssl genrsa -out intermediate1.key 8192
openssl req -sha256 -new -key intermediate1.key -out intermediate1.csr
openssl ca -batch -config ca.conf -notext -in intermediate1.csr -out intermediate1.crt

openssl ca -config ca.conf -gencrl -keyfile rootca.key -cert rootca.crt -out rootca.crl.pem
openssl crl -inform PEM -in rootca.crl.pem -outform DER -out rootca.crl

mkdir ../intermediate1
cp intermediate1.key ../intermediate1
cp intermediate1.crt ../intermediate1
cd ../intermediate1
cp ../../ca.conf ./

touch certindex
echo 1000 > certserial
echo 1000 > crlnumber

openssl ca -config ca.conf -gencrl -keyfile intermediate1.key -cert intermediate1.crt -out intermediate1.crl.pem
openssl crl -inform PEM -in intermediate1.crl.pem -outform DER -out intermediate1.crl

mkdir enduser-certs

generate_user "server"
generate_user "client"
generate_user "user1"
generate_user "user2"
