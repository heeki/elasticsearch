#!/bin/bash

OUTPUT1=`aws --profile $PROFILE cognito-idp admin-initiate-auth \
--user-pool-id $COGNITO_USERPOOL \
--client-id $COGNITO_CLIENTID \
--auth-flow ADMIN_NO_SRP_AUTH \
--auth-parameters USERNAME=${COGNITO_USERNAME},PASSWORD=${COGNITO_USERTEMPPW}`
export COGNITO_SESSION=`echo $OUTPUT1 | jq -r ".Session"`

OUTPUT2=`aws --profile $PROFILE cognito-idp admin-respond-to-auth-challenge \
--user-pool-id $COGNITO_USERPOOL \
--client-id $COGNITO_CLIENTID \
--challenge-name NEW_PASSWORD_REQUIRED \
--challenge-responses USERNAME=$COGNITO_USERNAME,NEW_PASSWORD=$COGNITO_USERPERMPW \
--session $COGNITO_SESSION`

OUTPUT3=`aws --profile $PROFILE cognito-idp initiate-auth \
--client-id $COGNITO_CLIENTID \
--auth-flow USER_PASSWORD_AUTH \
--auth-parameters USERNAME=${COGNITO_USERNAME},PASSWORD=${COGNITO_USERPERMPW}`

echo $OUTPUT3