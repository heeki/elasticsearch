# Deploying Elasticsearch
The provided repository is an amalgamation of my own learnings for deploying a basic Elasticsearch cluster for local testing.
The cluster is deployed within a VPC and is accessed via an NGINX reverse proxy. Access to Kibana is also protected using
Cognito authentication.


## Step 0
Create a bucket (or use an existing bucket) and upload `iac/nginx.conf` to key `elasticsearch/nginx.conf`.

Copy the `etc/execute_template.sh` file to your own `etc/execute_env.sh` file and update the variables in the step 0 section.

Deploy the CloudFormation templates using the helper scripts as defined below.

```bash
source etc/execute_env.sh
./deploy.sh -p $PROFILE -t iac/elasticsearch.yaml -s elasticsearch -v create
```

Sit back and take a breather. The stack will take roughly 15 minutes to create. I've observed the Elasticsearch piece alone takes the majority of the time.

After the stack is initially deployed, we need to make one update to the stack. In the template, search for the `CognitoIdentityRoleAttachment` resource. Uncomment the `RoleMappings` property and update the first key to comply with the following pattern: `cognito-idp.${AWS::Region}.amazonaws.com/${CognitoUserPool.ProviderName}:${ElasticsearchCognitoClientId}`.
* CloudFormation -> Resources -> CognitoUserPool -> App clients -> AWSElasticsearch-*
* Copy the app client id
* Update the template to look like the following:

```yaml
      RoleMappings:
        "cognito-idp.us-east-1.amazonaws.com/us-east-1_abcdefgh:abcdefgh1234567890abcdefgh":
          AmbiguousRoleResolution: AuthenticatedRole
          Type: Token
```

Save the updated template and execute the helper script to deploy the update.

```bash
./deploy.sh -p $PROFILE -t iac/elasticsearch.yaml -s elasticsearch -v update
```

## Step 1
Set the password for the Cognito user. To do this, first we need to update `etc/execute_env.sh` with some new values.

Now that the Cognito user pool and user has been created, an email should have been sent with a temporary password. Update `COGNITO_USERTEMPPW` with that value. Generate a new permanent password that complies with the password requirements and update `COGNITO_USERPERMPW` with that value.

Use the provided helper script documented below to retrieve the outputs from the CloudFormation template.

```bash
./describe.sh -p 1527 -s elasticsearch
```

Use those outputs to update the values for `COGNITO_USERPOOL` and `COGNITO_CLIENTID` in `etc/execute_env.sh`.

Now we will update the user that we created from status `FORCE_CHANGE_PASSWORD` to `CONFIRMED`. The output should be a JSON message that includes the AccessToken, IdToken, Refreshtoken, etc. 

```bash
source etc/execute_env.sh
./cognito.sh
```

## Step 2
Access the Kibana page by accessing https://!{OutProxyPublicDnsName}/_plugin/kibana. Login with the Cognito user name and the permanent password that you set.


## Troubleshooting Notes (Lessons Learned)
Below are some configuration error messages that I encountered between Cognito and Kibana and the resolution for the issues.

> com.amazonaws.services.cognitoidentity.model.NotAuthorizedException: Identity pool - us-east-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx does not have identity providers configured. (Service: AmazonCognitoIdentity; Status Code: 400; Error Code: NotAuthorizedException; Request ID: 9f6e4cd7–174e-408c-aa7f-842c281839dd)

This is because the identity pool is not configured with the user pool id and app client id.

> com.amazonaws.services.cognitoidentity.model.NotAuthorizedException: Token is not from a supported provider of this identity pool. (Service: AmazonCognitoIdentity; Status Code: 400; Error Code: NotAuthorizedException; Request ID: 9640537a-ddf9–49b6–8a14–6c349822f6f4)

This is because the wrong app client id was entered. The app client created as a resource by the CloudFormation template isn't used. When enabling Cognito for Elasticsearch, the service creates a different app client with the correct settings automatically. The correct app client id is configured by default but I had made manual changes which caused this problem.

> com.amazonaws.services.cognitoidentity.model.InvalidIdentityPoolConfigurationException: Invalid identity pool configuration. Check assigned IAM roles for this pool. (Service: AmazonCognitoIdentity; Status Code: 400; Error Code: InvalidIdentityPoolConfigurationException; Request ID: 8f3792a8-fee9–4c3d-89d1–8ba7b62a6182)

This was resolved by correcting a configuration issue with the trust policy for the authenticated IAM role.