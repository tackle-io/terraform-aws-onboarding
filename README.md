# Tackle AWS Onboarding - Terraform Module

Terraform module for integrating your AWS account with [Tackle's](https://tackle.io) platform, enabling AWS Marketplace and AWS Partner Central operations.

This module deploys Tackle's official CloudFormation template via Terraform's `aws_cloudformation_stack` resource, giving you the benefits of Terraform's workflow (state management, plan/apply, CI/CD integration) while using Tackle's production-tested infrastructure template.

## How It Works

1. Terraform downloads Tackle's [public CloudFormation template](https://tackle-templates.s3.us-west-2.amazonaws.com/integrations/aws-onboarding.yaml)
2. A CloudFormation stack is created with your Tackle-provided parameters
3. CloudFormation provisions all AWS resources, registers with Tackle, and manages the resource lifecycle

### What Gets Created

The CloudFormation template creates ~33 AWS resources including:

- **IAM Role** (TackleRole) with least-privilege permissions for AWS Marketplace and Partner Central
- **Event Processing Pipeline** -- EventBridge rule, SQS queue, EventBridge Pipe, and API destination for routing Marketplace and Partner Central events to Tackle
- **SDDS Infrastructure** -- S3 bucket, SNS topic, and SQS queues for AWS Marketplace Seller Data Delivery Service feeds
- **KMS Encryption Key** -- Customer-managed key (with automatic rotation) encrypting all data at rest
- **Registration Lambda** -- Automated registration with Tackle's platform
- **Heartbeat Scheduler** -- Hourly health check events for pipeline monitoring

## Prerequisites

- AWS account with [Marketplace seller enrollment](https://docs.aws.amazon.com/marketplace/latest/userguide/seller-registration-process.html)
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.14.0
- AWS credentials with permissions to create CloudFormation stacks, IAM roles, and all resource types listed above
- Tackle-provided `external_id` and `registration_token` (obtained from the Tackle Platform during onboarding)

## Region Requirement

This module **must** be deployed in **us-east-1** (N. Virginia). AWS Marketplace and Partner Central services operate in this region. The module includes a validation check that will fail if a different region is configured.

## Usage

### 1. Create your Terraform configuration

```hcl
provider "aws" {
  region = "us-east-1"
}

module "tackle_aws_onboarding" {
  source = "github.com/tackle-io/terraform-aws-onboarding"

  external_id        = var.external_id
  registration_token = var.registration_token
}
```

### 2. Set your variables

Create a `terraform.tfvars` file (**do not commit this to version control**):

```hcl
external_id        = "your-tackle-external-id"
registration_token = "your-tackle-registration-token"
```

Or pass them via the command line:

```bash
terraform apply \
  -var="external_id=your-tackle-external-id" \
  -var="registration_token=your-tackle-registration-token"
```

### 3. Deploy

```bash
terraform init
terraform plan    # Review — should show 1 resource to create
terraform apply
```

Stack creation typically takes 3-5 minutes.

### 4. Verify

After a successful apply, the output `stack_id` confirms the CloudFormation stack was created. You can also verify in the AWS Console under CloudFormation > Stacks.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `external_id` | A hash of a Tackle-internal identifier unique to your company. Provided by Tackle. | `string` | -- | Yes |
| `registration_token` | The token used to complete the registration process. Provided by Tackle. Min 10 characters. | `string` | -- | Yes |
| `stack_name` | Name for the CloudFormation stack. | `string` | `"Tackle-Resources"` | No |
| `tags` | Additional tags to apply to the CloudFormation stack and its resources. | `map(string)` | `{}` | No |

> `external_id` and `registration_token` are marked as sensitive and will not appear in Terraform plan output. Use an encrypted remote state backend to protect them at rest.

## Outputs

| Name | Description |
|------|-------------|
| `stack_id` | The CloudFormation stack ID |
| `stack_outputs` | All outputs exported by the CloudFormation stack |

## Pinning a Version

Use a Git ref to pin to a specific release:

```hcl
module "tackle_aws_onboarding" {
  source = "github.com/tackle-io/terraform-aws-onboarding?ref=v1.0.0"

  external_id        = var.external_id
  registration_token = var.registration_token
}
```

## Updating

When Tackle releases template updates (e.g., for new AWS Marketplace features or security improvements), the changes are picked up automatically since the template is fetched from Tackle's S3 bucket. Run:

```bash
terraform plan    # Review any resource changes
terraform apply   # Apply the update
```

CloudFormation handles updating existing resources and adding new ones.

## Destroying

```bash
terraform destroy
```

CloudFormation deletes all underlying AWS resources in the correct order. Contact [Tackle Support](https://help.tackle.io/en/) after destroying if you need to decommission your integration.

## Troubleshooting

### Stack Creation Failed

Check CloudFormation events for the root cause:

```bash
aws cloudformation describe-stack-events \
  --stack-name Tackle-Resources \
  --region us-east-1 \
  --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`].[LogicalResourceId,ResourceStatusReason]' \
  --output table
```

### Region Error

```
Error: The Tackle stack must be deployed in the us-east-1 (N. Virginia) region
```

Ensure your AWS provider is configured for `us-east-1`:

```hcl
provider "aws" {
  region = "us-east-1"
}
```

### Timeout

The default timeout is 15 minutes. If it times out, the CloudFormation stack may be stuck in `CREATE_IN_PROGRESS`. Check the CloudFormation console or events for the resource causing the delay.

### Permission Errors

The deploying IAM principal needs permissions to:
- Create and manage CloudFormation stacks
- Create IAM roles and policies (`iam:CreateRole`, `iam:PutRolePolicy`, `iam:AttachRolePolicy`, etc.)
- Create KMS keys, S3 buckets, SQS queues, SNS topics, EventBridge resources, and Lambda functions

## Support

- **Tackle Help Center**: https://help.tackle.io/en/
