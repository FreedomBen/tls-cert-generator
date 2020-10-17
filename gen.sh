#!/usr/bin/env bash

generate_private_key ()
{
  openssl genrsa -out "${1}" 8192
}

gen_self_signed_crt ()
{
  # TODO - add CN and stuff
  openssl req -sha256 -new -x509 -days 1826 -key "${1}" -out "${2}"
}

create_serial_files ()
{
  touch certindex
  echo 1000 > certserial
  echo 1000 > crlnumber
}

generate_root_ca ()
{
  generate_private_key "rootca.key"
  gen_self_signed_crt "rootca.key" "rootca.crt"
  create_serial_files
}

generate_intermediate_ca ()
{
  generate_private_key "intermdiate.key"
  generate_csr

  create_serial_files
}

generate_server ()
{
  echo "ohai"
}

generate_client ()
{
  echo "ohai"
}

main ()
{
  prevdir="$(pwd)"
  mkdir -p "${1}/root"
  cd "${1}/root"

  generate_root_ca
  generate_server
  generate_client

  generate_intermediate_ca
  generate_server
  generate_client
}

if [ -z "$1" ] || [[ $1 =~ ^--?h ]]; then
  echo "SCRIPT IS NOT FINISHED!  Use litera.sh instead for now"
  echo "Add subjectAltNames and purposes to ca.conf, then pass directory name to output to"
  exit 1
fi

main "$1"
