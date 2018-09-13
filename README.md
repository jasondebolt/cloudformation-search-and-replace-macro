# cloudformation-search-and-replace-macro
A recursive search and replace CloudFormation macro that works for both keys and values.

## Caveats
- This macro hasn't been well tested and shouldn't be used in production.
- Used for demo purposes only.

## What does this project do?
- Demonstrates using CloudFormation macros to recursively search and replace values in a CloudFormation template.
- Dynamically changes both the logical ID and name of an S3 bucket using a Lambda Macro.
- See template-s3-bucket.json for search values of PHX_MACRO_RANDOM_7 and PHX_MACRO_PROJECT_NAME.
- See /lambda/macros/lambda_function.py for replacement values.

## Requirements
- Make sure you have python3.6 and pip installed.

## Running the stacks
- Set the PROJECT_NAME variable using all lowercase letters within deploy-example.sh to a unique name.
- This unique project name will be used to create an S3 bucket, so all lowercase characters are required.
- Generate the stacks.
```
./deploy-example.sh create
or
./deploy-example.sh update
```

## Viewing results
- Open the CloudFormation console (https://console.aws.amazon.com/cloudformation)
- Click on the s3 bucket stack that was created.
- Click on the Template tab.
- Click View original template.
- Take note of the PHX_MACRO_RANDOM_7 and PHX_MACRO_PROJECT_NAME values in the unprocessed template.
- Click View processed template.
- Notice that both the PHX_MACRO_RANDOM_7 and PHX_MACRO_PROJECT_NAME values were replaced by new values.
