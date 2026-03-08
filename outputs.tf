output "stack_id" {
  description = "CloudFormation stack ID"
  value       = aws_cloudformation_stack.tackle.id
}

output "stack_outputs" {
  description = "All outputs from the CloudFormation stack"
  value       = aws_cloudformation_stack.tackle.outputs
}
