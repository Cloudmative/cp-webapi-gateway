#!/bin/bash

echo "$CLDMTV_CERT_PUBLIC" > combined.pem
echo "$CLDMTV_CERT_PRIVATE" >> combined.pem
openssl pkcs12 -export -in combined.pem -out cert.p12 -passout pass:mypass
keytool -importkeystore -srckeystore cert.p12 -srcstoretype pkcs12 -destkeystore cldmtv-trade-gateway.jks -storepass mypass -srcstorepass mypass
