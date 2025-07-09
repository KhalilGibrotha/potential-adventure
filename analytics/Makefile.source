# =====================================================================
#  Offline-wheel builder for RHEL 9 analytics stack
# =====================================================================
#
#   For AIRGAPPED systems: Download wheels on internet-connected host,
#   then transfer bundle to isolated environment.
#
#   USAGE:
#   make wheels          → downloads wheels into ./wheels/
#   make bundle          → wheels-YYYYMMDD.tar.gz ready for scp
#   make verify          → check bundle contents and statistics  
#   make requirements    → generate requirements.txt
#   make clean           → wipe wheels/, .venv/, tarball
#
#   Tunables at run-time:
#       make bundle PYTHON=python3.10            # use a specific interp
#       make bundle VENV_DIR=                    # skip virtualenv
#       make PACKAGES="numpy pandas" bundle      # custom package set
#
#   AIRGAPPED INSTALLATION:
#   1. Extract: tar -xzf wheels-YYYYMMDD.tar.gz
#   2. Install: pip install --find-links wheels --no-index <package>
# =====================================================================

# ---------- User-tweakable variables ---------------------------------
PYTHON     ?= $(shell command -v python3.11 2>/dev/null || command -v python3)
VENV_DIR   ?= .venv
WHEEL_DIR  ?= wheels
BUNDLE      = wheels-$(shell date +%Y%m%d).tar.gz

PACKAGES   ?= \
    numpy pandas scipy matplotlib seaborn statsmodels scikit-learn \
    pyarrow jupyterlab

# ---------- Derived variables ----------------------------------------
ifdef VENV_DIR
PIP_PYTHON := $(VENV_DIR)/bin/python
else
PIP_PYTHON := $(PYTHON)
endif
PIP         = $(PIP_PYTHON) -m pip
PIP_DL_FLAGS = --isolated --only-binary=:all: --dest $(WHEEL_DIR)

# ---------- Targets --------------------------------------------------
.PHONY: check_abi venv prepare wheels bundle verify requirements dist clean help verify requirements dist

## check_abi: abort if we're not building with CPython 3.11
check_abi:
	@$(PYTHON) -c "import sys, re, textwrap; \
		ver = f'cp{sys.version_info.major}{sys.version_info.minor}'; \
		sys.exit(0) if re.match(r'cp311', ver) else \
		sys.exit(textwrap.dedent(f'''\
			✖  Build interpreter is {ver}.\
			   RHEL 9 targets use CPython 3.11.\
			   Re-run with     make PYTHON=python3.11 …\
			   or install python3.11 on this host.\
		'''))"

## venv: create an isolated Python environment (if VENV_DIR is set)
ifdef VENV_DIR
$(VENV_DIR): check_abi
	@echo "==> Creating virtualenv '$(VENV_DIR)' with $(PYTHON)…"
	$(PYTHON) -m venv $(VENV_DIR)
	@echo "==> Upgrading pip inside venv…"
	$(PIP_PYTHON) -m pip install --upgrade pip setuptools wheel
venv: $(VENV_DIR)
else
venv: check_abi
	@echo "==> VENV_DIR disabled; using system $(PYTHON)"
endif

## prepare: ensure build directories exist
prepare: venv
	@mkdir -p $(WHEEL_DIR)

## wheels: download all requested packages (+ deps)
wheels: prepare
	@echo "==> Downloading wheels into '$(WHEEL_DIR)'…"
	$(PIP) download $(PIP_DL_FLAGS) $(PACKAGES)
	@echo "==> Downloaded $$(ls -1 $(WHEEL_DIR) | wc -l) wheels."

## bundle: tar-up the wheel directory
bundle: wheels
	@echo "==> Creating bundle '$(BUNDLE)'…"
	tar -czf $(BUNDLE) $(WHEEL_DIR)
	@echo "==> Bundle ready: $(BUNDLE)"

## clean: remove build artifacts
clean:
	@echo "==> Cleaning build artifacts…"
	rm -rf $(WHEEL_DIR) $(BUNDLE) $(VENV_DIR) requirements.txt analytics-stack-*.tar.gz dist-tmp

