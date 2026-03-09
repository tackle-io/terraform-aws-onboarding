# Security Policy

## Reporting a Vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.**

If you discover a security issue in this module, report it through GitHub's
private vulnerability reporting:

1. Go to the
   [Security tab](https://github.com/tackle-io/terraform-aws-onboarding/security)
2. Click **"Report a vulnerability"**
3. Fill in the details

You can also email **security@tackle.io** if you prefer.

## What to Include

- A description of the vulnerability and its potential impact
- Steps to reproduce or a proof-of-concept
- Affected versions (if known)
- Any suggested mitigations

## Response Timeline

| Stage                    | Target                 |
| ------------------------ | ---------------------- |
| Acknowledgement          | Within 2 business days |
| Initial assessment       | Within 5 business days |
| Resolution or mitigation | Dependent on severity  |

We follow responsible disclosure: we ask that you give us reasonable time to
address the issue before any public disclosure.

## Scope

This repository manages a Terraform module that deploys AWS infrastructure.
Issues in scope include:

- IAM permissions that are broader than necessary
- Insecure defaults in module variables
- Sensitive data exposed in Terraform outputs or state
- Supply chain risks in this repository's CI/CD configuration

Issues out of scope:

- Vulnerabilities in the underlying AWS services themselves
- Issues in Tackle's CloudFormation template (report those to
  security@tackle.io)
- Vulnerabilities in third-party tools (report upstream)
