#!/bin/bash

chr() {
  [ "$1" -lt 256 ] || return 1
  printf "\\$(printf '%03o' "$1")"
}

ord() {
  LC_CTYPE=C printf '%d' "'$1"
}

openssl genrsa 16 > /tmp/tiny.key

publicExponent=$(openssl rsa -in /tmp/tiny.key -noout -text | grep publicExponent | awk '{print $2}')
privateExponent=$(openssl rsa -in /tmp/tiny.key -noout -text | grep privateExponent | awk '{print $2}')
modulus=$(openssl rsa -in /tmp/tiny.key -noout -text | grep modulus | awk '{print $2}')

echo "Modulus is:            " + $modulus
echo "Private Exponent is:   " + $privateExponent
echo "Public Exponent is:    " + $publicExponent