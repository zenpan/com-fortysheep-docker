# Ansible Linting and Standards Guide

This document outlines the tools and practices for ensuring Ansible playbook consistency, standards adherence, and quality.

## Available Tools

### 1. ansible-lint (Primary Tool)
**Purpose**: Official Ansible linting tool for best practices and standards

**Features**:
- ✅ Syntax validation
- ✅ Best practices enforcement
- ✅ Deprecated module detection
- ✅ Security rule checking
- ✅ Code style consistency
- ✅ Configurable rules and profiles

**Installation**: `pip install ansible-lint`
**Usage**: `make ansible-lint`
**Config**: `.ansible-lint`

### 2. yamllint
**Purpose**: YAML syntax and style validation

**Features**:
- ✅ YAML syntax validation
- ✅ Consistent formatting rules
- ✅ Line length enforcement
- ✅ Indentation checking
- ✅ Comment style validation

**Installation**: `pip install yamllint`
**Usage**: `make ansible-yaml-lint`
**Config**: `.yamllint`

### 3. ansible-playbook --syntax-check
**Purpose**: Built-in Ansible syntax validation

**Features**:
- ✅ Basic syntax checking
- ✅ Variable reference validation
- ✅ Module parameter validation
- ✅ Jinja2 template validation

**Usage**: `make ansible-syntax-check`

### 4. Semgrep (Security Analysis)
**Purpose**: Static analysis for security vulnerabilities in Ansible code

**Features**:
- ✅ Security vulnerability detection
- ✅ OWASP rule compliance
- ✅ Custom rule configuration
- ✅ Integration with CI/CD pipelines
- ✅ Multi-language support

**Installation**: `pip install semgrep`
**Usage**: `make ansible-semgrep`
**Config**: `.semgrepignore`

**Note**: Semgrep was chosen over ansible-review due to compatibility issues with newer ansible-lint versions. Semgrep provides comprehensive security analysis with active maintenance and broad rule coverage.

### 5. Molecule (Advanced - Future Use)
**Purpose**: Testing framework for Ansible roles

**Features**:
- ✅ Role testing with multiple scenarios
- ✅ Integration testing
- ✅ Docker/Vagrant support
- ✅ Automated testing pipelines

**Installation**: `pip install molecule`
**Usage**: For role development and testing

**Note**: Molecule will be needed once the project makes use of roles for comprehensive testing scenarios.

## Configuration Files

### .ansible-lint
```yaml
---
profile: production  # min, basic, moderate, safety, shared, production

exclude_paths:
  - .cache/
  - .github/
  - .venv/
  - venv/

skip_list:
  - yaml[line-length]  # Allow longer lines
  - name[template]     # Allow template variables in names

enable_list:
  - no-log-password    # Ensure passwords are not logged
  - no-same-owner      # Check file ownership
```

### .yamllint
```yaml
---
extends: default

rules:
  line-length:
    max: 120
    allow-non-breakable-words: true

  truthy:
    allowed-values: ['true', 'false', 'yes', 'no', 'on', 'off']

  indentation:
    spaces: 2
    indent-sequences: true
```

### .semgrepignore
```
# Semgrep ignore file
# Ignore files and directories that shouldn't be scanned

# Development and build directories
.git/
.venv/
venv/
.tox/
.cache/
node_modules/
.pytest_cache/
__pycache__/
*.pyc
*.pyo

# IDE and editor files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Build artifacts
*.tar.gz
*.zip
*.log
*.tmp

# Secrets and sensitive files
*.key
*.pem
*.cert
*.crt
.env
.env.local
.env.production

# Test and example files
test_*
*_test.py
example_*
examples/
tests/

# Documentation
*.md
*.rst
*.txt
```

## Make Commands

### Individual Tools
- `make ansible-lint` - Run ansible-lint on playbooks
- `make ansible-yaml-lint` - Run yamllint on Ansible files
- `make ansible-syntax-check` - Check Ansible playbook syntax
- `make ansible-semgrep` - Run Semgrep security analysis on Ansible files

### Combined
- `make ansible-check-all` - Run all Ansible checks (syntax, yaml, lint, semgrep)

## Common Issues and Solutions

### 1. Duplicate Task Names
**Issue**: `name[unique]: Task name 'Display reboot requirement status' is not unique`
**Solution**: Use descriptive, unique task names
```yaml
# Bad
- name: Display reboot requirement status
  debug: msg="RedHat reboot status"

- name: Display reboot requirement status
  debug: msg="Debian reboot status"

# Good
- name: Display RedHat reboot requirement status
  debug: msg="RedHat reboot status"

- name: Display Debian reboot requirement status
  debug: msg="Debian reboot status"
```

