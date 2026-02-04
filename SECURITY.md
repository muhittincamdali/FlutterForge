# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to: security@muhittincamdali.com

Please include the following information:

- Type of issue (e.g., buffer overflow, SQL injection, cross-site scripting, etc.)
- Full paths of source file(s) related to the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Resolution**: Typically within 30 days, depending on complexity

### Disclosure Policy

- We will acknowledge your report within 48 hours
- We will provide a more detailed response within 7 days
- We will work with you to understand and resolve the issue
- We will keep you informed of our progress
- We will credit you in our security advisory (unless you prefer anonymity)

## Preferred Languages

We prefer all communications to be in English.

## Security Best Practices

When using FlutterForge in your projects:

1. **Keep Dependencies Updated**: Regularly update your dependencies
2. **Secure API Keys**: Never commit API keys or secrets
3. **Use Environment Variables**: Store sensitive data in env files
4. **Enable ProGuard/R8**: For release builds on Android
5. **Code Signing**: Properly sign your release builds

## Security Features

FlutterForge includes several security best practices by default:

- Secure storage for sensitive data
- Certificate pinning support
- Biometric authentication helpers
- Secure network configuration
