#!/bin/bash

while getopts p:t:s:v: flag
do
    case "${flag}" in
        p) PROFILE=${OPTARG};;
        t) TEMPLATE=${OPTARG};;
        s) STACK=${OPTARG};;
        v) VERB=${OPTARG};;
    esac
done

function usage {
    echo "deploy.sh -p [profile] -t [template_file] -s [stack_name] -v [create|update]" && exit 1
}

if [ -z "$PROFILE" ]; then usage; fi
if [ -z "$TEMPLATE" ]; then usage; fi
if [ -z "$STACK" ]; then usage; fi
if [ -z "$VERB" ]; then usage; fi

PARAMS="ParameterKey=ParamBucket,ParameterValue=$PROXY_BUCKET"
PARAMS="$PARAMS ParameterKey=ParamVpcId,ParameterValue=$VPCID"
PARAMS="$PARAMS ParameterKey=ParamSubnetIds,ParameterValue=\"$SUBNETID1\""
PARAMS="$PARAMS ParameterKey=ParamCidr,ParameterValue=$CIDR"
PARAMS="$PARAMS ParameterKey=ParamZoneId,ParameterValue=$ZONEID"
PARAMS="$PARAMS ParameterKey=ParamEC2Image,ParameterValue=$EC2_IMAGEID"
PARAMS="$PARAMS ParameterKey=ParamEC2Type,ParameterValue=$EC2_TYPE"
PARAMS="$PARAMS ParameterKey=ParamEC2Key,ParameterValue=$EC2_KEY"
PARAMS="$PARAMS ParameterKey=ParamEBSCapacity,ParameterValue=$EBS_CAPACITY"
PARAMS="$PARAMS ParameterKey=ParamDomainName,ParameterValue=$DOMAINNAME"
PARAMS="$PARAMS ParameterKey=ParamCognitoUserName,ParameterValue=$COGNITO_USERNAME"
PARAMS="$PARAMS ParameterKey=ParamCognitoUserEmail,ParameterValue=$COGNITO_USEREMAIL"
PARAMS="$PARAMS ParameterKey=ParamFnSG,ParameterValue=$FN_SG"
# PARAMS="$PARAMS ParameterKey=ParamESUserArn,ParameterValue=$ES_USERARN"

aws --profile $PROFILE cloudformation ${VERB}-stack \
--stack-name $STACK \
--template-body file://$TEMPLATE \
--parameters $PARAMS \
--capabilities CAPABILITY_IAM
