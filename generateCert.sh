#!/bin/bash

domain=$(uname -n)

if [[ "$CLDMTV_DOMAIN" != "" ]]; then
    domain="$CLDMTV_DOMAIN"
fi

# Generate a keystore.
keytool -genkey -alias cldmtv-trade-gateway -storepass mypass -keystore cldmtv-trade-gateway.jks \
    -keypass mypass -keyalg RSA -sigalg SHA1withRSA -dname "CN=$domain, OU=, O=Cloudmative, L=BERN, S=BE, C=CH"
# Generate a certificate and CSR for the keystore. CN should match the hostname of presto-coordinator
keytool -export -alias cldmtv-trade-gateway -storepass mypass -keystore cldmtv-trade-gateway.jks \
    -file cldmtv-trade-gateway.cer && \
    keytool -certreq -alias cldmtv-trade-gateway -storepass mypass -keystore cldmtv-trade-gateway.jks \
    -file cldmtv-trade-gateway.csr
