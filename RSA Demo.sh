#!/bin/bash

BC_LINE_LENGTH=0

chr() {
  [ "$1" -lt 256 ] || return 1
  printf "\\$(printf '%03o' "$1")"
}

ord() {
  LC_CTYPE=C printf '%d' "'$1"
}

openssl genrsa 16 > /tmp/tiny.key 2>/dev/null

publicExponentOfTinyKey=$(openssl rsa -in /tmp/tiny.key -noout -text | grep publicExponent | awk '{print $2}')
privateExponentOfTinyKey=$(openssl rsa -in /tmp/tiny.key -noout -text | grep privateExponent | awk '{print $2}')
modulusOfTinyKey=$(openssl rsa -in /tmp/tiny.key -noout -text | grep modulus | awk '{print $2}')

echo "modulus is:               $modulusOfTinyKey"
echo "Private Exponent is:      $privateExponentOfTinyKey"
echo "Public Exponent is:       $publicExponentOfTinyKey"

message="G"
messageAsNumber=$(ord G)

echo "Our message will be:      $message"
echo "Which is, as ASCII value: $messageAsNumber"

exponentiatedMessage=$(echo $messageAsNumber^$privateExponentOfTinyKey | bc)
encryptedMessage=$(echo $exponentiatedMessage%$modulusOfTinyKey | bc)

echo ""

echo "To encrypt this message we perform this arithmetic operation: "
echo "  (message ^ privateExponentOfTinyKey) % modulusOfTinyKey"
echo "In this case: "
echo "  ($messageAsNumber ^ $privateExponentOfTinyKey) % $modulusOfTinyKey"

echo "With a resulting ciphertext of: $encryptedMessage"

exponentiatedEncryptedMessage=$(echo $encryptedMessage^$publicExponentOfTinyKey | bc)
decryptedMessage=$(echo $exponentiatedEncryptedMessage%$modulusOfTinyKey | bc)

echo ""

echo "To decrypt the encrypted message we perform this arithmetic operation:"
echo "  (encryptedMessage ^ publicExponent) % modulus"
echo "In this case: "
echo "  ($encryptedMessage ^ $publicExponentOfTinyKey) % $modulusOfTinyKey"

echo "With a resulting decrypted message of: $decryptedMessage"

echo ""

echo "For comparison, a reasonably strong RSA key would a 2048-bit or larger modulus."
exampleStrongRsaModulus=$(echo 2^2048 | bc)
echo "An appropriately sized, 2048-bit RSA modulus is approximately: $exampleStrongRsaModulus"
