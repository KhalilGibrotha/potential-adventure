# Ansible Development Environment for Airgapped Systems

This offline bundle provides a complete Ansible development stack for RHEL 9 systems without internet access. The bundle includes all necessary Python wheels and dependencies for professional Ansible development, testing, and automation workflows.

## 📦 What's Included

### Core Ansible Components
- **Ansible Core** - The foundational automation engine
- **Ansible Collections** - Extended modules and plugins
- **Ansible Lint** - Best practices validation and code quality
- **YAML Lint** - YAML syntax and style validation

### Development & Testing Framework
- **Molecule** - Ansible role testing framework with plugins
- **pytest** - Python testing framework with Ansible extensions
- **pytest-ansible** - Ansible-specific testing utilities

### Code Quality & Linting
- **pre-commit** - Git hook framework for code quality
- **black** - Python code formatter
- **flake8** - Python linting and style checking
- **yamllint** - YAML linting and validation

### Essential Libraries & Dependencies
- **Jinja2** - Template engine (required by Ansible)
- **PyYAML** - YAML parsing and generation
- **requests** - HTTP library for API interactions
- **jmespath** - JSON query language
- **netaddr** - Network address manipulation
- **passlib** - Password hashing utilities
- **bcrypt** - Modern password hashing
- **cryptography** - Cryptographic libraries

### System Tools
- **jq** - JSON processor and query tool
- **pandoc** - Universal document converter

## 🚀 Quick Installation

### Option 1: Automated Installation (Recommended)
```bash
# Extract and run the installer
tar -xzf ansible-complete-20250709.tar.gz
cd ansible/
bash install-ansible-offline.sh ansible-wheels-20250709.tar.gz
```

### Option 2: Manual Installation
```bash
# Extract wheels
tar -xzf ansible-wheels-20250709.tar.gz

# Create virtual environment
python3 -m venv venv-ansible
source venv-ansible/bin/activate

# Install from offline wheels
pip install --find-links wheels --no-index ansible ansible-lint molecule pytest
```

## 📋 Bundle Contents

### Generated Files
- `ansible-wheels-20250709.tar.gz` - All Python wheels (249MB)
- `install-ansible-offline.sh` - Automated installation script
- `requirements-ansible.txt` - Package list for reference
- `Makefile.source` - Source Makefile for rebuilding
- `README.md` - This documentation
- `QUICKSTART.md` - Quick reference guide

### Installation Creates
- `venv-ansible/` - Python virtual environment
- `ansible.cfg` - Ansible configuration file
- `inventory/` - Sample inventory structure
- `playbooks/` - Example playbook templates

## ⚙️ Post-Installation Configuration

### Activate Environment
```bash
source venv-ansible/bin/activate
```

### Verify Installation
```bash
# Check Ansible version
ansible --version

# Check Ansible Lint
ansible-lint --version

# Check Molecule
molecule --version

# Check available collections
ansible-galaxy collection list
```

### Test Installation
```bash
# Test basic connectivity
ansible localhost -m ping

# Test linting
echo "- name: test" > test.yml
ansible-lint test.yml

# Test molecule (if docker available)
molecule --version
```

## 🏗️ Development Workflow

### 1. Project Structure
```
ansible-project/
├── ansible.cfg              # Ansible configuration
├── inventory/               # Target systems
│   ├── production/
│   └── staging/
├── playbooks/              # Automation playbooks
├── roles/                  # Reusable roles
├── group_vars/             # Group variables
├── host_vars/              # Host-specific variables
└── molecule/               # Testing scenarios
```

### 2. Role Development
```bash
# Create a new role
ansible-galaxy init my-role

# Test with molecule
cd my-role
molecule test
```

### 3. Quality Assurance
```bash
# Lint playbooks
ansible-lint playbooks/

# Lint YAML files
yamllint .

# Run pre-commit hooks
pre-commit run --all-files
```

## 🧪 Testing Framework

### Molecule Testing
```bash
# Initialize molecule in role
molecule init scenario --driver-name docker

# Test role
molecule test

# Create instance for debugging
molecule create
molecule converge
molecule verify
molecule destroy
```

