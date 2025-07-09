# Quick Start Guide

## 🚀 For Airgapped Systems

### 1. Extract Distribution
```bash
tar -xzf analytics-complete-20250709.tar.gz
cd analytics/
```

### 2. Run Installation
```bash
bash install-offline.sh wheels-20250709.tar.gz
```

### 3. Activate Environment
```bash
source venv-analytics/bin/activate
```

### 4. Test Installation
```bash
python -c "import numpy, pandas, matplotlib; print('✓ Analytics stack ready!')"
```

### 5. Start JupyterLab
```bash
jupyter lab
```

## 📁 What's Included

- **README.md** - Complete documentation
- **install-offline.sh** - Automated installer
- **wheels-20250709.tar.gz** - Python packages (181MB)
- **requirements.txt** - Package list (110 packages)
- **Makefile.source** - Build configuration

## 🔧 Custom Options

```bash
# Different virtual environment name
VENV_DIR=my-env bash install-offline.sh wheels-20250709.tar.gz

# Different Python version
PYTHON=python3.10 bash install-offline.sh wheels-20250709.tar.gz
```

## 📊 Included Libraries

- **Data**: NumPy, Pandas, PyArrow
- **Visualization**: Matplotlib, Seaborn
- **ML**: Scikit-learn, Statsmodels
- **Development**: JupyterLab, IPython

---
*See README.md for complete documentation*
