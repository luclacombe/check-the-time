# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly via [GitHub's private vulnerability reporting](https://github.com/luclacombe/check-the-time/security/advisories/new).

Do **not** open a public issue for security vulnerabilities.

## Scope

This is a macOS menu bar app with no network calls, no user accounts, and no server component. The attack surface is limited to:

- The bundled `games.json` data file (pre-generated, no runtime fetching)
- The Python data pipeline in `scripts/` (runs offline, developer-only)
- GitHub Actions CI/CD workflows
