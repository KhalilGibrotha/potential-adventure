# Quick Start: Miniconda for RHEL 9 Airgapped Systems

## 🚀 5-Minute Setup

### Step 1: Transfer Files
```bash
# Copy to your airgapped RHEL 9 system
scp miniconda-rhel9-20250711.tar.gz user@rhel9-host:~/
```

### Step 2: Install
```bash
# On the airgapped system
tar -xzf miniconda-rhel9-20250711.tar.gz
cd miniconda/
bash install-miniconda-offline.sh
```

### Step 3: Initialize
```bash
# Initialize conda for your shell
~/miniconda3/bin/conda init bash
source ~/.bashrc

# Verify installation
conda --version
python --version
```

### Step 4: Create Environment
```bash
# Create your first environment
conda create -n myproject python=3.11 numpy pandas -y
conda activate myproject

# Test it works
python -c "import numpy, pandas; print('Ready to go!')"
```

## 🎯 Common Use Cases

### Data Science Environment
```bash
conda create -n datascience python=3.11 numpy pandas matplotlib jupyter scipy -y
conda activate datascience
jupyter lab  # Start Jupyter Lab
```

### Web Development Environment  
```bash
conda create -n webapp python=3.11 flask requests -y
conda activate webapp
python -m flask --version
```

### Machine Learning Environment
```bash
conda create -n ml python=3.11 numpy pandas scikit-learn -y
conda activate ml
python -c "import sklearn; print(f'scikit-learn {sklearn.__version__} ready')"
```

## 🔧 Essential Commands

```bash
# Environment management
conda env list              # List all environments
conda activate <name>       # Activate environment
conda deactivate            # Deactivate current environment
conda env remove -n <name>  # Delete environment

# Package management
conda list                  # List installed packages
conda install <package>     # Install package
conda update <package>      # Update package
conda remove <package>      # Remove package

# System management
conda info                  # System information
conda clean --all          # Clean package cache
conda config --show        # Show configuration
```

## ⚠️ Troubleshooting Quick Fixes

### "conda: command not found"
```bash
export PATH="$HOME/miniconda3/bin:$PATH"
source ~/.bashrc
```

### Permission denied
```bash
chmod +x install-miniconda-offline.sh
```

### Check installation
```bash
ls -la ~/miniconda3/bin/conda
~/miniconda3/bin/conda --version
```

## 📦 What's Included

- ✅ Miniconda3 (Python 3.11+)
- ✅ Conda package manager
- ✅ Pip package installer
- ✅ Essential packages: numpy, pandas, requests
- ✅ Environment management tools
- ✅ RHEL 9 x86_64 compatibility

## 📞 Need Help?

1. Check `README.md` for detailed documentation
2. Run `conda doctor` to diagnose issues
3. Check logs at `/tmp/miniconda-install.log`
4. Verify with: `conda info --all`

---
*Ready to start? Run the install script and you'll be up and running in under 5 minutes!*
