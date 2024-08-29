#!/bin/bash
#
# This simple program can be used to reproduce the DSpace REST API bug that was
# reported in Github issue https://github.com/DSpace/DSpace/issues/9781
# Run this program twice to trigger the error. If the error does not occur,
# run the program two more times.
# The error described in Github issue 9781 (usually) occurs in the second run.
#
# Author: Sascha Szott, 2024-08-29

DS_API_URL="https://demo.dspace.org/server/api"
# make sure that "special" characters are percent-encoded
USERNAME="dspacedemo%2Badmin%40gmail.com"
PASSWORD="dspace"

MAX_NUM_OF_STATUS_REQUESTS=20

# get a valid CSRF token
CSRF_TOKEN=$(curl -s -v -X POST "${DS_API_URL}/authn/login" 2>&1 | grep -i "< dspace-xsrf-token:" | awk '{print $3}' | tr -d '\r' | tr -d '\n')
echo "CSRF token: $CSRF_TOKEN"

# log in with valid CSRF token
JWT=$(curl -s -v -X POST --cookie "DSPACE-XSRF-COOKIE=${CSRF_TOKEN}" -H "X-Xsrf-Token:${CSRF_TOKEN}" -d "user=${USERNAME}&password=${PASSWORD}" "${DS_API_URL}/authn/login" 2>&1 | grep -i "< authorization: bearer" | awk '{print $4}' | tr -d '\r' | tr -d '\n')
echo "JWT token: $JWT"

sleep 5

REQ_CNT=0
while true
do
  # get authentication status
  AUTHENTICATED=$(curl -s -v -H "Authorization: Bearer ${JWT}" -H "X-Xsrf-Token: ${CSRF_TOKEN}" "${DS_API_URL}/authn/status" 2>&1 | grep -i "authenticated" | awk '{print $3}' | tr -d ',')
  if [ "$AUTHENTICATED" = "false" ]; then
      echo "F"
      echo "Failure occurred - GET /api/authn/status returned \"authenticated\": false"
      exit 1
  else
    echo -n "T"
  fi
  REQ_CNT=$((REQ_CNT+1))
  if [[ "$REQ_CNT" -gt "$MAX_NUM_OF_STATUS_REQUESTS" ]]; then
    echo ""
    echo "No failures detected so far - log out"
    LOGOUT=$(curl -s -v -X POST --cookie "DSPACE-XSRF-COOKIE=${CSRF_TOKEN}" -H "Authorization: Bearer ${JWT}" -H "X-Xsrf-Token: ${CSRF_TOKEN}" "${DS_API_URL}/authn/logout" 2>&1 | grep "< HTTP/" | awk '{print $3}')
    echo "logout response code: $LOGOUT"
    exit 1
  fi
done
