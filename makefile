include etc/environment.sh

elasticsearch:
	aws --profile ${PROFILE} cloudformation create-stack --stack-name ${STACK} --template-body file://${TEMPLATE} --parameters file://etc/environment.json --capabilities CAPABILITY_IAM | jq
elasticsearch.update:
	aws --profile ${PROFILE} cloudformation update-stack --stack-name ${STACK} --template-body file://${TEMPLATE} --parameters file://etc/environment.json --capabilities CAPABILITY_IAM | jq
