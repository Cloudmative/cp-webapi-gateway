#!/bin/bash

if [[ "$GATEWAY_IP" == "" ]]; then
    GATEWAY_IP="localhost"
fi

CURL_ARGS="-sf"

# prolong current session (since calling the other endpoints does not seem to do this)
curl -ksfm5 https://$GATEWAY_IP:5000/v1/api/tickle > /dev/null

# check if already logged in
authenticated=$(curl -ksfm5 https://$GATEWAY_IP:5000/v1/api/iserver/auth/status | jq -r '.authenticated')
if [[ "$authenticated" == "true" ]]; then
    echo $(date) " Already logged in"
    exit 0
elif [[ "$authenticated" == "false" ]]; then
    echo $(date) "Reauthenticate"
    triggered=$(curl -ksfm5 https://$GATEWAY_IP:5000/v1/api/iserver/reauthenticate | jq -r '.message')
    if [[ "$triggered" != "triggered" ]]; then
        echo $(date) " Reauth failed"
        exit 1
    fi
    authenticated=$(curl -ksfm5 https://$GATEWAY_IP:5000/v1/api/iserver/auth/status | jq -r '.authenticated')
    if [[ "$authenticated" == "true" ]]; then
        echo $(date) " Reauth successful"
        exit 0
    fi
    echo $(date) " Reauth unsuccessful"
fi
echo $(date) " Login expired, logging back in"

ready=$(curl $CURL_ARGS http://localhost:4444/status | jq '.value.ready')

if [[ "$ready" != "true" ]]; then
    echo $(date) " Error: webdriver not available"
    exit 1
fi

sessionId=$(curl $CURL_ARGS http://localhost:4444/session -X POST -H "Content-Type: application/json" -d '{"capabilities":{"alwaysMatch":{"acceptInsecureCerts":true}}}' | jq -r '.value.sessionId') 
#echo $sessionId
trap "curl $CURL_ARGS http://localhost:4444/session/$sessionId -X DELETE -H 'Content-Type: application/json' -d '{}' > /dev/null" EXIT

curl $CURL_ARGS http://localhost:4444/session/$sessionId/url -X POST -H "Content-Type: application/json" -d "{\"url\":\"https://$GATEWAY_IP:5000/\"}" > /dev/null

nameElementId=$(curl $CURL_ARGS http://localhost:4444/session/$sessionId/element -X POST -H "Content-Type: application/json" -d '{"using":"css selector","value":"#user_name"}' | jq -r '.value[]')

curl $CURL_ARGS http://localhost:4444/session/$sessionId/element/$nameElementId/value -X POST -H "Content-Type: application/json" -d "{\"text\": \"$USERNAME\"}" > /dev/null

pwElementId=$(curl $CURL_ARGS http://localhost:4444/session/$sessionId/element -X POST -H "Content-Type: application/json" -d '{"using":"css selector","value":"#password"}' | jq -r '.value[]')

curl $CURL_ARGS http://localhost:4444/session/$sessionId/element/$pwElementId/value -X POST -H "Content-Type: application/json" -d "{\"text\": \"${PASSWORD}\n\"}" > /dev/null

sleep 50

# debug
#curl $CURL_ARGS http://localhost:4444/session/$sessionId/screenshot | jq -r '.value' | base64 -d > image2.png

# check for 2fa

# check if login successful
authenticated=$(curl -ksfm5 https://$GATEWAY_IP:5000/v1/api/iserver/auth/status | jq -r '.authenticated')
if [[ "$authenticated" == "true" ]]; then
    echo $(date) " Login succeeded"
else
    echo $(date) " Login failed"
    exit 1
fi