### 2. Line Length Issues
**Issue**: `line too long (87 > 80 characters)`
**Solution**: Break long lines or configure yamllint
```yaml
# Bad
- name: This is a very long task name that exceeds the line length limit and should be shortened

# Good
- name: Install required packages for system maintenance
```

### 3. YAML Formatting
**Issue**: Various YAML formatting issues
**Solution**: Use consistent indentation and spacing
```yaml
# Bad
- name:Install packages
  apt:
    name: "{{item}}"
    state:present
  with_items:
  - package1
  - package2

# Good
- name: Install packages
  ansible.builtin.apt:
    name: "{{ item }}"
    state: present
  with_items:
    - package1
    - package2
```

### 4. Deprecated Modules
**Issue**: Use of deprecated modules
**Solution**: Use fully qualified collection names (FQCN)
```yaml
# Bad
- name: Update packages
  apt:
    upgrade: dist

# Good
- name: Update packages
  ansible.builtin.apt:
    upgrade: dist
```

## Best Practices

### 1. Use FQCN (Fully Qualified Collection Names)
- Always use `ansible.builtin.` prefix for built-in modules
- Use collection names for third-party modules

### 2. Consistent Naming
- Use descriptive, unique task names
- Follow consistent naming conventions
- Avoid duplicate task names

### 3. Proper Variable Handling
- Use `{{ variable }}` syntax consistently
- Avoid bare variables in conditionals
- Use proper quoting for variables

### 4. Security Considerations
- Use `no_log: true` for sensitive operations
- Avoid hardcoded secrets
- Use proper file permissions

### 5. Error Handling
- Use `failed_when` for custom failure conditions
- Use `changed_when` for idempotency
- Handle errors gracefully

## Integration with CI/CD

### Pre-commit Hooks
Ansible linting is integrated into pre-commit hooks:
```yaml
- repo: https://github.com/ansible/ansible-lint
  rev: v25.6.1
  hooks:
    - id: ansible-lint
      files: ^playbooks/.*\.(yml|yaml)$
```

### GitHub Actions
Ansible linting runs in CI/CD pipeline:
```yaml
- name: Run Ansible Lint
  run: make ansible-check-all
```

### Semgrep Integration
Semgrep is integrated for continuous security analysis:
```yaml
- name: Run Semgrep Security Analysis
  run: make ansible-semgrep
```

## Profiles and Strictness Levels

### ansible-lint Profiles
- **min**: Minimal rule set
- **basic**: Basic rule set (recommended for beginners)
- **moderate**: Moderate rule set
- **safety**: Safety-focused rules
- **shared**: Shared/collaborative rules
- **production**: Production-ready rules (strictest)

### Current Configuration
- **Profile**: `production` (strictest standards)
- **Verbosity**: Standard output
- **Exclusions**: Development and cache directories

## Troubleshooting

### Common ansible-lint Issues
1. **Rule conflicts**: Adjust `skip_list` in `.ansible-lint`
2. **False positives**: Use `enable_list` for specific rules
3. **Performance**: Use `exclude_paths` for large directories

### Common yamllint Issues
1. **Line length**: Adjust `line-length` rule
2. **Indentation**: Configure `indentation` rule
3. **Comments**: Adjust `comments` rule

### Tool Compatibility
- **ansible-lint**: Compatible with Ansible 2.12+
- **yamllint**: Works with any YAML files
- **semgrep**: Compatible with multiple languages and frameworks
- **ansible-review**: Deprecated due to compatibility issues with newer ansible-lint versions

### Security Analysis with Semgrep
Semgrep provides comprehensive security analysis for Ansible playbooks:
- **OWASP Top 10**: Detects common security vulnerabilities
- **CWE Rules**: Common Weakness Enumeration compliance
- **Custom Rules**: Supports custom security rule development
- **CI/CD Integration**: Seamlessly integrates with automated pipelines
- **Multi-format Output**: JSON, SARIF, and text output formats

## Monitoring and Metrics

### Quality Metrics
- **Lint failures**: Track failures over time
- **Rule violations**: Monitor specific rule patterns
- **Technical debt**: Measure skipped rules

### Reporting
- **CI/CD reports**: Automated reporting in pipelines
- **Developer feedback**: Immediate feedback via pre-commit hooks
- **Quality gates**: Prevent deployment of non-compliant code

## Resources

### Documentation
- [ansible-lint Documentation](https://ansible.readthedocs.io/projects/lint/)
- [yamllint Documentation](https://yamllint.readthedocs.io/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

### Tools
- [ansible-lint Rules](https://ansible.readthedocs.io/projects/lint/rules/)
- [yamllint Rules](https://yamllint.readthedocs.io/en/stable/rules.html)
- [Semgrep Rules](https://semgrep.dev/explore)
- [Molecule Testing](https://molecule.readthedocs.io/)

---

*This guide ensures consistent, high-quality Ansible code that follows industry best practices and security standards.*