### pytest Integration
```bash
# Run Ansible-specific tests
pytest tests/

# Test with different inventory
pytest --ansible-inventory=inventory/staging tests/
```

## 🔧 Configuration Examples

### ansible.cfg
```ini
[defaults]
inventory = inventory/production
host_key_checking = False
retry_files_enabled = False
stdout_callback = yaml
pipelining = True

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
```

### Inventory Structure
```yaml
# inventory/production/hosts.yml
all:
  children:
    webservers:
      hosts:
        web01.example.com:
        web02.example.com:
    databases:
      hosts:
        db01.example.com:
```

## 🔍 Troubleshooting

### Common Issues

**Import Errors**
```bash
# Ensure virtual environment is activated
source venv-ansible/bin/activate

# Check Python path
python -c "import ansible; print(ansible.__file__)"
```

**Module Not Found**
```bash
# Install missing dependencies
pip install --find-links wheels --no-index <package-name>

# Check available wheels
ls wheels/*.whl | grep <package>
```

**Ansible Collections**
```bash
# Install additional collections offline
ansible-galaxy collection install --offline <collection-path>

# List installed collections
ansible-galaxy collection list
```

### Performance Optimization

**Ansible Configuration**
```ini
# ansible.cfg performance settings
[defaults]
host_key_checking = False
pipelining = True
forks = 50

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=300s
```

**System Tuning**
```bash
# Increase file limits for large inventories
ulimit -n 4096

# Parallel execution
export ANSIBLE_FORKS=20
```

## 📚 Documentation & Resources

### Official Documentation
- [Ansible Documentation](https://docs.ansible.com/)
- [Molecule Documentation](https://molecule.readthedocs.io/)
- [Ansible Lint Rules](https://ansible-lint.readthedocs.io/)

### Best Practices
- Use descriptive task names
- Implement idempotency in all tasks
- Use handlers for service restarts
- Tag tasks for selective execution
- Document variables and defaults

### Security Considerations
- Store secrets in Ansible Vault
- Use least privilege principles
- Validate input parameters
- Implement proper error handling

## 🎯 Use Cases

### Infrastructure as Code
- Server provisioning and configuration
- Application deployment automation
- Security compliance automation
- Disaster recovery procedures

### Testing & Validation
- Role testing with Molecule
- Integration testing with pytest
- Syntax validation with ansible-lint
- Configuration drift detection

### CI/CD Integration
- Pipeline automation
- Quality gates with linting
- Automated testing workflows
- Deployment orchestration

## 🔄 Updating & Maintenance

### Updating Packages
```bash
# On internet-connected machine
make -f Makefile.source clean
make -f Makefile.source dist

# Transfer new bundle to airgapped system
scp ansible-complete-*.tar.gz target-host:
```

### Backup Configuration
```bash
# Backup current environment
tar -czf ansible-backup-$(date +%Y%m%d).tar.gz venv-ansible/ ansible.cfg inventory/
```

## 📈 Bundle Statistics

- **Total Wheels**: ~180 packages
- **Bundle Size**: 249MB compressed
- **Python Version**: 3.11+ (RHEL 9 compatible)
- **Architecture**: x86_64
- **Generated**: $(date)

## 🎉 Success Indicators

After successful installation, you should have:
- ✅ Ansible CLI tools available
- ✅ Molecule testing framework ready
- ✅ Linting tools configured
- ✅ Development environment isolated
- ✅ All dependencies satisfied offline

## 📞 Support

### Self-Diagnosis
```bash
# Environment check
source venv-ansible/bin/activate
python -c "import ansible, molecule, yaml; print('All imports successful')"

# Configuration validation
ansible-config dump --only-changed
```

### Common Commands
```bash
# Quick environment setup
source venv-ansible/bin/activate

# Test basic functionality
ansible --version && ansible-lint --version && molecule --version
```

Ready to automate your infrastructure? Start with the quickstart guide! 🚀
