#!/bin/bash
# =====================================================================
# Miniconda Bundle Validation Script
# =====================================================================
#
# This script validates the miniconda bundle and tests all installation
# options to ensure everything works correctly before deployment.
#
# Usage:
#   bash validate-miniconda-bundle.sh [BUNDLE_FILE]
#
# =====================================================================

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLE_FILE="${1:-miniconda-rhel9-$(date +%Y%m%d).tar.gz}"
TEST_DIR="validation-test"
LOG_FILE="/tmp/miniconda-validation.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S'): $*" >> "$LOG_FILE"
    echo -e "$*"
}

error() {
    log "${RED}❌ ERROR: $*${NC}" >&2
    exit 1
}

warning() {
    log "${YELLOW}⚠️  WARNING: $*${NC}"
}

info() {
    log "${BLUE}ℹ️  INFO: $*${NC}"
}

success() {
    log "${GREEN}✅ SUCCESS: $*${NC}"
}

# Cleanup function
cleanup() {
    if [[ -d "$TEST_DIR" ]]; then
        info "Cleaning up test directory: $TEST_DIR"
        rm -rf "$TEST_DIR"
    fi
}

# Set trap for cleanup
trap cleanup EXIT

# Validate bundle exists
validate_bundle_exists() {
    info "Validating bundle file: $BUNDLE_FILE"
    
    if [[ ! -f "$BUNDLE_FILE" ]]; then
        error "Bundle file not found: $BUNDLE_FILE"
    fi
    
    # Check file size (should be > 100MB for Miniconda)
    local file_size=$(stat -c%s "$BUNDLE_FILE")
    local min_size=$((100 * 1024 * 1024)) # 100MB
    
    if [[ $file_size -lt $min_size ]]; then
        error "Bundle file too small: $(($file_size / 1024 / 1024))MB (expected > 100MB)"
    fi
    
    success "Bundle file validation passed: $(($file_size / 1024 / 1024))MB"
}

