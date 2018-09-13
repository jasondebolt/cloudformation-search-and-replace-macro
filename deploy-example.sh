#!/bin/bash
set -e

# Deploys a Macro stack and an S3 Bucket stack which is transformed by the macro.
#
# USAGE
#   ./deploy-example.sh [create | update]

# Check for valid arguments
if [ $# -ne 1 ]
  then
    echo "Incorrect number of arguments supplied. Pass in either 'create' or 'update'."
    exit 1
fi

# Convert create/update to uppercase
OP=$(echo $1 | tr '/a-z/' '/A-Z/')

PROJECT_NAME='enter-lowercase-project-name-here'
LAMBDA_BUCKET_NAME=$PROJECT_NAME-lambda
MACRO_STACK_NAME=$PROJECT_NAME-macro
S3_STACK_NAME=$PROJECT_NAME-s3-bucket
VERSION_ID=all`date '+%Y-%m-%d-%H%M%S'`
CHANGE_SET_NAME=$VERSION_ID

aws s3 mb s3://$LAMBDA_BUCKET_NAME

# Upload the Python Lambda functions
listOfPythonLambdaFunctions='macro'
for functionName in $listOfPythonLambdaFunctions
do
  mkdir -p builds/$functionName
  cp -rf lambda/$functionName/* builds/$functionName/
  cd builds/$functionName/
  pip install -r requirements.txt -t .
  zip -r lambda_function.zip ./*
  aws s3 cp lambda_function.zip s3://$LAMBDA_BUCKET_NAME/$VERSION_ID/$functionName/
  cd ../../
  rm -rf builds
done

# Validate the CloudFormation template before template execution.
aws cloudformation validate-template --template-body file://template-macro.json

aws cloudformation $1-stack \
    --stack-name $MACRO_STACK_NAME \
    --template-body file://template-macro.json \
    --capabilities CAPABILITY_IAM \
    --parameters ParameterKey=ProjectName,ParameterValue=$PROJECT_NAME \
                 ParameterKey=LambdaBucketName,ParameterValue=$LAMBDA_BUCKET_NAME \
                 ParameterKey=Version,ParameterValue=$VERSION_ID

aws cloudformation wait stack-$1-complete --stack-name $MACRO_STACK_NAME

# Validate the CloudFormation template before template execution.
aws cloudformation validate-template --template-body file://template-s3-bucket.json

aws cloudformation create-change-set --stack-name $S3_STACK_NAME \
    --change-set-name $CHANGE_SET_NAME \
    --template-body file://template-s3-bucket.json \
    --change-set-type $OP

aws cloudformation wait change-set-create-complete \
    --change-set-name $CHANGE_SET_NAME --stack-name $S3_STACK_NAME

# Let's automatically execute the change-set
aws cloudformation execute-change-set --stack-name $S3_STACK_NAME \
    --change-set-name $CHANGE_SET_NAME

aws cloudformation wait stack-$1-complete --stack-name $S3_STACK_NAME
