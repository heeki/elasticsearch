#!/bin/bash

# step 0
export PROFILE=local-profile-name
export PROXY_BUCKET=bucket-where-nginx-config-was-uploaded
export VPCID=vpc-abcdefgh
export SUBNETID1=subnet-abcdefgh
export SUBNETID2=subnet-ijklmnop
export CIDR=allowable-ip-range
export EC2_IMAGEID=ami-08f3d892de259504d
export EC2_TYPE=t3.small
export EC2_KEY=ec2-ssh-key-pair
export EBS_CAPACITY=20
export DOMAINNAME=name-for-cognito-and-elasticsearch-domains
export COGNITO_USERNAME=username
export COGNITO_USEREMAIL=username@domain.com

# step 1
export COGNITO_USERTEMPPW=temp-password-emailed-to-email-address
export COGNITO_USERPERMPW=new-permanent-password
export COGNITO_USERPOOL=output-from-cloudformation-OutCognitoUserPool
export COGNITO_CLIENTID=output-from-cloudformation-OutCognitoClientId
