#!/bin/bash
# =====================================================================
# Miniconda Offline Installer for RHEL 9 Systems
# =====================================================================
#
# This script installs Miniconda from a bundled installer without 
# requiring internet connectivity. Designed for airgapped RHEL 9 systems.
#
# Usage:
#   bash install-miniconda-offline.sh [OPTIONS]
#
# Options:
#   --user          Install for current user only (default)
#   --system        Install system-wide (requires root)
#   --prefix PATH   Install to custom directory
#   --silent        Silent installation (no prompts)
#   --help          Show this help message
#
# =====================================================================

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/miniconda-install.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Default installation settings
INSTALL_MODE="user"
INSTALL_PREFIX=""
SILENT_MODE=false
FORCE_INSTALL=false
DRY_RUN=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${TIMESTAMP}: $*" >> "$LOG_FILE"
    echo -e "$*"
}

error() {
    log "${RED}ERROR: $*${NC}" >&2
    exit 1
}

warning() {
    log "${YELLOW}WARNING: $*${NC}"
}

info() {
    log "${BLUE}INFO: $*${NC}"
}

success() {
    log "${GREEN}SUCCESS: $*${NC}"
}

# Help function
show_help() {
    cat << EOF
Miniconda Offline Installer for RHEL 9

Usage: $0 [OPTIONS]

Options:
  --user          Install for current user only (default)
  --system        Install system-wide (requires root)
  --prefix PATH   Install to custom directory
  --silent        Silent installation (no prompts)
  --force         Force installation (overwrite existing)
  --dry-run       Show what would be done without installing
  --help          Show this help message

Examples:
  $0                                    # User installation
  $0 --system                          # System-wide installation
  $0 --prefix /opt/miniconda3          # Custom installation path
  $0 --silent --user                   # Silent user installation
  $0 --dry-run                         # Preview installation steps

For more information, see README.md
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --user)
                INSTALL_MODE="user"
                shift
                ;;
            --system)
                INSTALL_MODE="system"
                shift
                ;;
            --prefix)
                INSTALL_PREFIX="$2"
                INSTALL_MODE="custom"
                shift 2
                ;;
            --silent)
                SILENT_MODE=true
                shift
                ;;
            --force)
                FORCE_INSTALL=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done
}

# Check system requirements
check_requirements() {
    info "Checking system requirements..."
    
    # Check OS
    if [[ ! -f /etc/redhat-release ]]; then
        warning "This script is designed for RHEL 9. Continuing anyway..."
    else
        local rhel_version=$(grep -oP 'release \K[0-9]+' /etc/redhat-release 2>/dev/null || echo "unknown")
        if [[ "$rhel_version" != "9" ]]; then
            warning "Expected RHEL 9, found version $rhel_version. Continuing anyway..."
        fi
    fi
    
    # Check architecture
    local arch=$(uname -m)
    if [[ "$arch" != "x86_64" ]]; then
        error "Unsupported architecture: $arch. This installer requires x86_64."
    fi
    
    # Check available disk space (require at least 2GB)
    local available_space=$(df "$HOME" | awk 'NR==2 {print $4}')
    local required_space=2097152 # 2GB in KB
    
    if [[ "$available_space" -lt "$required_space" ]]; then
        error "Insufficient disk space. Required: 2GB, Available: $((available_space / 1024 / 1024))GB"
    fi
    
    success "System requirements check passed"
}

# Determine installation directory
determine_install_dir() {
    case "$INSTALL_MODE" in
        user)
            INSTALL_PREFIX="$HOME/miniconda3"
            ;;
        system)
            if [[ $EUID -ne 0 ]]; then
                error "System-wide installation requires root privileges. Use 'sudo $0 --system'"
            fi
            INSTALL_PREFIX="/opt/miniconda3"
            ;;
        custom)
            # INSTALL_PREFIX already set by --prefix option
            ;;
    esac
    
    info "Installation directory: $INSTALL_PREFIX"
}

# Check for existing installation
check_existing_installation() {
    if [[ -d "$INSTALL_PREFIX" ]]; then
        if [[ "$FORCE_INSTALL" == "true" ]]; then
            warning "Removing existing installation at $INSTALL_PREFIX"
            rm -rf "$INSTALL_PREFIX"
        else
            if [[ "$SILENT_MODE" == "false" ]]; then
                echo -n "Miniconda already exists at $INSTALL_PREFIX. Overwrite? [y/N]: "
                read -r response
                if [[ ! "$response" =~ ^[Yy]$ ]]; then
                    error "Installation cancelled by user"
                fi
            else
                error "Existing installation found at $INSTALL_PREFIX. Use --force to overwrite."
            fi
            rm -rf "$INSTALL_PREFIX"
        fi
    fi
}

# Find the Miniconda installer
find_installer() {
    local installer_pattern="Miniconda3-*-Linux-x86_64.sh"
    local installer_file=""
    
    # Look for installer in current directory
    for file in $SCRIPT_DIR/$installer_pattern; do
        if [[ -f "$file" ]]; then
            installer_file="$file"
            break
        fi
    done
    
    if [[ -z "$installer_file" ]]; then
        error "Miniconda installer not found. Expected pattern: $installer_pattern"
    fi
    
    info "Found installer: $(basename "$installer_file")"
    echo "$installer_file"
}

