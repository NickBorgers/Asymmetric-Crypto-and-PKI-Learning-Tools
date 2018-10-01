#!/bin/bash

BC_LINE_LENGTH=0

getCharacterFromNumber() {
  [ "$1" -lt 256 ] || return 1
  printf "\\$(printf '%03o' "$1")"
}

getNumberFromCharacter() {
  LC_CTYPE=C printf '%d' "'$1"
}

RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
NC='\033[0m' # No Color

MAGENTA() {
    colorId=13
    activateColor $colorId
}

CYAN() {
    colorId=14
    activateColor $colorId
}

BLUE() {
    colorId=12
    activateColor $colorId
}

YELLOW() {
    colorId=11
    activateColor $colorId
}

RED() {
    colorId=9
    activateColor $colorId
}

GREEN() {
    colorId=10
    activateColor $colorId
}

activateColor() {
    colorId=$1
    printf "$(tput setaf $colorId)"
}

PRINT_HORZIONTAL_LINE() { printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - ; }

PAUSE(){ read -p "$*" ; }

PLAINTEXT_COLOR_CODE=$BLUE
CIPHERTEXT_COLOR_CODE=$GREEN
MODULUS_COLOR_CODE=$MAGENTA
PRIVATE_EXPONENT_COLOR_CODE=$RED
PUBLIC_EXPONENT_COLOR_CODE=$CYAN
NO_COLOR_CODE=$NC

PLAINTEXT_COLOR_COMMAND() { printf $(BLUE); }
CIPHERTEXT_COLOR_COMMAND() { printf $(GREEN); }
MODULUS_COLOR_COMMAND() { printf $(MAGENTA); }
PRIVATE_EXPONENT_COLOR_COMMAND() { printf $(RED); }
PUBLIC_EXPONENT_COLOR_COMMAND() { printf $(CYAN); }
NO_COLOR_COMMAND() { printf $(tput sgr0); }

NUMBER_VALUE_PRINTF_FORMAT='%-50s %5s \n'

openssl genrsa 16 > /tmp/tiny.key 2>/dev/null

publicExponentOfTinyKey=$(openssl rsa -in /tmp/tiny.key -noout -text | grep publicExponent | awk '{print $2}')
privateExponentOfTinyKey=$(openssl rsa -in /tmp/tiny.key -noout -text | grep privateExponent | awk '{print $2}')
modulusOfTinyKey=$(openssl rsa -in /tmp/tiny.key -noout -text | grep modulus | awk '{print $2}')

printf "$NUMBER_VALUE_PRINTF_FORMAT" "$(MODULUS_COLOR_COMMAND)Modulus$(NO_COLOR_COMMAND) is:" "$(MODULUS_COLOR_COMMAND)$modulusOfTinyKey$(NO_COLOR_COMMAND)"

printf "$NUMBER_VALUE_PRINTF_FORMAT" "$(PRIVATE_EXPONENT_COLOR_COMMAND)Private exponent$(NO_COLOR_COMMAND) is:" "$(PRIVATE_EXPONENT_COLOR_COMMAND)$privateExponentOfTinyKey$(NO_COLOR_COMMAND)"

printf "$NUMBER_VALUE_PRINTF_FORMAT" "$(PUBLIC_EXPONENT_COLOR_COMMAND)Public exponent$(NO_COLOR_COMMAND) is:" "$(PUBLIC_EXPONENT_COLOR_COMMAND)$publicExponentOfTinyKey$(NO_COLOR_COMMAND)"

message="G"
messageAsNumber=$(getNumberFromCharacter G)

printf "$NUMBER_VALUE_PRINTF_FORMAT" "Our $(PLAINTEXT_COLOR_COMMAND)plaintext message$(NO_COLOR_COMMAND) is:" "$(PLAINTEXT_COLOR_COMMAND)$message$(NO_COLOR_COMMAND)"

printf "$NUMBER_VALUE_PRINTF_FORMAT" "Which is, as ASCII value:" "$(PLAINTEXT_COLOR_COMMAND)$messageAsNumber$(NO_COLOR_COMMAND)"

PAUSE "Press [Enter] to perform encryption..."

exponentiatedMessage=$(echo $messageAsNumber^$privateExponentOfTinyKey | bc)
encryptedMessage=$(echo $exponentiatedMessage%$modulusOfTinyKey | bc)

