#!/bin/bash
# =====================================================================
# Offline Ansible Development Environment Installation Script
# =====================================================================
# 
# Usage: 
#   1. Transfer ansible-wheels-YYYYMMDD.tar.gz to airgapped system
#   2. Run: bash install-ansible-offline.sh ansible-wheels-YYYYMMDD.tar.gz
#
# This script will:
#   - Extract the wheel bundle
#   - Create/activate virtual environment
#   - Install all Ansible development packages offline
#   - Set up development tools and configuration
# =====================================================================

set -euo pipefail

# Color output functions
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}==> $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
log_error() { echo -e "${RED}✖ $1${NC}"; }

# Check arguments
if [[ $# -ne 1 ]]; then
    log_error "Usage: $0 <ansible-wheels-bundle.tar.gz>"
    exit 1
fi

BUNDLE="$1"
VENV_DIR="${VENV_DIR:-./venv-ansible}"
PYTHON="${PYTHON:-python3.11}"

# Verify bundle exists
if [[ ! -f "$BUNDLE" ]]; then
    log_error "Bundle file '$BUNDLE' not found"
    exit 1
fi

log_info "Starting offline Ansible development environment installation from $BUNDLE"

# Extract bundle
log_info "Extracting wheel bundle..."
tar -xzf "$BUNDLE"
WHEEL_DIR="wheels"

if [[ ! -d "$WHEEL_DIR" ]]; then
    log_error "Wheel directory not found after extraction"
    exit 1
fi

WHEEL_COUNT=$(find "$WHEEL_DIR" -name "*.whl" | wc -l)
log_success "Extracted $WHEEL_COUNT wheels"

# Check Python version
if ! command -v "$PYTHON" &> /dev/null; then
    log_error "Python interpreter '$PYTHON' not found"
    log_info "Available Python versions:"
    ls /usr/bin/python* 2>/dev/null || true
    exit 1
fi

PYTHON_VERSION=$($PYTHON --version 2>&1)
log_info "Using $PYTHON_VERSION"

# Create virtual environment
if [[ -d "$VENV_DIR" ]]; then
    log_warning "Virtual environment '$VENV_DIR' already exists - removing and recreating"
    rm -rf "$VENV_DIR"
fi

if [[ ! -d "$VENV_DIR" ]]; then
    log_info "Creating virtual environment: $VENV_DIR"
    $PYTHON -m venv "$VENV_DIR"
fi

# Activate virtual environment
source "$VENV_DIR/bin/activate"
log_success "Activated virtual environment"

# Upgrade pip
log_info "Upgrading pip, setuptools, wheel..."
pip install --upgrade --find-links "$WHEEL_DIR" --no-index pip setuptools wheel

# Install Ansible core
log_info "Installing Ansible core..."
pip install --find-links "$WHEEL_DIR" --no-index ansible-core ansible

# Install development and testing tools
log_info "Installing development tools..."
pip install --find-links "$WHEEL_DIR" --no-index ansible-lint yamllint molecule pytest pytest-ansible

# Install additional utilities
log_info "Installing additional utilities..."
pip install --find-links "$WHEEL_DIR" --no-index jinja2 requests pyyaml pre-commit black flake8 jmespath netaddr passlib bcrypt cryptography

# Create basic configuration
log_info "Setting up Ansible configuration..."
mkdir -p ~/.ansible

# Create ansible.cfg if it doesn't exist
if [[ ! -f ansible.cfg ]]; then
    cat > ansible.cfg << 'EOF'
[defaults]
host_key_checking = False
inventory = inventory/hosts
roles_path = roles
collections_path = collections
timeout = 30
retry_files_enabled = False
stdout_callback = yaml
bin_ansible_callbacks = True

[inventory]
enable_plugins = host_list, script, auto, yaml, ini, toml

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes
EOF
    log_success "Created ansible.cfg"
fi

# Create molecule configuration
if [[ ! -f molecule.cfg ]]; then
    cat > molecule.cfg << 'EOF'
[defaults]
lint = yamllint .
EOF
    log_success "Created molecule.cfg"
fi

# Create pre-commit configuration for development
if [[ ! -f .pre-commit-config.yaml ]]; then
    cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
        args: ['--multi']
      - id: check-added-large-files

  - repo: https://github.com/adrienverge/yamllint
    rev: v1.32.0
    hooks:
      - id: yamllint
        args: [-c=.yamllint]

  - repo: https://github.com/ansible/ansible-lint
    rev: v6.17.2
    hooks:
      - id: ansible-lint
EOF
    log_success "Created .pre-commit-config.yaml"
fi

# Create yamllint configuration
if [[ ! -f .yamllint ]]; then
    cat > .yamllint << 'EOF'
extends: default

rules:
  line-length:
    max: 120
    level: warning
  comments:
    min-spaces-from-content: 1
  truthy:
    allowed-values: ['true', 'false', 'yes', 'no']
EOF
    log_success "Created .yamllint"
fi

# Create sample directory structure
log_info "Creating sample Ansible project structure..."
mkdir -p {inventory,roles,playbooks,group_vars,host_vars,collections}

# Create sample inventory
if [[ ! -f inventory/hosts ]]; then
    cat > inventory/hosts << 'EOF'
[local]
localhost ansible_connection=local

[development]
# dev-server.example.com

[production]
# prod-server.example.com
EOF
    log_success "Created sample inventory"
fi

log_success "Installation completed successfully!"
log_info "Virtual environment created in: $(pwd)/$VENV_DIR"
log_info "Activation command: source $VENV_DIR/bin/activate"
log_info ""
log_info "Quick start commands:"
log_info "  ansible --version                    # Check Ansible version"
log_info "  ansible-lint --version              # Check linting tools"
log_info "  ansible localhost -m setup          # Test local connection"
log_info "  molecule init role my-role          # Create new role with testing"
log_info ""
log_info "Development workflow:"
log_info "  1. Create playbooks in ./playbooks/"
log_info "  2. Create roles in ./roles/"
log_info "  3. Test with: ansible-playbook playbooks/site.yml --check"
log_info "  4. Lint with: ansible-lint ."
log_info "  5. Test roles with: cd roles/my-role && molecule test"

# Verification
log_info "Performing verification..."
python -c "
import sys
packages = ['ansible', 'yaml', 'jinja2', 'requests', 'pytest']
failed = []
for pkg in packages:
    try:
        __import__(pkg)
        print(f'✓ {pkg}')
    except ImportError as e:
        print(f'✗ {pkg}: {e}')
        failed.append(pkg)

if failed:
    print(f'\n⚠ Failed to import: {failed}')
    sys.exit(1)
else:
    print(f'\n🎉 All {len(packages)} core packages imported successfully!')
"

# Test Ansible installation
log_info "Testing Ansible installation..."
ansible --version
ansible-lint --version

log_success "Verification completed - Ansible development environment is ready!"
log_success "You can now work on the redesigned-guacamole project and similar Ansible automation!"
