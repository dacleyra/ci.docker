#!/bin/bash

keystorePath="/config/configDropins/defaults/keystore.xml"
keystorePathP12="/output/resources/security/key.p12"
keystorePathJKS="/output/resources/security/key.jks"
publicCertPath="/etc/wlp/config/keystore/tls.crt"
privateKeyPath="/etc/wlp/config/keystore/tls.key"

if [ -e $publicCertPath ] && [ -e $privateKeyPath ]
then
  #Generate or determine keystore password
  if [ ! -e $keystorePath ]
  then
    PASSWORD=$(openssl rand -base64 32)
    XML="<server description=\"Default Server\"><keyStore id=\"defaultKeyStore\" password=\"$PASSWORD\" /></server>"
    mkdir -p $(dirname $keystorePath)
    echo $XML > $keystorePath
  else
    export PASSWORD=$(grep -oP 'password="\K[^"]*' $keystorePath)
  fi
  
  mkdir -p $(dirname $keystorePathP12)
  openssl pkcs12 -export -in $publicCertPath -inkey $privateKeyPath -out $keystorePathP12 -name defaultServer -passin pass:$PASSWORD -passout pass:$PASSWORD
  keytool -importkeystore -srckeystore $keystorePathP12 -srcstoretype PKCS12 -srcstorepass $PASSWORD -alias defaultServer -deststorepass $PASSWORD -destkeypass $PASSWORD -destkeystore $keystorePathJKS
fi
