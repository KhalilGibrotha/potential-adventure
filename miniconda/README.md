# Miniconda Distribution for Airgapped RHEL 9 Systems

A complete Miniconda Python distribution packaged for airgapped/isolated RHEL 9 systems. This bundle provides a self-contained Python environment manager that can be deployed without internet connectivity.

## 📦 Package Contents

This distribution provides:

### Core Components
- **Miniconda3** - Minimal conda installer with Python 3.11+
- **Conda Package Manager** - Environment and package management
- **Pip** - Python package installer
- **Essential Packages** - Core scientific computing libraries

### Pre-installed Packages
- **numpy** - Numerical computing with arrays
- **pandas** - Data manipulation and analysis
- **requests** - HTTP library for API interactions
- **setuptools** - Python package development tools
- **wheel** - Python wheel package format

### Environment Management
- **conda** - Create and manage isolated Python environments
- **conda-build** - Build conda packages from source
- **conda-env** - Environment specification files

## 🚀 Quick Start

### For Airgapped Installation

1. **Transfer the distribution** to your airgapped RHEL 9 system:
   ```bash
   scp miniconda-rhel9-20250711.tar.gz target-host:~/
   ```

2. **Extract and install**:
   ```bash
   tar -xzf miniconda-rhel9-20250711.tar.gz
   cd miniconda/
   bash install-miniconda-offline.sh
   ```

3. **Initialize and test**:
   ```bash
   # Initialize conda for your shell
   ~/miniconda3/bin/conda init bash
   
   # Restart your shell or source bashrc
   source ~/.bashrc
   
   # Test installation
   conda --version
   python --version
   
   # Create a test environment
   conda create -n test python=3.11 numpy pandas -y
   conda activate test
   python -c "import numpy, pandas; print('Miniconda ready!')"
   ```

## 🛠️ Building the Package

### Prerequisites

- Internet-connected RHEL 9 or compatible Linux system
- At least 2GB free disk space
- `wget` and `bash` available

### Build Process

1. **Download and package Miniconda**:
   ```bash
   make package
   ```

2. **Create redistributable bundle**:
   ```bash
   make bundle
   ```

3. **Verify the package**:
   ```bash
   make verify
   ```

## 📋 Detailed Installation Guide

### System Requirements

- **Operating System**: RHEL 9, Rocky Linux 9, AlmaLinux 9, or compatible
- **Architecture**: x86_64 (AMD64)
- **Memory**: Minimum 1GB RAM (2GB+ recommended)
- **Storage**: Minimum 2GB free space
- **User Permissions**: Regular user (no root required for user installation)

### Installation Options

#### Option 1: User Installation (Recommended)
```bash
# Install for current user only (no admin rights needed)
bash install-miniconda-offline.sh --user
```

#### Option 2: System-wide Installation
```bash
# Requires root privileges
sudo bash install-miniconda-offline.sh --system
```

#### Option 3: Custom Location
```bash
# Install to specific directory
bash install-miniconda-offline.sh --prefix /opt/miniconda3
```

### Post-Installation Configuration

1. **Shell Integration**:
   ```bash
   # For bash users
   ~/miniconda3/bin/conda init bash
   
   # For zsh users  
   ~/miniconda3/bin/conda init zsh
   
   # For fish users
   ~/miniconda3/bin/conda init fish
   ```

2. **Environment Variables**:
   ```bash
   # Add to ~/.bashrc or ~/.profile
   export PATH="$HOME/miniconda3/bin:$PATH"
   ```

3. **Conda Configuration**:
   ```bash
   # Set conda to not auto-activate base environment
   conda config --set auto_activate_base false
   
   # Set up conda channels (for when internet becomes available)
   conda config --add channels conda-forge
   conda config --add channels bioconda
   ```

## 🔧 Environment Management

### Creating Environments

```bash
# Create a basic data science environment
conda create -n datascience python=3.11 numpy pandas matplotlib jupyter -y

# Create environment from requirements file
conda create -n myproject --file environment.yml

# Create environment with specific Python version
conda create -n python39 python=3.9 -y
```

### Managing Environments

```bash
# List all environments
conda env list

# Activate environment
conda activate datascience

# Deactivate environment
conda deactivate

# Remove environment
conda env remove -n datascience
```

### Package Management

```bash
# Install packages in active environment
conda install scipy scikit-learn

# Install from pip when conda package unavailable
pip install some-package

# Update packages
conda update --all

# List installed packages
conda list
```

## 📦 Offline Package Management

### Adding Packages to Offline Environment

When you regain internet connectivity, you can download packages for offline use:

```bash
# Download packages without installing
conda install --download-only numpy pandas scipy

# Create offline package cache
conda create -n build-env --download-only python=3.11 numpy pandas

# Package the downloads for transfer
tar -czf conda-packages.tar.gz ~/miniconda3/pkgs/
```

### Installing Downloaded Packages

```bash
# Extract package cache
tar -xzf conda-packages.tar.gz -C ~/miniconda3/

# Install from local cache
conda install --offline numpy pandas scipy
```

## 🔍 Troubleshooting

### Common Issues

#### 1. "conda: command not found"
```bash
# Add conda to PATH
export PATH="$HOME/miniconda3/bin:$PATH"

# Or run conda init again
~/miniconda3/bin/conda init bash
source ~/.bashrc
```

#### 2. Permission denied during installation
```bash
# Ensure the installation script is executable
chmod +x install-miniconda-offline.sh

# Check file ownership
ls -la install-miniconda-offline.sh
```

#### 3. Insufficient disk space
```bash
# Check available space
df -h $HOME

# Clean conda cache
conda clean --all
```

#### 4. SSL/Certificate errors (when internet available)
```bash
# Configure conda to use system certificates
conda config --set ssl_verify true

# Or disable SSL verification (not recommended for production)
conda config --set ssl_verify false
```

### Environment Debugging

```bash
# Check conda info
conda info

# Check environment details
conda info --envs

# Verify conda installation
conda doctor

# Check package dependencies
conda list --explicit > package-list.txt
```

## 📖 Additional Resources

### Documentation Links
- [Conda User Guide](https://docs.conda.io/projects/conda/en/latest/user-guide/)
- [Managing Environments](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html)
- [Managing Packages](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-pkgs.html)

### Best Practices

1. **Use environment files** (`environment.yml`) for reproducible environments
2. **Pin versions** for critical packages in production
3. **Regular cleanup** of package cache to save space
4. **Backup environments** before major changes
5. **Use virtual environments** for project isolation

### Security Considerations

- Verify package checksums when possible
- Use official conda channels when internet is available
- Keep conda and packages updated for security patches
- Review package dependencies before installation

## 📞 Support

For issues specific to this offline distribution:
1. Check the troubleshooting section above
2. Verify system requirements are met
3. Test with a minimal environment first
4. Check the installation logs in `/tmp/miniconda-install.log`

For general conda issues, refer to the official conda documentation and community forums.