# Install Miniconda
install_miniconda() {
    local installer_file
    installer_file=$(find_installer)
    
    info "Installing Miniconda to $INSTALL_PREFIX"
    
    # Make installer executable
    chmod +x "$installer_file"
    
    # Create parent directory if needed
    local parent_dir=$(dirname "$INSTALL_PREFIX")
    if [[ ! -d "$parent_dir" ]]; then
        mkdir -p "$parent_dir"
    fi
    
    # Run installer
    if [[ "$SILENT_MODE" == "true" ]]; then
        bash "$installer_file" -b -p "$INSTALL_PREFIX" >> "$LOG_FILE" 2>&1
    else
        bash "$installer_file" -b -p "$INSTALL_PREFIX"
    fi
    
    if [[ ! -d "$INSTALL_PREFIX" ]]; then
        error "Installation failed. Check log file: $LOG_FILE"
    fi
    
    success "Miniconda installed successfully"
}

# Configure Miniconda
configure_miniconda() {
    info "Configuring Miniconda..."
    
    local conda_exe="$INSTALL_PREFIX/bin/conda"
    
    # Initialize conda for bash (if not silent)
    if [[ "$SILENT_MODE" == "false" ]]; then
        echo -n "Initialize conda for bash shell? [Y/n]: "
        read -r response
        if [[ ! "$response" =~ ^[Nn]$ ]]; then
            "$conda_exe" init bash >> "$LOG_FILE" 2>&1
            success "Conda initialized for bash. Please restart your shell or run 'source ~/.bashrc'"
        fi
    fi
    
    # Set default configuration
    "$conda_exe" config --set auto_activate_base false >> "$LOG_FILE" 2>&1
    "$conda_exe" config --set always_yes false >> "$LOG_FILE" 2>&1
    
    success "Miniconda configuration completed"
}

# Install basic packages
install_basic_packages() {
    info "Installing basic packages..."
    
    local conda_exe="$INSTALL_PREFIX/bin/conda"
    local pip_exe="$INSTALL_PREFIX/bin/pip"
    
    # Update conda itself
    info "Updating conda..."
    if ! "$conda_exe" update -n base -c defaults conda -y >> "$LOG_FILE" 2>&1; then
        warning "Failed to update conda, continuing with existing version"
    fi
    
    # Install essential packages
    local packages=(
        "numpy"
        "pandas" 
        "requests"
        "setuptools"
        "wheel"
    )
    
    local failed_packages=()
    
    for package in "${packages[@]}"; do
        info "Installing $package..."
        if "$conda_exe" install -n base "$package" -y >> "$LOG_FILE" 2>&1; then
            success "$package installed successfully with conda"
        elif "$pip_exe" install "$package" >> "$LOG_FILE" 2>&1; then
            success "$package installed successfully with pip"
        else
            warning "Failed to install $package"
            failed_packages+=("$package")
        fi
    done
    
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        warning "Some packages failed to install: ${failed_packages[*]}"
        warning "You can install them manually later using: conda install ${failed_packages[*]}"
    fi
    
    success "Basic packages installation completed"
}

# Verify installation
verify_installation() {
    info "Verifying installation..."
    
    local conda_exe="$INSTALL_PREFIX/bin/conda"
    local python_exe="$INSTALL_PREFIX/bin/python"
    
    # Test conda
    if ! "$conda_exe" --version >> "$LOG_FILE" 2>&1; then
        error "Conda verification failed"
    fi
    
    # Test python
    if ! "$python_exe" --version >> "$LOG_FILE" 2>&1; then
        error "Python verification failed"
    fi
    
    # Test basic imports
    if ! "$python_exe" -c "import numpy, pandas; print('Basic packages working')" >> "$LOG_FILE" 2>&1; then
        warning "Some basic packages may not be working correctly"
    fi
    
    success "Installation verification completed"
}

# Show post-installation instructions
show_post_install() {
    echo ""
    echo "================================================================="
    echo "✅ Miniconda installation completed successfully!"
    echo "================================================================="
    echo ""
    echo "Installation location: $INSTALL_PREFIX"
    echo ""
    echo "To get started:"
    echo ""
    echo "1. Add conda to your PATH (if not done automatically):"
    echo "   export PATH=\"$INSTALL_PREFIX/bin:\$PATH\""
    echo ""
    echo "2. Initialize conda for your shell:"
    echo "   $INSTALL_PREFIX/bin/conda init bash"
    echo "   source ~/.bashrc"
    echo ""
    echo "3. Test your installation:"
    echo "   conda --version"
    echo "   python --version"
    echo ""
    echo "4. Create your first environment:"
    echo "   conda create -n myproject python=3.11 numpy pandas -y"
    echo "   conda activate myproject"
    echo ""
    echo "📖 For detailed usage instructions, see README.md"
    echo "🚀 For quick examples, see QUICKSTART.md"
    echo ""
    echo "Installation log: $LOG_FILE"
    echo ""
}

# Main installation function
main() {
    echo "================================================================="
    echo "🐍 Miniconda Offline Installer for RHEL 9"
    echo "================================================================="
    echo ""
    
    # Initialize log file
    echo "Installation started at $TIMESTAMP" > "$LOG_FILE"
    
    parse_args "$@"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "🔍 DRY RUN MODE - No actual installation will be performed"
        echo ""
        determine_install_dir
        echo "Would install to: $INSTALL_PREFIX"
        local installer_file
        installer_file=$(find_installer)
        echo "Found installer: $(basename "$installer_file")"
        echo ""
        echo "Installation steps that would be performed:"
        echo "1. Check system requirements"
        echo "2. Check for existing installation at $INSTALL_PREFIX"
        echo "3. Install Miniconda from $(basename "$installer_file")"
        echo "4. Configure Miniconda settings"
        echo "5. Install basic packages: numpy, pandas, requests, setuptools, wheel"
        echo "6. Verify installation"
        echo ""
        echo "To perform actual installation, run without --dry-run"
        exit 0
    fi
    
    check_requirements
    determine_install_dir
    check_existing_installation
    install_miniconda
    configure_miniconda
    install_basic_packages
    verify_installation
    show_post_install
}

# Run main function with all arguments
main "$@"
