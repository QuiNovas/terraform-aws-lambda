variable "allow_self_invocation" {
  default     = false
  description = "If true, allows this Lambda function to invoke itself. Useful for recursive invocations"
  type        = bool
}

variable "aws_efs_file_system_id" {
  description = "required if using file_system_config.The ID of the file system for which the mount target is intended."
  type        = string
  default     = ""
}

variable "aws_subnet" {
  description = "required if using file_system_config.The ID of the subnet to add the mount target in."
  type        = string

  validation {
    condition = (
      var.aws_subnet == "" ||
      substr(var.aws_subnet, 0, 7) == "subnet-"
    )
    error_message = "The aws_subnet value should either start with \"subnet-\" or \"\"."
  }
  default = ""
}

variable "description" {
  default     = ""
  description = "Description of what your Lambda Function does"
  type        = string
}

variable "dead_letter_arn" {
  description = "The arn for the SNS topic that handles dead letters"
  type        = string
}

variable "destinations_on_failure_arn" {
  description = "Add destination to function. An ARN of SQS queue, SNS topic, Lambda function, or EventBridge event bus. Added as on_failure aysynchronous invocation"
  type        = string
  default     = ""
}

variable "destinations_on_success_arn" {
  description = "Add destination to function. An ARN of SQS queue, SNS topic, Lambda function, or EventBridge event bus. Added as on_success aysynchronous invocation"
  type        = string
  default     = ""
}

variable "environment_variables" {
  default = {
    DEFAULT = "default"
  }
  description = "The map of environment variables to give to the Lambda function"
  type        = map(string)
}

variable "handler" {
  description = "The handler for the lambda function"
  type        = string
}

variable "kms_key_arn" {
  description = "The arn of the KMS key used to encrypt the environment variables"
  type        = string
}

variable "file_system_config" {
  description = "it contains  ARN of the Amazon EFS Access Point that provides access to the file system.and The path where the function can access the file system, starting with /mnt/."
  type = object({
    arn              = string
    local_mount_path = string
  })
  default = null
}

variable "file_system_ip_address" {
  default     = ""
  description = "(optional) The address (within the address range of the specified subnet) at which the file system may be mounted via the mount target."
  type        = string
}

variable "file_system_security_groups" {
  default     = []
  description = "(optional) A list of up to 5 VPC security group IDs (that must be for the same VPC as subnet specified) in effect for the mount target."
  type        = list(string)
}

variable "layers" {
  default     = []
  description = "The list of lambda layers to be attached"
  type        = list(string)
}

variable "memory_size" {
  default     = 128
  description = "The memory allocation for the function"
  type        = number
}

variable "name" {
  description = "The name of the function"
  type        = string
}

variable "policy_arns" {
  default     = []
  description = "A list of additional policy arns to attach to the function's role"
  type        = list(string)
}

variable "reserved_concurrent_executions" {
  default     = -1
  description = "The amount of reserved concurrent executions for this lambda function."
  type        = number
}

variable "log_retention_days" {
  default     = 7
  description = "The number of days you want to retain log events in the specified log group"
  type        = number
}


variable "runtime" {
  description = "The runtime the function should use"
  type        = string
}

variable "s3_bucket" {
  description = "The name or id of the S3 bucket that contains the function package"
  type        = string
}

variable "s3_object_key" {
  description = "The key of the function package in the s3_bucket"
  type        = string
}

variable "timeout" {
  default     = 3
  description = "The timeout to apply to the function"
  type        = number
}

variable "tracing_config" {
  description = "Can be either PassThrough or Active."
  type = object({
    mode = string
  })
  default = null
}

variable "vpc_config" {
  description = "Provide this to allow your function to access your VPC. Both 'subnet_ids' and 'security_group_ids' are a list of strings are required to enable vpc)."
  type        = map(list(string))
  default     = {}
}