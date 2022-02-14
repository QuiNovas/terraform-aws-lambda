# terraform-aws-lambda

This module creates a Lambda function in AWS, including the required role, log group, and invocation policy (for use in 
other roles)

* [Terraform documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)

## Usage

### simple usage
```hcl
*module "test" {
    dead_letter_arn = "arn:aws:sns:us-east-1:123456789012:test"
    handler         = "function.handler"
    kms_key_arn     = "arn:aws:kms:us-east-1:123456789012:key/c3298b1d-e9cb-4c89-9e41-11fe7fd4576"
    name            =  "test"
    runtime         = "python3.7"
    s3_bucket       = "test-bucket"
    s3_object_key   = "test.zip"
    source          = "QuiNovas/lambda/aws"

    tags            = {
            Terraform = "true"
            Environment = "dev"
  }
    version         = "3.0.12"
}


provider "aws" {
    region = "us-east-1"
}
```

### usage :- triggering aws lambda function from aws api gateway and self invocation
```hcl
resource "aws_api_gateway_rest_api" "test" {
  name = "test"
}

resource "aws_s3_bucket" "test" {
  bucket = "test-bucket"
  acl    = "private"

  tags = {
    Name        = "test"
    Environment = "Dev"
  }
}

resource "aws_kms_key" "test" {
  description         = "Key for test"
  enable_key_rotation = true
}


resource "aws_kinesis_stream" "test" {
  encryption_type  = "KMS"
  kms_key_id       = aws_kms_key.test.key_id
  name             = "test"
  retention_period = 168
  shard_count      = 4
}

data "aws_iam_policy_document" "apigateway_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = [
        "apigateway.amazonaws.com",
      ]

      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "test" {
  statement {
    actions = [
      "s3:PutObject*",
    ]

    resources = [
      "${aws_s3_bucket.test.arn}/*",
    ]

    sid = "AllowPutinBucket"
  }

  statement {
    actions = [
      "firehose:PutRecord*",
    ]

    resources = [
      aws_kinesis_stream.test.arn,
    ]

    sid = "AllowPutRecords"
  }

resource "aws_iam_policy" "test" {
  name   = "test"
  policy = data.aws_iam_policy_document.test.json
}

module "test" {
  dead_letter_arn = "arn:aws:sns:us-east-1:123456789012:test"

  environment_variables = {
    ENVIRONMENT            = "dev"
    LOG_LEVEL              = "INFO"
  }

  handler     = "function.handler"
  kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/c3298b1d-e9cb-4c89-9e41-11fe7fd4576"
  memory_size = 256
  name        = "test"

  policy_arns = [
    aws_iam_policy.test.arn,
  ]


  runtime            = "python3.7"
  s3_bucket          = "test-bucket"
  s3_object_key      = "test.zip"
  source             = "QuiNovas/lambda/aws"
  timeout            = 300
  version            = "3.0.12"
  log_retention_days = 7
}

resource "aws_lambda_permission" "test" {
  action        = "lambda:InvokeFunction"
  function_name = module.test.name
  principal     = "apigateway.amazonaws.com"
  statement_id  = "AllowExecutionFromTESTAPIGateway"
  source_arn    = aws_api_gateway_rest_api.test.execution_arn
}

resource "aws_iam_role" "test_invocation" {
  assume_role_policy = data.aws_iam_policy_document.apigateway_assume_role.json
  name               = "test-invocation"
}

resource "aws_iam_role_policy_attachment" "test_invocation" {
  policy_arn = module.test.invoke_policy_arn
  role       = aws_iam_role.test_invocation.name
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allow\_self\_invocation | If true, allows this Lambda function to invoke itself. Useful for recursive invocations | bool | false | no |
| description | Description of what your Lambda Function does | string | "" | no |
| dead\_letter\_arn | The arn for the SNS topic that handles dead letters | string |  | yes |
| destinations\_on\_failure\_arn | Add destination to function. An ARN of SQS queue, SNS topic, Lambda function, or EventBridge event bus. Added as on_failure aysynchronous invocation | string | "" | no |
| destinations\_on\_success\_arn | Add destination to function. An ARN of SQS queue, SNS topic, Lambda function, or EventBridge event bus. Added as on_success aysynchronous invocation | string | "" | no |
| environment\_variables | The map of environment variables to give to the Lambda function | map(string) | {} | no |
| handler | DesThe handler for the lambda function | string |  | yes |
| kms\_key\_arn | The arn of the KMS key used to encrypt the environment variables | string |  | yes |
| layers | The list of lambda layers to be attached | list(string) | [] | no |
| memory\_size | The memory allocation for the function | number | 128 | no |
| name | The name of the function" | string |  | yes |
| policy\_arns | A list of additional policy arns to attach to the function's role | list(string) | [] | no |
| log\_retention\_days | The number of days you want to retain log events in the specified log group | number | 7 | no |
| provisioned\_concurrency | If true, allows this Lambda function to create alias and manage provisioned_concurrency_config | bool | false | no |
| provisioned\_concurrent\_executions | Amount of capacity to allocate. Must be greater than or equal to 1 | number | 1 | no |
| runtime | The runtime the function should use | string |  | yes |
| s3\_bucket | The name or id of the S3 bucket that contains the function package | string |  | yes |
| s3\_object\_key | The key of the function package in the s3_bucket | string |  | yes |
| timeout | The timeout to apply to the function | number | 3 | no |
| tags | Key-value map of tags | map(any) | {} | no |
| vpc\_config | Provide this to allow your function to access your VPC. Both 'subnet_ids' and 'security_group_ids' are a list of strings are required to enable vpc). | map(list(string)) | {} | no |







## Authors

Module managed by Quinovas (https://github.com/QuiNovas)

## License

Apache License, Version 2.0, January 2004 (http://www.apache.org/licenses/). See LICENSE for full details.