## verify: verify bundle contents and show statistics
verify:
	@if [ -f "$(BUNDLE)" ]; then \
		echo "==> Bundle: $(BUNDLE)"; \
		echo "==> Size: $$(du -h $(BUNDLE) | cut -f1)"; \
		echo "==> Contents:"; \
		tar -tzf $(BUNDLE) | head -10; \
		echo "... (total $$(tar -tzf $(BUNDLE) | wc -l) files)"; \
		echo "==> Wheel count: $$(tar -tzf $(BUNDLE) | grep -c '\.whl$$')"; \
	else \
		echo "❌ Bundle $(BUNDLE) not found. Run 'make bundle' first."; \
		exit 1; \
	fi

## requirements: generate requirements.txt from downloaded wheels
requirements: wheels
	@echo "==> Generating requirements.txt from wheels..."
	@$(PIP_PYTHON) -c "\
import os, re; \
wheels = [f for f in os.listdir('$(WHEEL_DIR)') if f.endswith('.whl')]; \
packages = set(); \
[packages.add(re.match(r'^([^-]+)', wheel).group(1).replace('_', '-')) for wheel in wheels if re.match(r'^([^-]+)', wheel)]; \
open('requirements.txt', 'w').writelines([pkg + '\n' for pkg in sorted(packages)])"
	@echo "==> Generated requirements.txt with $$(wc -l < requirements.txt) packages"

## dist: create complete distribution with installation script
dist: bundle requirements
	@echo "==> Creating complete distribution bundle..."
	@mkdir -p dist-tmp
	@cp $(BUNDLE) dist-tmp/
	@cp install-offline.sh dist-tmp/
	@cp requirements.txt dist-tmp/
	@cp Makefile dist-tmp/Makefile.source
	@echo "==> Creating README for airgapped installation..."
	@echo "# Analytics Stack for Airgapped Systems" > dist-tmp/README.md
	@echo "" >> dist-tmp/README.md
	@echo "This distribution contains Python wheels for a complete analytics stack including:" >> dist-tmp/README.md
	@echo "- NumPy, Pandas, SciPy" >> dist-tmp/README.md
	@echo "- Matplotlib, Seaborn" >> dist-tmp/README.md
	@echo "- Scikit-learn, Statsmodels" >> dist-tmp/README.md
	@echo "- PyArrow, JupyterLab" >> dist-tmp/README.md
	@echo "" >> dist-tmp/README.md
	@echo "## Quick Installation" >> dist-tmp/README.md
	@echo "" >> dist-tmp/README.md
	@echo "\`\`\`bash" >> dist-tmp/README.md
	@echo "bash install-offline.sh $(BUNDLE)" >> dist-tmp/README.md
	@echo "\`\`\`" >> dist-tmp/README.md
	@echo "" >> dist-tmp/README.md
	@echo "Generated on: $(shell date)" >> dist-tmp/README.md
	@tar -czf analytics-stack-$(shell date +%Y%m%d).tar.gz -C dist-tmp .
	@rm -rf dist-tmp
	@echo "==> Complete distribution ready: analytics-stack-$(shell date +%Y%m%d).tar.gz"

## help: print this list
help:
	@echo "Available targets:"
	@echo "  check_abi    - Verify CPython 3.11 is available"
	@echo "  venv         - Create virtual environment (.venv)"
	@echo "  prepare      - Ensure build directories exist"
	@echo "  wheels       - Download all Python wheels"
	@echo "  bundle       - Create tar.gz bundle for airgapped transfer"
	@echo "  verify       - Verify bundle contents"
	@echo "  requirements - Generate requirements.txt from wheels"
	@echo "  dist         - Create complete distribution with installer"
	@echo "  clean        - Remove all build artifacts"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Usage examples:"
	@echo "  make dist                                # Complete distribution"
	@echo "  make bundle                              # Just wheel bundle"
	@echo "  make PACKAGES=\"numpy pandas\" dist       # Custom packages"
	@echo "  make PYTHON=python3.10 dist             # Different Python version"
