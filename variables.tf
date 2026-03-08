variable "external_id" {
  type        = string
  description = "A hash of a Tackle-internal identifier unique to your company. Provided by Tackle."
  sensitive   = true

  validation {
    condition     = length(var.external_id) > 0
    error_message = "You must use the Tackle-provided external ID."
  }
}

variable "registration_token" {
  type        = string
  description = "The token used to complete the registration process. Provided by Tackle."
  sensitive   = true

  validation {
    condition     = length(var.registration_token) >= 10
    error_message = "You must use the Tackle-provided registration token (minimum 10 characters)."
  }
}

variable "stack_name" {
  type        = string
  description = "Name for the CloudFormation stack."
  default     = "Tackle-Resources"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.stack_name))
    error_message = "Stack name must start with a letter and contain only alphanumeric characters and hyphens."
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to the CloudFormation stack and its resources."
  default     = {}
}
