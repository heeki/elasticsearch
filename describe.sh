#!/bin/bash

while getopts p:s: flag
do
    case "${flag}" in
        p) PROFILE=${OPTARG};;
        s) STACK=${OPTARG};;
    esac
done

function usage {
    echo "describe.sh -p [profile] -s [stack]" && exit 1
}

if [ -z "$PROFILE" ]; then usage; fi
if [ -z "$STACK" ]; then usage; fi

OUTPUT=$(aws --profile $PROFILE cloudformation describe-stacks --stack-name $STACK)
ES_DOMAIN_ARN=$(echo $OUTPUT | jq -r -c '.["Stacks"][]["Outputs"][]  | select(.OutputKey == "OutDomainArn") | .OutputValue')
ES_DOMAIN_ENDPOINT=$(echo $OUTPUT | jq -r -c '.["Stacks"][]["Outputs"][]  | select(.OutputKey == "OutDomainEndpoint") | .OutputValue')
PROXY_DNS=$(echo $OUTPUT | jq -r -c '.["Stacks"][]["Outputs"][]  | select(.OutputKey == "OutProxyPublicDnsName") | .OutputValue')
PROXY_IP=$(echo $OUTPUT | jq -r -c '.["Stacks"][]["Outputs"][]  | select(.OutputKey == "OutProxyPublicIp") | .OutputValue')
COGNITO_USERPOOL=$(echo $OUTPUT | jq -r -c '.["Stacks"][]["Outputs"][]  | select(.OutputKey == "OutCognitoUserPool") | .OutputValue')
COGNITO_IDENTITYPOOL=$(echo $OUTPUT | jq -r -c '.["Stacks"][]["Outputs"][]  | select(.OutputKey == "OutCognitoIdentityPool") | .OutputValue')
COGNITO_PROVIDERNAME=$(echo $OUTPUT | jq -r -c '.["Stacks"][]["Outputs"][]  | select(.OutputKey == "OutCognitoProviderName") | .OutputValue')
COGNITO_PROVIDERURL=$(echo $OUTPUT | jq -r -c '.["Stacks"][]["Outputs"][]  | select(.OutputKey == "OutCognitoProviderUrl") | .OutputValue')
COGNITO_CLIENTID=$(echo $OUTPUT | jq -r -c '.["Stacks"][]["Outputs"][]  | select(.OutputKey == "OutCognitoClientId") | .OutputValue')
for var in {ES_DOMAIN_ARN,ES_DOMAIN_ENDPOINT,PROXY_DNS,PROXY_IP,COGNITO_USERPOOL,COGNITO_IDENTITYPOOL,COGNITO_PROVIDERNAME,COGNITO_PROVIDERURL,COGNITO_CLIENTID}; do echo "$var=${!var}"; done