printf "\n"

printf "To encrypt this plaintext we perform this arithmetic operation: \n"
printf "  (${PLAINTEXT_COLOR_CODE}plaintext${NC} ^ ${PRIVATE_EXPONENT_COLOR_CODE}privateExponent${NC}) %% ${MODULUS_COLOR_CODE}modulus${NC}\n"
printf "In this case: \n"
printf "  (${PLAINTEXT_COLOR_CODE}$messageAsNumber${NC} ^ ${PRIVATE_EXPONENT_COLOR_CODE}$privateExponentOfTinyKey${NC}) %% ${MODULUS_COLOR_CODE}$modulusOfTinyKey${NC}\n"

printf "With a resulting ${CIPHERTEXT_COLOR_CODE}ciphertext${NC} of: ${CIPHERTEXT_COLOR_CODE}$encryptedMessage${NC}\n"
printf "You can summarize as ${CIPHERTEXT_COLOR_CODE}ciphertext${NC} = RSA.encrypt(${MODULUS_COLOR_CODE}modulus${NC}, ${PRIVATE_EXPONENT_COLOR_CODE}privateExponent${NC}, ${PLAINTEXT_COLOR_CODE}plaintext${NC})\n\n"

PAUSE "Press [Enter] to perform decryption..."

exponentiatedEncryptedMessage=$(echo $encryptedMessage^$publicExponentOfTinyKey | bc)
decryptedMessage=$(echo $exponentiatedEncryptedMessage%$modulusOfTinyKey | bc)

printf "\n"

printf "To decrypt the encrypted message we perform this arithmetic operation:\n"
printf "  (${CIPHERTEXT_COLOR_CODE}ciphertext${NC} ^ ${PUBLIC_EXPONENT_COLOR_CODE}publicExponent${NC}) %% ${MODULUS_COLOR_CODE}modulus${NC}\n"
printf "In this case: \n"
printf "  (${CIPHERTEXT_COLOR_CODE}$encryptedMessage${NC} ^ ${PUBLIC_EXPONENT_COLOR_CODE}$publicExponentOfTinyKey${NC}) %% ${MODULUS_COLOR_CODE}$modulusOfTinyKey${NC}\n"

printf "With a resulting ${PLAINTEXT_COLOR_CODE}decrypted message${NC} of: ${PLAINTEXT_COLOR_CODE}$decryptedMessage${NC}, which of course is our starting message of ${PLAINTEXT_COLOR_CODE}$(getCharacterFromNumber $decryptedMessage)${NC}\n"
printf "You can summarize as ${PLAINTEXT_COLOR_CODE}recovered cleartext${NC} = RSA.decrypt(${MODULUS_COLOR_CODE}modulus${NC}, ${PUBLIC_EXPONENT_COLOR_CODE}publicExponent${NC}, ${CIPHERTEXT_COLOR_CODE}ciphertext${NC})\n"

printf "\n\n"

PAUSE "Press [Enter] to learn more..."

PRINT_HORZIONTAL_LINE

# Size of this RSA key is much too small.
printf "Please note, this example is purely for demonstration and has a number of issues that make it extremely insecure.\n\n"

printf "\"Raw\" RSA is known to be very insecure\n"
PRINT_HORZIONTAL_LINE
printf "The topic of padding is beyond the scope of this demonstration effort, but suffice it to say that using the RSA algorithm directly against the plaintext message has a number of security issues. If you need to perform RSA operations, please use an existing implementation and provide appropriate parameters for padding. For signing, the Probablistic Signature Scheme (PSS) for RSA, RSA-PSS, standardized in PKCS#1 v2.1 should be used. For encryption, encrypt the Data Encryption Key (DEK) with Optimal Asymmetric Encryption Padding (OAEP), standardized in PKCS#1 v2 and RFC 2437.\n\n"

printf "Key size is far too small\n"
PRINT_HORZIONTAL_LINE
printf "For comparison, a strong RSA key would be based on a 3072-bit or larger modulus.\n"
exampleStrongRsaModulus=$(echo 2^3072 | bc)
printf "An appropriately sized, ${MODULUS_COLOR_CODE}3072-bit RSA modulus${NC} is on the scale of: ${MODULUS_COLOR_CODE}$exampleStrongRsaModulus${NC}\n\n"
