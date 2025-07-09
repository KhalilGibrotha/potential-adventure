# Ansible Development Environment - Quickstart Guide

⚡ **Get up and running with Ansible development in 5 minutes!**

## 🚀 Fast Track Installation

### Step 1: Install (30 seconds)
```bash
# Extract the bundle
tar -xzf ansible-complete-20250709.tar.gz
cd ansible/

# Run automated installer
bash install-ansible-offline.sh ansible-wheels-20250709.tar.gz
```

### Step 2: Activate (5 seconds)
```bash
source venv-ansible/bin/activate
```

### Step 3: Verify (10 seconds)
```bash
ansible --version
```

**That's it!** You now have a complete Ansible development environment.

## ⚡ Essential Commands

### Quick Validation
```bash
# Test Ansible installation
ansible localhost -m ping

# Check installed tools
ansible --version && ansible-lint --version && molecule --version

# View available collections
ansible-galaxy collection list
```

### Instant Role Creation
```bash
# Create a new role
ansible-galaxy init my-app-role
cd my-app-role

# Test the role with Molecule
molecule test
```

### Fast Linting
```bash
# Lint a playbook
ansible-lint playbook.yml

# Lint all YAML files
yamllint .

# Quick syntax check
ansible-playbook --syntax-check playbook.yml
```

## 📋 Cheat Sheet

### Must-Know Commands
| Command | Purpose |
|---------|---------|
| `ansible-playbook site.yml` | Run playbook |
| `ansible-lint playbook.yml` | Lint playbook |
| `ansible-galaxy init role-name` | Create role |
| `molecule test` | Test role |
| `ansible-vault create secrets.yml` | Create encrypted file |
| `ansible-inventory --list` | Show inventory |

### Quick File Templates

**Simple Playbook** (`site.yml`)
```yaml
---
- name: Configure servers
  hosts: all
  become: yes
  tasks:
    - name: Install package
      package:
        name: nginx
        state: present
```

**Basic Inventory** (`inventory/hosts.yml`)
```yaml
all:
  children:
    webservers:
      hosts:
        web01.example.com:
        web02.example.com:
```

**Ansible Config** (`ansible.cfg`)
```ini
[defaults]
inventory = inventory/hosts.yml
host_key_checking = False
stdout_callback = yaml
```

## 🧪 Testing Workflow

### 1. Create & Test Role
```bash
# Create role
ansible-galaxy init webserver

# Edit role tasks
vim webserver/tasks/main.yml

# Test with Molecule
cd webserver
molecule test
```

### 2. Playbook Development
```bash
# Create playbook
vim site.yml

# Syntax check
ansible-playbook --syntax-check site.yml

# Dry run
ansible-playbook --check site.yml

# Execute
ansible-playbook site.yml
```

### 3. Quality Assurance
```bash
# Comprehensive linting
ansible-lint site.yml

# YAML validation
yamllint site.yml

# Pre-commit hooks (if configured)
pre-commit run --all-files
```

## 🔧 Common Configurations

### Enable Ansible Vault
```bash
# Create vault password file
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass

# Add to ansible.cfg
echo "vault_password_file = .vault_pass" >> ansible.cfg
```

### Performance Tuning
```bash
# Add to ansible.cfg
cat >> ansible.cfg << 'EOF'
[defaults]
forks = 20
host_key_checking = False
pipelining = True

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=300s
EOF
```

## 🎯 Project Structure Template

```bash
# Create standard project structure
mkdir -p {inventory,playbooks,roles,group_vars,host_vars}
mkdir -p inventory/{production,staging}

# Basic files
touch ansible.cfg
touch inventory/production/hosts.yml
touch playbooks/site.yml
```

## 🚨 Troubleshooting Quick Fixes

### Environment Issues
```bash
# Ensure virtual environment is active
source venv-ansible/bin/activate

# Check Python path
which python
which ansible
```

### Module Import Errors
```bash
# Reinstall problematic package
pip install --find-links wheels --no-index --force-reinstall ansible
```

### Connectivity Issues
```bash
# Test SSH connectivity
ansible all -m ping -u your-username

# Check inventory
ansible-inventory --list --yaml
```

### Permission Issues
```bash
# Use sudo for privilege escalation
ansible-playbook -b site.yml

# Specify user
ansible-playbook -u your-username site.yml
```

## 📊 Success Checklist

After setup, verify you can:
- [ ] Run `ansible --version` without errors
- [ ] Execute `ansible localhost -m ping` successfully
- [ ] Create a role with `ansible-galaxy init test-role`
- [ ] Lint with `ansible-lint --version`
- [ ] Test with `molecule --version`

## 🏃‍♂️ Next Steps

1. **Create your first playbook** following the templates above
2. **Set up inventory** for your target systems  
3. **Configure SSH keys** for passwordless access
4. **Start with simple tasks** like package installation
5. **Use roles** for reusable components
6. **Implement testing** with Molecule
7. **Add quality gates** with linting

## 🎓 Learning Path

### Beginner (Week 1)
- Basic playbook creation
- Inventory management  
- Simple task execution

### Intermediate (Week 2-3)
- Role development
- Variable management
- Conditional logic

### Advanced (Week 4+)
- Molecule testing
- Custom modules
- Advanced templating

## 📚 Essential Documentation

- [Ansible User Guide](https://docs.ansible.com/ansible/latest/user_guide/)
- [Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Molecule Testing](https://molecule.readthedocs.io/en/latest/)

## 💡 Pro Tips

### Speed Up Development
```bash
# Use check mode for dry runs
ansible-playbook --check site.yml

# Run specific tags only
ansible-playbook --tags "config" site.yml

# Limit to specific hosts
ansible-playbook --limit "webservers" site.yml
```

### Debug Effectively
```bash
# Verbose output
ansible-playbook -vvv site.yml

# Debug tasks
- debug: var=variable_name

# Step through tasks
ansible-playbook --step site.yml
```

**Ready to build automation? Start with a simple playbook and grow from there!** 🚀

---
*Need help? Check the full README.md for comprehensive documentation and troubleshooting guides.*