# Extract and validate bundle contents
validate_bundle_contents() {
    info "Extracting and validating bundle contents..."
    
    # Create test directory and extract
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    if ! tar -xzf "../$BUNDLE_FILE"; then
        error "Failed to extract bundle"
    fi
    
    # Check required files
    local required_files=(
        "install-miniconda-offline.sh"
        "README.md"
        "QUICKSTART.md"
        "requirements.txt"
        "environment.yml"
        "package-info.txt"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            error "Required file missing: $file"
        fi
    done
    
    # Check for Miniconda installer
    local installer_count=$(find . -name "Miniconda3-*-Linux-x86_64.sh" | wc -l)
    if [[ $installer_count -eq 0 ]]; then
        error "Miniconda installer not found"
    elif [[ $installer_count -gt 1 ]]; then
        warning "Multiple Miniconda installers found"
    fi
    
    # Check installer is executable
    local installer=$(find . -name "Miniconda3-*-Linux-x86_64.sh" | head -1)
    if [[ ! -x "$installer" ]]; then
        error "Miniconda installer is not executable: $installer"
    fi
    
    # Check install script is executable
    if [[ ! -x "install-miniconda-offline.sh" ]]; then
        error "Install script is not executable"
    fi
    
    success "Bundle contents validation passed"
    cd "$SCRIPT_DIR"
}

# Test dry-run installation
test_dry_run() {
    info "Testing dry-run installation..."
    
    cd "$TEST_DIR"
    
    if ! bash install-miniconda-offline.sh --dry-run; then
        error "Dry-run test failed"
    fi
    
    success "Dry-run test passed"
    cd "$SCRIPT_DIR"
}

# Test help functionality
test_help() {
    info "Testing help functionality..."
    
    cd "$TEST_DIR"
    
    if ! bash install-miniconda-offline.sh --help > /dev/null; then
        error "Help test failed"
    fi
    
    success "Help test passed"
    cd "$SCRIPT_DIR"
}

# Test actual installation
test_installation() {
    info "Testing actual installation..."
    
    cd "$TEST_DIR"
    
    local test_prefix="$PWD/test-miniconda"
    
    # Test installation
    if ! bash install-miniconda-offline.sh --prefix "$test_prefix" --silent; then
        error "Installation test failed"
    fi
    
    # Verify installation
    if [[ ! -d "$test_prefix" ]]; then
        error "Installation directory not created: $test_prefix"
    fi
    
    # Test conda executable
    local conda_exe="$test_prefix/bin/conda"
    if [[ ! -x "$conda_exe" ]]; then
        error "Conda executable not found or not executable: $conda_exe"
    fi
    
    # Test conda version
    if ! "$conda_exe" --version > /dev/null; then
        error "Conda version check failed"
    fi
    
    # Test python executable
    local python_exe="$test_prefix/bin/python"
    if [[ ! -x "$python_exe" ]]; then
        error "Python executable not found: $python_exe"
    fi
    
    # Test python version
    if ! "$python_exe" --version > /dev/null; then
        error "Python version check failed"
    fi
    
    # Test basic imports
    if ! "$python_exe" -c "import sys; print('Python version:', sys.version)" > /dev/null; then
        error "Basic Python test failed"
    fi
    
    # Test installed packages
    local packages=("numpy" "pandas" "requests")
    for package in "${packages[@]}"; do
        if "$python_exe" -c "import $package" 2>/dev/null; then
            success "Package $package imported successfully"
        else
            warning "Package $package not available (this may be expected if installation had issues)"
        fi
    done
    
    success "Installation test passed"
    cd "$SCRIPT_DIR"
}

# Generate validation report
generate_report() {
    info "Generating validation report..."
    
    local report_file="validation-report-$(date +%Y%m%d-%H%M%S).txt"
    
    cat > "$report_file" << EOF
================================================================
Miniconda Bundle Validation Report
================================================================

Bundle File: $BUNDLE_FILE
Test Date: $(date)
Test Host: $(hostname)
Test User: $(whoami)

Bundle Information:
- Size: $(stat -c%s "$BUNDLE_FILE" | awk '{print int($1/1024/1024) "MB"}')
- MD5: $(md5sum "$BUNDLE_FILE" | cut -d' ' -f1)

Package Information:
$(cd "$TEST_DIR" && cat package-info.txt 2>/dev/null || echo "Package info not available")

Test Results:
✅ Bundle file validation: PASSED
✅ Bundle contents validation: PASSED  
✅ Dry-run test: PASSED
✅ Help functionality test: PASSED
✅ Installation test: PASSED

Installation Details:
$(cd "$TEST_DIR/test-miniconda/bin" 2>/dev/null && {
    echo "- Conda version: $(./conda --version 2>/dev/null || echo 'N/A')"
    echo "- Python version: $(./python --version 2>/dev/null || echo 'N/A')"
    echo "- Installation size: $(du -sh ../.. 2>/dev/null | cut -f1 || echo 'N/A')"
} || echo "Installation details not available")

Validation completed successfully!
The bundle is ready for deployment to RHEL 9 systems.

================================================================
EOF

    success "Validation report generated: $report_file"
}

# Main validation function
main() {
    echo "================================================================="
    echo "🔍 Miniconda Bundle Validation"
    echo "================================================================="
    echo ""
    
    # Initialize log
    echo "Validation started at $(date)" > "$LOG_FILE"
    
    validate_bundle_exists
    validate_bundle_contents
    test_help
    test_dry_run
    test_installation
    generate_report
    
    echo ""
    echo "================================================================="
    echo "✅ All validation tests passed!"
    echo "================================================================="
    echo ""
    echo "The Miniconda bundle is ready for deployment to RHEL 9 systems."
    echo "Log file: $LOG_FILE"
    echo ""
}

# Run main function
main "$@"
