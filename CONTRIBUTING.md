# Contributing

Thanks for your interest in contributing to this module.

## Getting Started

### Prerequisites

Install [mise](https://mise.jdx.dev) to manage all tool versions:

```bash
brew install mise       # macOS
curl https://mise.run | sh  # Linux / other
```

Then install all pinned tools and git hooks:

```bash
mise install   # installs terraform, tflint, trivy, terraform-docs, prek
mise run hooks # installs prek git hooks
```

### Running checks locally

```bash
mise run fmt       # auto-format all Terraform files
mise run validate  # terraform init + validate
mise run lint      # tflint with AWS ruleset
mise run docs      # regenerate README inputs/outputs table
mise run check     # runs fmt, validate, and lint together
```

All of these run automatically in CI on every push and pull request.

## Making Changes

1. Fork the repository and create a branch from `main`
2. Make your changes — keep each PR focused on a single concern
3. Run `mise run check` and ensure all checks pass
4. Update the README if you add, remove, or change a variable or output
   (`mise run docs` handles the inputs/outputs table automatically)
5. Open a pull request against `main` using the provided PR template

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>: <short description>

[optional body]
```

Types: `feat`, `fix`, `docs`, `refactor`, `ci`, `chore`

## Versioning

This module follows [Semantic Versioning](https://semver.org/):

- **Patch** (`1.0.x`) — bug fixes, no interface changes
- **Minor** (`1.x.0`) — new optional variables or outputs, backwards compatible
- **Major** (`x.0.0`) — breaking changes to required variables or behaviour

Releases are created automatically by release-drafter based on PR labels. Apply
the appropriate label (`major`, `minor`, `patch`) to your PR.

## Reporting Issues

Use the GitHub issue templates:

- **Bug report** — for unexpected behaviour or errors
- **Feature request** — for new capabilities or improvements

For security vulnerabilities, see [SECURITY.md](.github/SECURITY.md).
