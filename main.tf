data "aws_region" "current" {}

resource "terraform_data" "region_check" {
  lifecycle {
    precondition {
      condition     = data.aws_region.current.id == "us-east-1"
      error_message = "The Tackle stack must be deployed in the us-east-1 (N. Virginia) region to integrate with AWS Marketplace and Partner Central."
    }
  }
}

resource "aws_cloudformation_stack" "tackle" {
  name         = var.stack_name
  template_url = "https://tackle-templates.s3.us-west-2.amazonaws.com/integrations/aws-onboarding.yaml"

  parameters = {
    ExternalId        = var.external_id
    RegistrationToken = var.registration_token
  }

  capabilities = [
    "CAPABILITY_IAM",
    "CAPABILITY_NAMED_IAM",
    "CAPABILITY_AUTO_EXPAND"
  ]

  tags = var.tags

  # Allow up to 15 minutes for stack creation (Lambda registration + resource creation)
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}
