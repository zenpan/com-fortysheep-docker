# Security Policy

## Supported Versions

This project maintains security support for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| main    | ✅ Yes             |
| < 1.0   | ❌ No              |

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly:

### For Critical Security Issues:
- **Email**: kevin@fortysheep.com
- **Subject**: [SECURITY] Vulnerability Report
- **Response Time**: Within 24 hours

### For General Security Concerns:
- **GitHub Issues**: Create a [security issue](https://github.com/kevinritchey/docker-infrastructure/issues/new?labels=security)
- **Response Time**: Within 7 days

## Security Measures

This project implements multiple layers of security:

### Automated Security Scanning
- **Pre-commit Hooks**: Automatic security scanning on every commit
- **CI/CD Pipeline**: Comprehensive security gates in GitHub Actions
- **Dependencies**: Dependabot monitors for vulnerable dependencies

### Infrastructure Security
- **Trivy**: Infrastructure as Code security scanning
- **Checkov**: Policy compliance validation
- **Gitleaks**: Secret detection and prevention
- **Semgrep**: Static application security testing

### Security Tools Configuration
- **Trivy Config**: `trivy.yaml` with security policies
- **Ignore Rules**: `.trivyignore` for accepted risks
- **Pre-commit**: `.pre-commit-config.yaml` with security hooks

## Security Best Practices

### For Contributors:
1. **Never commit secrets** - Use environment variables or AWS credentials
2. **Run security scans** - Use `make check-security` before pushing
3. **Keep dependencies updated** - Monitor Dependabot PRs
4. **Follow least privilege** - Minimal IAM permissions in Terraform

### For Maintainers:
1. **Review security scan results** - Check GitHub Security tab
2. **Monitor security alerts** - Enable GitHub security notifications
3. **Update security tools** - Keep scanning tools current
4. **Audit access** - Regularly review repository permissions

## Incident Response

In case of a security incident:

1. **Immediate**: Disable affected systems/access
2. **Assess**: Determine scope and impact
3. **Contain**: Prevent further damage
4. **Remediate**: Fix the vulnerability
5. **Document**: Create incident report
6. **Communicate**: Notify affected parties

## Security Contacts

- **Security Lead**: Kevin Ritchey (kevin@fortysheep.com)
- **Backup Contact**: Create GitHub issue with `security` label

## Acknowledgments

We appreciate responsible disclosure of security vulnerabilities and will acknowledge contributors who help improve our security posture.

---

*This security policy is reviewed and updated quarterly.*
