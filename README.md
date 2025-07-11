# Offline Development Stacks for RHEL 9

A collection of complete offline development environments packaged for airgapped/isolated RHEL 9 systems. Each stack provides all necessary components for specific development workflows without requiring internet connectivity.

## 📦 Available Distributions

### 🐍 Miniconda Distribution
Complete Python environment manager for data science and development.
- **Location**: `miniconda/`
- **Components**: Miniconda3, conda package manager, essential Python packages
- **Use Case**: Python environment management, data science, scientific computing
- **Size**: ~150MB compressed
- **Features**: Environment isolation, package management, RHEL 9 optimized
- **Build**: `make miniconda`

### 📊 Analytics Stack
Comprehensive Python analytics and data science environment.
- **Location**: `analytics/`
- **Components**: NumPy, Pandas, SciPy, Matplotlib, Seaborn, Scikit-learn, JupyterLab
- **Use Case**: Data analysis, machine learning, statistical computing
- **Build**: `make analytics`

### 🔧 Ansible Development Environment
Complete Ansible automation and infrastructure-as-code toolkit.
- **Location**: `ansible/`
- **Components**: Ansible Core, Molecule testing, linting tools, development utilities
- **Use Case**: Infrastructure automation, configuration management, DevOps
- **Build**: `make ansible`

## 🚀 Quick Start

### Building All Distributions
```bash
# Build all distributions
make miniconda
make analytics  
make ansible
```

### Building Specific Distribution
```bash
# Build only Miniconda
make miniconda

# Build only Analytics stack
make analytics

# Build only Ansible environment
make ansible
```

### Deploying to Airgapped Systems

1. **Transfer the bundle** to your RHEL 9 system:
   ```bash
   scp miniconda-rhel9-20250711.tar.gz user@rhel9-host:~/
   scp analytics-stack-20250711.tar.gz user@rhel9-host:~/
   scp ansible-complete-20250711.tar.gz user@rhel9-host:~/
   ```

2. **Install on the target system**:
   ```bash
   # Extract and install
   tar -xzf miniconda-rhel9-20250711.tar.gz
   cd miniconda && bash install-miniconda-offline.sh
   
   # Or analytics stack
   tar -xzf analytics-stack-20250711.tar.gz
   cd analytics && bash install-offline.sh
   
   # Or ansible environment
   tar -xzf ansible-complete-20250711.tar.gz
   cd ansible && bash install-ansible-offline.sh
   ```

## 📋 System Requirements

### Target Systems
- **OS**: RHEL 9, Rocky Linux 9, AlmaLinux 9, or compatible
- **Architecture**: x86_64 (AMD64)
- **Memory**: Minimum 2GB RAM (4GB+ recommended)
- **Storage**: 2-10GB free space (depending on distribution)

### Build Systems
- Internet connectivity for downloading packages
- RHEL 9 or compatible Linux distribution
- Python 3.11+ available
- Standard build tools (`make`, `wget`, `tar`)

## 🛠️ Distribution Details

### Miniconda Distribution
- **Size**: ~500MB
- **Python Version**: 3.11+
- **Package Manager**: conda + pip
- **Key Features**:
  - Environment isolation
  - Package dependency resolution
  - Cross-platform compatibility
  - Scientific computing ready

### Analytics Stack
- **Size**: ~2GB
- **Python Version**: 3.11
- **Package Count**: 50+ packages
- **Key Features**:
  - Complete data science toolkit
  - Jupyter Lab environment
  - Machine learning libraries
  - Visualization tools

### Ansible Environment
- **Size**: ~1GB
- **Python Version**: 3.11
- **Package Count**: 100+ packages
- **Key Features**:
  - Ansible automation platform
  - Testing framework (Molecule)
  - Code quality tools
  - Development utilities

## 📖 Documentation

Each distribution includes comprehensive documentation:

- **README.md**: Complete setup and usage guide
- **QUICKSTART.md**: 5-minute quick start instructions
- **requirements.txt**: Package dependencies
- **install script**: Automated installation

## 🔧 Customization

### Custom Package Sets
```bash
# Analytics with custom packages
make PACKAGES="numpy pandas scikit-learn" analytics

# Different Python version
make PYTHON=python3.10 miniconda
```

### Custom Installation Paths
```bash
# Install to custom location
bash install-miniconda-offline.sh --prefix /opt/miniconda3
```

## 🏗️ Development

### Project Structure
```
.
├── analytics/          # Analytics stack
├── ansible/           # Ansible environment  
├── miniconda/         # Miniconda distribution
├── Makefile           # Main build system
├── LICENSE            # Project license
└── README.md          # This file
```

### Building From Source
```bash
# Clone repository
git clone <repo-url>
cd potential-adventure

# Build specific distribution
make miniconda

# Or build all
make miniconda analytics ansible
```

### Adding New Distributions

1. Create new folder following the existing pattern
2. Include: `README.md`, `QUICKSTART.md`, `Makefile.source`, `install-*.sh`
3. Add target to main `Makefile`
4. Test on target RHEL 9 system

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Test on RHEL 9 system
4. Submit pull request

## 📞 Support

### Troubleshooting

- Check system requirements
- Verify file permissions
- Review installation logs
- Test with minimal environment

### Common Issues

- **Insufficient disk space**: Clean up or allocate more storage
- **Permission denied**: Check file permissions and user access
- **Package conflicts**: Use fresh environment or force reinstall

## 📜 License

This project is licensed under the terms specified in the LICENSE file.

## 🏷️ Tags

`rhel9` `airgapped` `offline` `python` `miniconda` `analytics` `ansible` `data-science` `automation` `devops`

---

*Ready to deploy? Choose your distribution and follow the quick start guide!*
