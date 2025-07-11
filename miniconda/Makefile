# =====================================================================
#  Miniconda Offline Packager for RHEL 9 Systems
# =====================================================================
#
#   For AIRGAPPED RHEL 9 systems: Download Miniconda installer on 
#   internet-connected host, then transfer bundle to isolated environment.
#
#   USAGE:
#   make download         → downloads Miniconda installer
#   make package          → creates offline installation package  
#   make bundle           → miniconda-rhel9-YYYYMMDD.tar.gz ready for transfer
#   make verify           → check bundle contents and verify installer
#   make clean            → remove downloads and temporary files
#   make test-install     → test installation in local directory
#
#   Tunables at run-time:
#       make download PYTHON_VERSION=3.11    # specific Python version
#       make package INSTALL_PREFIX=/opt     # custom install location
#       make bundle ARCH=x86_64              # specify architecture
#
#   AIRGAPPED INSTALLATION:
#   1. Transfer: scp miniconda-rhel9-YYYYMMDD.tar.gz target-host:~/
#   2. Extract: tar -xzf miniconda-rhel9-YYYYMMDD.tar.gz
#   3. Install: cd miniconda && bash install-miniconda-offline.sh
# =====================================================================

# ---------- User-tweakable variables ---------------------------------
PYTHON_VERSION  ?= latest
ARCH            ?= x86_64
PLATFORM        ?= Linux
DOWNLOAD_DIR    ?= downloads
PACKAGE_DIR     ?= package
BUNDLE_NAME     ?= miniconda-rhel9-$(shell date +%Y%m%d).tar.gz
INSTALLER_URL   ?= https://repo.anaconda.com/miniconda/Miniconda3-$(PYTHON_VERSION)-$(PLATFORM)-$(ARCH).sh

# ---------- Derived variables ----------------------------------------
INSTALLER_FILE  = $(DOWNLOAD_DIR)/Miniconda3-$(PYTHON_VERSION)-$(PLATFORM)-$(ARCH).sh
SCRIPT_DIR      = $(shell pwd)

# ---------- Targets --------------------------------------------------
.PHONY: help download package bundle verify clean test-install all

## Default target
all: bundle

## help: Show this help message
help:
	@echo "Miniconda Offline Packager for RHEL 9"
	@echo ""
	@echo "Usage:"
	@echo "  make download    - Download Miniconda installer"
	@echo "  make package     - Create offline installation package"
	@echo "  make bundle      - Create redistributable bundle"
	@echo "  make verify      - Verify bundle contents"
	@echo "  make clean       - Clean up downloads and build files"
	@echo "  make test-install - Test installation locally"
	@echo "  make all         - Download, package, and bundle (default)"
	@echo ""
	@echo "Options:"
	@echo "  PYTHON_VERSION=3.11  - Specific Python version (default: latest)"
	@echo "  ARCH=x86_64          - Architecture (default: x86_64)"
	@echo "  DOWNLOAD_DIR=path    - Download directory (default: downloads)"
	@echo ""
	@echo "Example:"
	@echo "  make bundle PYTHON_VERSION=py311"

## download: Download Miniconda installer
download: $(INSTALLER_FILE)

$(INSTALLER_FILE):
	@echo "📥 Downloading Miniconda installer..."
	@mkdir -p $(DOWNLOAD_DIR)
	@if [ "$(PYTHON_VERSION)" = "latest" ]; then \
		LATEST_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-$(PLATFORM)-$(ARCH).sh"; \
		echo "Downloading latest version from: $$LATEST_URL"; \
		wget -O $@ "$$LATEST_URL" || curl -L -o $@ "$$LATEST_URL"; \
	else \
		echo "Downloading specific version from: $(INSTALLER_URL)"; \
		wget -O $@ "$(INSTALLER_URL)" || curl -L -o $@ "$(INSTALLER_URL)"; \
	fi
	@chmod +x $@
	@echo "✅ Downloaded: $@"
	@ls -lh $@

