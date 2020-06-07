#!/bin/bash

if [[ "$GATEWAY_IP" == "" ]]; then
    GATEWAY_IP="localhost"
fi

# check if already logged in
authenticated=$(curl -ksfm5 https://localhost:5000/v1/portal/iserver/auth/status | jq -r '.authenticated')
if [[ "$authenticated" == "true" ]]; then
    echo $(date) " Already logged in"
    exit 0
fi
echo $(date) " Login expired, logging back in"

ready=$(curl -sf http://localhost:4444/status | jq '.value.ready')
#echo $ready

if [[ "$ready" != "true" ]]; then
    echo $(date) " Error: webdriver not available"
    exit 1
fi

sessionId=$(curl -sf http://localhost:4444/session -X POST -H "Content-Type: application/json" -d '{"capabilities":{"alwaysMatch":{"acceptInsecureCerts":true}}}' | jq -r '.value.sessionId') 
#echo $sessionId
trap "curl -sf http://localhost:4444/session/$sessionId -X DELETE -H 'Content-Type: application/json' -d '{}' > /dev/null" EXIT

curl -sf http://localhost:4444/session/$sessionId/url -X POST -H "Content-Type: application/json" -d "{\"url\":\"https://$GATEWAY_IP:5000/\"}" > /dev/null

nameElementId=$(curl -sf http://localhost:4444/session/$sessionId/element -X POST -H "Content-Type: application/json" -d '{"using":"css selector","value":"#user_name"}' | jq -r '.value[]')

curl -sf http://localhost:4444/session/$sessionId/element/$nameElementId/value -X POST -H "Content-Type: application/json" -d "{\"text\": \"$USERNAME\"}" > /dev/null

pwElementId=$(curl -sf http://localhost:4444/session/$sessionId/element -X POST -H "Content-Type: application/json" -d '{"using":"css selector","value":"#password"}' | jq -r '.value[]')

curl -sf http://localhost:4444/session/$sessionId/element/$pwElementId/value -X POST -H "Content-Type: application/json" -d "{\"text\": \"${PASSWORD}\n\"}" > /dev/null

sleep 50

# debug
#curl -sf http://localhost:4444/session/$sessionId/screenshot | jq -r '.value' | base64 -d > image2.png

# check for 2fa

# check if login successful
authenticated=$(curl -ksfm5 https://localhost:5000/v1/portal/iserver/auth/status | jq -r '.authenticated')
if [[ "$authenticated" == "true" ]]; then
    echo $(date) " Login succeeded"
else
    echo $(date) " Login failed"
fi
