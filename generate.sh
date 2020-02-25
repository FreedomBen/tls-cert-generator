#!/usr/bin/env bash

die ()
{
  echo "[FATAL]: generate.sh: $1"
  exit 1
}

generate_root_ca_key_and_crt ()
{
  openssl req \
    -nodes \
    -x509 \
    -newkey rsa:2048 \
    -keyout ca.key \
    -out ca.crt \
    -subj "/C=AU/ST=NSW/L=Sydney/O=MongoDB/OU=root/CN=`hostname -f`/emailAddress=freedomben@protonmail.com"
}

generate_server_key_and_csr ()
{
  openssl req \
    -nodes \
    -newkey rsa:2048 \
    -keyout server.key \
    -out server.csr \
    -subj "/C=AU/ST=NSW/L=Sydney/O=MongoDB/OU=server/CN=`hostname -f`/emailAddress=freedomben@protonmail.com"
}

sign_cerver_crt ()
{
  openssl x509 \
    -req \
    -in server.csr \
    -CA ca.crt \
    -CAkey ca.key \
    -CAcreateserial \
    -out server.crt
}

create_server_pem ()
{
  cat server.key server.crt > server.pem
}

generate_client_key_and_csr ()
{
  openssl req \
    -nodes \
    -newkey rsa:2048 \
    -keyout client.key \
    -out client.csr \
    -subj "/C=AU/ST=NSW/L=Sydney/O=MongoDB/OU=client/CN=`hostname -f`/emailAddress=freedomben@protonmail.com"
}

sign_client_crt ()
{
  openssl x509 \
    -req \
    -in client.csr \
    -CA ca.crt \
    -CAkey ca.key \
    -CAserial ca.srl \
    -out client.crt
}

create_client_pem ()
{
  cat client.key client.crt > client.pem
}


create_client_pfx ()
{
  openssl pkcs12 \
    -inkey client.key \
    -in client.crt \
    -export \
    -out client.pfx
}

parse_args ()
{
  for i in "$@"
  do
  case $i in
      -ch=*|--client-hostname=*)
      EXTENSION="${i#*=}"
      shift # past argument=value
      ;;
      -sh=*|--server-hostname=*)
      EXTENSION="${i#*=}"
      shift # past argument=value
      ;;
      -ni=*|--num-intermediates=*)
      SEARCHPATH="${i#*=}"
      shift # past argument=value
      ;;
      -nc=*|--num-clients=*)
      SEARCHPATH="${i#*=}"
      shift # past argument=value
      ;;
      -ns=*|--num-servers=*)
      SEARCHPATH="${i#*=}"
      shift # past argument=value
      ;;
      -h|--help)
      SEARCHPATH="${i#*=}"
      ;;
      *)
            # unknown option
      ;;
  esac
  done
}

verify_args ()
{
  echo TODO
}

print_usage ()
{
  cat <<- EOF
    generate.sh Usage (required in <> default in []):

      generate.sh \
         -h|--help \
        -ch|--client-hostname=<hostname> \
        -sh|--server-hostname=<hostname> \
        -ni|--number-intermediates=[1] \
        -nc|--number-clients=1 \
        -ns|--number-servers=1 \

EOF
}

main ()
{
  if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    print_usage
    exit 1
  fi

  parse_args $@
  verify_args

  local server_hostname="${1}"
  local client_hostname="${2}"

  generate_root_ca_key_and_crt "$server_hostname"
  generate_intermediate_ca_key_and_crt "$server_hostname"
  generate_server_key_and_csr "$server_hostname"
  sign_server_crt
  create_server_pem
  generate_client_key_and_csr "$client_hostname"
  sign_client_crt
  create_client_pem
  create_client_pfx       # For Java, C#, etc
}

main $@