## package: Create offline installation package
package: download
	@echo "📦 Creating offline installation package..."
	@mkdir -p $(PACKAGE_DIR)
	
	# Copy installer
	@cp $(INSTALLER_FILE) $(PACKAGE_DIR)/
	
	# Copy installation scripts and documentation
	@cp install-miniconda-offline.sh $(PACKAGE_DIR)/
	@cp README.md $(PACKAGE_DIR)/
	@cp QUICKSTART.md $(PACKAGE_DIR)/
	@cp requirements.txt $(PACKAGE_DIR)/
	
	# Make install script executable
	@chmod +x $(PACKAGE_DIR)/install-miniconda-offline.sh
	
	# Create environment specification file
	@echo "# Miniconda Environment Specification" > $(PACKAGE_DIR)/environment.yml
	@echo "name: base" >> $(PACKAGE_DIR)/environment.yml
	@echo "channels:" >> $(PACKAGE_DIR)/environment.yml
	@echo "  - defaults" >> $(PACKAGE_DIR)/environment.yml
	@echo "  - conda-forge" >> $(PACKAGE_DIR)/environment.yml
	@echo "dependencies:" >> $(PACKAGE_DIR)/environment.yml
	@echo "  - python>=3.11" >> $(PACKAGE_DIR)/environment.yml
	@echo "  - numpy" >> $(PACKAGE_DIR)/environment.yml
	@echo "  - pandas" >> $(PACKAGE_DIR)/environment.yml
	@echo "  - requests" >> $(PACKAGE_DIR)/environment.yml
	@echo "  - pip" >> $(PACKAGE_DIR)/environment.yml
	
	# Create package information file
	@echo "PACKAGE_NAME=miniconda-rhel9" > $(PACKAGE_DIR)/package-info.txt
	@echo "PACKAGE_VERSION=$(shell date +%Y%m%d)" >> $(PACKAGE_DIR)/package-info.txt
	@echo "PYTHON_VERSION=$(PYTHON_VERSION)" >> $(PACKAGE_DIR)/package-info.txt
	@echo "ARCHITECTURE=$(ARCH)" >> $(PACKAGE_DIR)/package-info.txt
	@echo "PLATFORM=$(PLATFORM)" >> $(PACKAGE_DIR)/package-info.txt
	@echo "BUILD_DATE=$(shell date -u +%Y-%m-%dT%H:%M:%SZ)" >> $(PACKAGE_DIR)/package-info.txt
	@echo "BUILD_HOST=$(shell hostname)" >> $(PACKAGE_DIR)/package-info.txt
	
	@echo "✅ Package created in $(PACKAGE_DIR)/"

## bundle: Create redistributable tar.gz bundle
bundle: package
	@echo "🗜️  Creating redistributable bundle..."
	@tar -czf $(BUNDLE_NAME) -C $(PACKAGE_DIR) .
	@echo "✅ Bundle created: $(BUNDLE_NAME)"
	@ls -lh $(BUNDLE_NAME)
	@echo ""
	@echo "📋 Bundle ready for transfer to airgapped RHEL 9 systems"
	@echo "   Transfer command: scp $(BUNDLE_NAME) user@rhel9-host:~/"
	@echo "   Install command:  tar -xzf $(BUNDLE_NAME) && cd miniconda && bash install-miniconda-offline.sh"

## verify: Verify bundle contents and installer
verify:
	@echo "🔍 Verifying bundle contents..."
	@if [ ! -f $(BUNDLE_NAME) ]; then \
		echo "❌ Bundle not found: $(BUNDLE_NAME)"; \
		echo "   Run 'make bundle' first"; \
		exit 1; \
	fi
	
	@echo "📦 Bundle contents:"
	@tar -tzf $(BUNDLE_NAME) | head -20
	
	@echo ""
	@echo "📊 Bundle statistics:"
	@echo "   Size: $$(ls -lh $(BUNDLE_NAME) | awk '{print $$5}')"
	@echo "   Files: $$(tar -tzf $(BUNDLE_NAME) | wc -l)"
	
	# Verify installer if available
	@if [ -f $(INSTALLER_FILE) ]; then \
		echo ""; \
		echo "🧪 Verifying Miniconda installer..."; \
		bash $(INSTALLER_FILE) -h | head -5; \
		echo "✅ Installer verification passed"; \
	fi
	
	@echo ""
	@echo "✅ Bundle verification completed"

## test-install: Test installation in local directory
test-install: package
	@echo "🧪 Testing installation locally..."
	@rm -rf test-install/
	@mkdir -p test-install/
	@cd test-install && tar -xzf ../$(BUNDLE_NAME)
	@cd test-install && bash install-miniconda-offline.sh --prefix $(SCRIPT_DIR)/test-install/miniconda3 --silent
	@echo "🔍 Testing conda installation..."
	@$(SCRIPT_DIR)/test-install/miniconda3/bin/conda --version
	@$(SCRIPT_DIR)/test-install/miniconda3/bin/python --version
	@$(SCRIPT_DIR)/test-install/miniconda3/bin/python -c "import sys; print(f'Python {sys.version[:5]} at {sys.executable}')"
	@echo "✅ Local installation test passed"
	@echo "🧹 Cleaning up test installation..."
	@rm -rf test-install/

## clean: Remove downloads and build files
clean:
	@echo "🧹 Cleaning up..."
	@rm -rf $(DOWNLOAD_DIR)/
	@rm -rf $(PACKAGE_DIR)/
	@rm -f miniconda-rhel9-*.tar.gz
	@rm -rf test-install/
	@echo "✅ Cleanup completed"

## info: Show current configuration
info:
	@echo "Current configuration:"
	@echo "  Python Version: $(PYTHON_VERSION)"
	@echo "  Architecture:   $(ARCH)"
	@echo "  Platform:       $(PLATFORM)"
	@echo "  Download Dir:   $(DOWNLOAD_DIR)"
	@echo "  Package Dir:    $(PACKAGE_DIR)"
	@echo "  Bundle Name:    $(BUNDLE_NAME)"
	@echo "  Installer URL:  $(INSTALLER_URL)"

# Include source makefile if it exists (for additional targets)
-include Makefile.source
