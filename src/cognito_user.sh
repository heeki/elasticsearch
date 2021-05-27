#!/bin/bash
source etc/environment.sh

OUTPUT3=`aws --profile $PROFILE cognito-idp initiate-auth \
--client-id $COGNITO_CLIENTID \
--auth-flow USER_PASSWORD_AUTH \
--auth-parameters USERNAME=${COGNITO_USERNAME},PASSWORD=${COGNITO_USERPERMPW}`

echo $OUTPUT3 | jq