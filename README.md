# Deploying Elasticsearch
The provided repository is an amalgamation of my own learnings for deploying a basic Elasticsearch cluster for local testing. The cluster is deployed within a VPC and is accessed via an NGINX reverse proxy. Access to Kibana can optionally be protected using Cognito authentication.

## Step 0
Create a bucket (or use an existing bucket) and upload `iac/nginx.conf` to key `elasticsearch/nginx.conf`.

Copy the `etc/execute_template.sh` file to your own `etc/execute_env.sh` file and update the variables in the step 0 section.

Deploy the CloudFormation templates using the helper scripts as defined below.

```bash
source etc/execute_env.sh
./deploy.sh -p $PROFILE -t iac/elasticsearch.yaml -s elasticsearch -v create
```

The stack will take roughly 15 minutes to create. I've observed the Elasticsearch piece alone takes the majority of the time.

Once the stack is created and the EC2 instance is finished with its initialization, access the Kibana page at https://!{OutProxyPublicDnsName}/_plugin/kibana.


## Step 1 (Optional)
NOTE: This step is only needed if Cognito is going to be enabled.

In the `ElasticsearchDomain` resource, update the `CognitoOptions` property. Set Enabled to true and update to associated additional properties.

```yaml
      CognitoOptions:
        Enabled: true
        IdentityPoolId: !Ref CognitoIdentityPool
        RoleArn: !GetAtt ElasticsearchRole.Arn
        UserPoolId: !Ref CognitoUserPool
```

Execute the update stack script. This will create a new Cognito app client id specific to Elasticsearch.

```bash
./deploy.sh -p $PROFILE -t iac/elasticsearch.yaml -s elasticsearch -v update
```

After the stack is finished updating, we need to add a role attachment setting. In the template, search for the `CognitoIdentityRoleAttachment` resource. Uncomment the `RoleMappings` property and update the first key to comply with the following pattern: `cognito-idp.${AWS::Region}.amazonaws.com/${CognitoUserPool.ProviderName}:${ElasticsearchCognitoClientId}`. Note that the `${ElasticsearchCognitoClientId}` should be the new app client id that was created in the previous stack update.
* CloudFormation -> Resources -> CognitoUserPool -> App clients -> AWSElasticsearch-*
* Copy the app client id
* Update the template to look like the following:

```yaml
      RoleMappings:
        "cognito-idp.us-east-1.amazonaws.com/us-east-1_abcdefgh:abcdefgh1234567890abcdefgh":
          AmbiguousRoleResolution: AuthenticatedRole
          Type: Token
```

Execute the update stack script.

```bash
./deploy.sh -p $PROFILE -t iac/elasticsearch.yaml -s elasticsearch -v update
```

## Step 2 (Optional)
NOTE: This step is only needed if Cognito is going to be enabled.

The Cognito user that we created initially starts with a `FORCE_CHANGE_PASSWORD` status. This step will update the user status to `CONFIRMED`. To do this, set the password for the Cognito user. First we need to update `etc/execute_env.sh` with some new values. An email should have been sent to the configured email address with a temporary password. Update `COGNITO_USERTEMPPW` with that value. Generate a new permanent password that complies with the password requirements and update `COGNITO_USERPERMPW` with that value.

Use the provided helper script documented below to retrieve the outputs from the CloudFormation template.

```bash
./describe.sh -p $PROFILE -s elasticsearch
```

Use those outputs to update the values for `COGNITO_USERPOOL` and `COGNITO_CLIENTID` in `etc/execute_env.sh`.

Execute the cognito password update script. The output should be a JSON message that includes the AccessToken, IdToken, Refreshtoken, etc. 

```bash
source etc/execute_env.sh
./cognito.sh
```

## Troubleshooting Notes (Lessons Learned)
Below are some configuration error messages that I encountered between Cognito and Kibana and the resolution for the issues.

> com.amazonaws.services.cognitoidentity.model.NotAuthorizedException: Identity pool - us-east-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx does not have identity providers configured. (Service: AmazonCognitoIdentity; Status Code: 400; Error Code: NotAuthorizedException; Request ID: 9f6e4cd7–174e-408c-aa7f-842c281839dd)

This is because the identity pool is not configured with the user pool id and app client id.

> com.amazonaws.services.cognitoidentity.model.NotAuthorizedException: Token is not from a supported provider of this identity pool. (Service: AmazonCognitoIdentity; Status Code: 400; Error Code: NotAuthorizedException; Request ID: 9640537a-ddf9–49b6–8a14–6c349822f6f4)

This is because the wrong app client id was entered. The app client created as a resource by the CloudFormation template isn't used. When enabling Cognito for Elasticsearch, the service creates a different app client with the correct settings automatically. The correct app client id is configured by default but I had made manual changes which caused this problem.

> com.amazonaws.services.cognitoidentity.model.InvalidIdentityPoolConfigurationException: Invalid identity pool configuration. Check assigned IAM roles for this pool. (Service: AmazonCognitoIdentity; Status Code: 400; Error Code: InvalidIdentityPoolConfigurationException; Request ID: 8f3792a8-fee9–4c3d-89d1–8ba7b62a6182)

This was resolved by correcting a configuration issue with the trust policy for the authenticated IAM role.