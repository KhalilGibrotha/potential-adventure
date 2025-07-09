# Analytics Stack for Airgapped Systems

A complete offline Python analytics environment packaged for airgapped/isolated systems running RHEL 9 or compatible Linux distributions.

## 📦 Package Contents

This distribution provides a full-featured analytics stack including:

### Core Libraries
- **NumPy** - Numerical computing with arrays
- **Pandas** - Data manipulation and analysis
- **SciPy** - Scientific computing algorithms

### Visualization
- **Matplotlib** - Comprehensive plotting library
- **Seaborn** - Statistical data visualization

### Machine Learning
- **Scikit-learn** - Machine learning algorithms
- **Statsmodels** - Statistical modeling

### Data Processing
- **PyArrow** - Fast columnar data processing

### Development Environment
- **JupyterLab** - Interactive data science notebook environment

## 🚀 Quick Start

### For Airgapped Installation

1. **Transfer the distribution** to your airgapped system:
   ```bash
   scp analytics-stack-20250709.tar.gz target-host:~/
   ```

2. **Extract and install**:
   ```bash
   tar -xzf analytics-stack-20250709.tar.gz
   cd analytics/
   bash install-offline.sh wheels-20250709.tar.gz
   ```

3. **Activate and test**:
   ```bash
   source venv-analytics/bin/activate
   python -c "import numpy, pandas; print('Analytics stack ready!')"
   jupyter lab  # Start JupyterLab
   ```

## 📋 System Requirements

- **Operating System**: RHEL 9, CentOS 9, Rocky Linux 9, or compatible
- **Python**: 3.11 (required for binary compatibility)
- **Disk Space**: ~500MB for full installation
- **Memory**: 2GB+ recommended for data analysis

## 🛠 Installation Methods

### Method 1: Automated Installation (Recommended)

The included `install-offline.sh` script handles everything automatically:

```bash
bash install-offline.sh wheels-20250709.tar.gz
```

**Features:**
- ✅ Automatic Python version detection
- ✅ Virtual environment creation
- ✅ Package installation with dependency resolution  
- ✅ Post-installation verification
- ✅ Colored output with progress indicators
- ✅ Error handling and rollback

### Method 2: Manual Installation

For custom installations or troubleshooting:

1. **Extract wheels**:
   ```bash
   tar -xzf wheels-20250709.tar.gz
   ```

2. **Create virtual environment**:
   ```bash
   python3.11 -m venv analytics-env
   source analytics-env/bin/activate
   ```

3. **Upgrade pip tools**:
   ```bash
   pip install --find-links wheels --no-index --upgrade pip setuptools wheel
   ```

4. **Install packages**:
   ```bash
   # Core analytics stack
   pip install --find-links wheels --no-index numpy pandas scipy matplotlib seaborn statsmodels scikit-learn pyarrow

   # JupyterLab environment  
   pip install --find-links wheels --no-index jupyterlab
   ```

5. **Verify installation**:
   ```bash
   python -c "import numpy, pandas, scipy, matplotlib, seaborn, sklearn, pyarrow; print('All packages imported successfully!')"
   ```

## 🔧 Configuration Options

### Environment Variables

- `VENV_DIR` - Virtual environment directory (default: `venv-analytics`)
- `PYTHON` - Python interpreter to use (default: `python3.11`)

### Custom Installation Examples

```bash
# Use different virtual environment name
VENV_DIR=my-analytics bash install-offline.sh wheels-20250709.tar.gz

# Use different Python version (if available)
PYTHON=python3.10 bash install-offline.sh wheels-20250709.tar.gz

# Install to specific location
cd /opt/analytics && bash install-offline.sh /path/to/wheels-20250709.tar.gz
```

## 📊 Usage Examples

### Basic Data Analysis

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# Load data
df = pd.read_csv('data.csv')

# Basic statistics
print(df.describe())

# Visualization
plt.figure(figsize=(10, 6))
sns.histplot(df['column_name'])
plt.show()
```

### Machine Learning

```python
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score

# Prepare data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Train model
model = RandomForestClassifier()
model.fit(X_train, y_train)

# Evaluate
predictions = model.predict(X_test)
accuracy = accuracy_score(y_test, predictions)
print(f"Accuracy: {accuracy:.2f}")
```

### JupyterLab Usage

```bash
# Start JupyterLab server
source venv-analytics/bin/activate
jupyter lab

# Access via browser at: http://localhost:8888
```

## 🔍 Verification & Troubleshooting

### Package Verification

```bash
# Check all installed packages
pip list

# Verify specific imports
python -c "
import numpy as np
import pandas as pd
import scipy
print(f'NumPy: {np.__version__}')
print(f'Pandas: {pd.__version__}')
print(f'SciPy: {scipy.__version__}')
"
```

### Common Issues

**Problem**: `ModuleNotFoundError` after installation
```bash
# Solution: Ensure virtual environment is activated
source venv-analytics/bin/activate
```

**Problem**: Permission denied errors
```bash
# Solution: Install to user directory or use different location
VENV_DIR=~/analytics-env bash install-offline.sh wheels-20250709.tar.gz
```

**Problem**: Python 3.11 not found
```bash
# Solution: Install Python 3.11 or use alternative
# RHEL 9: dnf install python3.11
# Or specify different Python: PYTHON=python3.9 bash install-offline.sh ...
```

## 📁 File Structure

```
analytics/
├── README.md                    # This documentation
├── install-offline.sh           # Automated installation script
├── requirements.txt             # Package list (110 packages)
├── wheels-20250709.tar.gz      # Wheel bundle (181MB)
├── Makefile.source             # Source build configuration
└── analytics-stack-20250709.tar.gz  # Complete distribution
```

## 🏗 Building from Source

For administrators who want to customize the package list:

1. **Edit the source Makefile**:
   ```bash
   # Modify PACKAGES variable in Makefile.source
   PACKAGES = numpy pandas scipy matplotlib seaborn my-custom-package
   ```

2. **Rebuild distribution**:
   ```bash
   make dist
   ```

3. **Available build targets**:
   - `make wheels` - Download wheels only
   - `make bundle` - Create wheel bundle
   - `make verify` - Verify bundle contents
   - `make dist` - Create complete distribution
   - `make clean` - Clean build artifacts

## 📝 Package List

<details>
<summary>Complete list of 110 included packages (click to expand)</summary>

Core packages and their dependencies:
- NumPy, Pandas, SciPy
- Matplotlib, Seaborn, Pillow
- Scikit-learn, Statsmodels, Joblib
- PyArrow, PyTZ, TZData
- JupyterLab, IPython, IPyKernel
- Jupyter-Server, NBConvert, NBFormat
- And 90+ supporting dependencies...

See `requirements.txt` for the complete list.
</details>

## 🤝 Support

### Getting Help

1. **Check logs**: Installation script provides detailed error messages
2. **Verify requirements**: Ensure Python 3.11 and sufficient disk space
3. **Manual installation**: Try step-by-step manual process if automated fails
4. **Environment**: Check virtual environment activation

### Additional Resources

- **Python Documentation**: https://docs.python.org/3.11/
- **Pandas User Guide**: https://pandas.pydata.org/docs/
- **Scikit-learn Tutorials**: https://scikit-learn.org/stable/tutorial/
- **JupyterLab Documentation**: https://jupyterlab.readthedocs.io/

---

**Generated**: July 9, 2025  
**Python Version**: CPython 3.11  
**Total Packages**: 110  
**Bundle Size**: 181MB  
**Target**: RHEL 9 / Airgapped Systems
