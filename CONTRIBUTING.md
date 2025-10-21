# Contributing to V-Model AUTOSAR Docs

We welcome contributions that improve traceability, documentation, and test coverage.

## Workflow

1. Fork the repository
2. Create a feature branch
3. Add or update `.rst` files in `docs/`
4. Link requirements to specs and tests using `:derived_from:` and `:tests:`
5. Run `sphinx-build` to verify documentation
6. Submit a pull request

## Style Guide

- Use `reStructuredText` for all documentation
- Follow V-model structure: requirement → design → implementation → test → validation
- Use `Sphinx-Needs` directives for traceability

## Testing

Use `ctest` or `make test` to run unit tests. Link test cases to requirements in `docs/tests/`.

Happy documenting!
