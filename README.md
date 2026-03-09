# Tackle AWS Onboarding - Terraform Module

[![CI](https://github.com/tackle-io/terraform-aws-onboarding/actions/workflows/ci.yml/badge.svg)](https://github.com/tackle-io/terraform-aws-onboarding/actions/workflows/ci.yml)

Terraform module for integrating your AWS account with
[Tackle's](https://tackle.io) platform, enabling AWS Marketplace and AWS Partner
Central operations.

This module deploys Tackle's official CloudFormation template via Terraform's
`aws_cloudformation_stack` resource, giving you the benefits of Terraform's
workflow (state management, plan/apply, CI/CD integration) while using Tackle's
production-tested infrastructure template.

## How It Works

1. Terraform downloads Tackle's
   [public CloudFormation template](https://tackle-templates.s3.us-west-2.amazonaws.com/integrations/aws-onboarding.yaml)
2. A CloudFormation stack is created with your Tackle-provided parameters
3. CloudFormation provisions all AWS resources, registers with Tackle, and
   manages the resource lifecycle

### What Gets Created

The CloudFormation template creates ~33 AWS resources including:

- **IAM Role** (TackleRole) with least-privilege permissions for AWS Marketplace
  and Partner Central
- **Event Processing Pipeline** -- EventBridge rule, SQS queue, EventBridge
  Pipe, and API destination for routing Marketplace and Partner Central events
  to Tackle
- **SDDS Infrastructure** -- S3 bucket, SNS topic, and SQS queues for AWS
  Marketplace Seller Data Delivery Service feeds
- **KMS Encryption Key** -- Customer-managed key (with automatic rotation)
  encrypting all data at rest
- **Registration Lambda** -- Automated registration with Tackle's platform
- **Heartbeat Scheduler** -- Hourly health check events for pipeline monitoring

## Prerequisites

- AWS account with
  [Marketplace seller enrollment](https://docs.aws.amazon.com/marketplace/latest/userguide/seller-registration-process.html)
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.14.0
- AWS credentials with permissions to create CloudFormation stacks, IAM roles,
  and all resource types listed above
- Tackle-provided `external_id` and `registration_token` (obtained from the
  Tackle Platform during onboarding)

## Region Requirement

This module **must** be deployed in **us-east-1** (N. Virginia). AWS Marketplace
and Partner Central services operate in this region. The module includes a
validation check that will fail if a different region is configured.

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

After a successful apply, the output `stack_id` confirms the CloudFormation
stack was created. You can also verify in the AWS Console under CloudFormation >
Stacks.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudformation_stack.tackle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) | resource |
| [terraform_data.region_check](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_external_id"></a> [external\_id](#input\_external\_id) | A hash of a Tackle-internal identifier unique to your company. Provided by Tackle. | `string` | n/a | yes |
| <a name="input_registration_token"></a> [registration\_token](#input\_registration\_token) | The token used to complete the registration process. Provided by Tackle. | `string` | n/a | yes |
| <a name="input_stack_name"></a> [stack\_name](#input\_stack\_name) | Name for the CloudFormation stack. | `string` | `"Tackle-Resources"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to the CloudFormation stack and its resources. | `map(string)` | `{}` | no |
| <a name="input_template_version"></a> [template\_version](#input\_template\_version) | Bump this (or upgrade the module to a new release that bumps the default) to force a CloudFormation stack update. When changed, Terraform runs UpdateStack and CloudFormation re-fetches the template from the URL, so consumers can pick up the latest CFT without changing the template URL. Set to the module release version (e.g. "1.1") when cutting a new tag so that upgrading ref=v1.0.0 to ref=v1.1.0 triggers an update. | `string` | `"1.0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_stack_id"></a> [stack\_id](#output\_stack\_id) | CloudFormation stack ID |
| <a name="output_stack_outputs"></a> [stack\_outputs](#output\_stack\_outputs) | All outputs from the CloudFormation stack |
<!-- END_TF_DOCS -->

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

When Tackle releases template updates (e.g., for new AWS Marketplace features or
security improvements), the changes are picked up automatically since the
template is fetched from Tackle's S3 bucket. Run:

```bash
terraform plan    # Review any resource changes
terraform apply   # Apply the update
```

CloudFormation handles updating existing resources and adding new ones.

## Destroying

```bash
terraform destroy
```

CloudFormation deletes all underlying AWS resources in the correct order.
Contact [Tackle Support](https://help.tackle.io/en/) after destroying if you
need to decommission your integration.

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

The default timeout is 15 minutes. If it times out, the CloudFormation stack may
be stuck in `CREATE_IN_PROGRESS`. Check the CloudFormation console or events for
the resource causing the delay.

### Permission Errors

The deploying IAM principal needs permissions to:

- Create and manage CloudFormation stacks
- Create IAM roles and policies (`iam:CreateRole`, `iam:PutRolePolicy`,
  `iam:AttachRolePolicy`, etc.)
- Create KMS keys, S3 buckets, SQS queues, SNS topics, EventBridge resources,
  and Lambda functions

## Development

### Prerequisites

Install [mise](https://mise.jdx.dev) to manage all tool versions:

```bash
# macOS
brew install mise

# or via the installer
curl https://mise.run | sh
```

### Setup

```bash
# Install all pinned tools (terraform, tflint, trivy, terraform-docs, prek)
mise install

# Install git hooks (runs prek on each commit)
mise run hooks
```

### Common tasks

```bash
mise run fmt       # terraform fmt -recursive
mise run validate  # terraform init + validate
mise run lint      # tflint --init && tflint -f compact
mise run docs      # regenerate README inputs/outputs via terraform-docs
mise run check     # fmt + validate + lint in one go
```

All tasks are defined in [`mise.toml`](./mise.toml).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for setup instructions, coding standards,
and the pull request process.

## Support

- **Tackle Help Center**: https://help.tackle.io/en/
