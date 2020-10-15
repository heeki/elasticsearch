include etc/execute_env.sh

cloudformation:
	aws --profile ${PROFILE} cloudformation create-stack --stack-name ${STACK} --template-body file://${TEMPLATE} --parameters file://etc/execute_env.json --capabilities CAPABILITY_IAM | jq

cloudformation.update:
	aws --profile ${PROFILE} cloudformation update-stack --stack-name ${STACK} --template-body file://${TEMPLATE} --parameters file://etc/execute_env.json --capabilities CAPABILITY_IAM | jq
