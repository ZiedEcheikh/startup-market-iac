# Startup Market IAC
Market IAC is infrastructure as a code for public market that automatically scale up and down and run in a highly available configuration for mobile and web application.


## AWS Resources
* Amazon API Gateway : Sales RestApi with OpenAPI Specification
* AWS Lambda : Function to deploy futurs of startup-market-lambda-functions:0.1.0
* Amazon DynamoDB : table for sales data
* Amazon S3 : Bucket to store and share poster of sales
* Amazon CloudWatch : 2 logs streams for sales Api Gatewy and sales lambda function
* IAM policies : Specifies permissions to the resources

## Building from Source
### Prerequisites
Git, python3.11 and terraform >=1.5.0

### Check out sources
```
$ git@github.com:ZiedEcheikh/startup-market-iac-serverless.git
```

### Create python virtual environment
```
$ python3 -m venv .venv
```

### Activate virtual environment

On Unix or MacOS, using the bash shell:

```
$ source .venv/bin/activate
```

On Windows using the Command Prompt:
```
$ \.venv\Scripts\activate.bat
```

### Install packages
```
$ pip3 install -r requirements.txt
```

### Install the git hook scripts
```
$ pre-commit install
```

### Run against all the files
```
$ pre-commit run --all-files
```
