# Python SBOM Test Project

A sample Python Flask application for testing SBOM generation and license resolution with various pip packages.

## 🎯 Purpose

This project includes Python packages with diverse license types to test license resolution capabilities:
- BSD licensed packages (pandas, numpy, flask)
- Apache-2.0 packages (tensorflow, requests)
- MIT licensed packages (sqlalchemy, click)
- Complex licensing scenarios (cryptography, boto3)

## 🏗️ Project Structure

```
python-sample/
├── main.py              # Main Flask application
├── requirements.txt     # Python dependencies
├── setup.py            # Setup and installation script
└── README.md           # This file
```

## 🚀 Quick Start

### Prerequisites
- Python 3.8+ (recommended: Python 3.9-3.11)
- pip package manager
- Virtual environment (recommended)

### Installation Methods

#### Method 1: Automated Setup
```bash
# Run the setup script
./setup.py

# This will:
# 1. Create virtual environment
# 2. Install dependencies
# 3. Run initial tests
```

#### Method 2: Manual Setup
```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
source venv/bin/activate  # On macOS/Linux
# venv\Scripts\activate   # On Windows

# Upgrade pip
pip install --upgrade pip

# Install dependencies
pip install -r requirements.txt
```

### Running the Application

```bash
# Test mode (run all package tests)
python main.py --mode test

# Server mode (start Flask web server)
python main.py --mode server --port 5000

# Info mode (display package information)
python main.py --mode info
```

## 📦 Included Packages

### Web Framework & HTTP
| Package | Version | License | Purpose |
|---------|---------|---------|---------|
| flask | 3.0.0 | BSD-3-Clause | Web application framework |
| fastapi | 0.104.1 | MIT | Modern web framework |
| uvicorn | 0.24.0 | BSD-3-Clause | ASGI server |
| requests | 2.31.0 | Apache-2.0 | HTTP library |

### Data Science & ML
| Package | Version | License | Purpose |
|---------|---------|---------|---------|
| pandas | 2.1.4 | BSD-3-Clause | Data analysis library |
| numpy | 1.26.2 | BSD-3-Clause | Numerical computing |
| scikit-learn | 1.3.2 | BSD-3-Clause | Machine learning |
| tensorflow | 2.15.0 | Apache-2.0 | Deep learning framework |
| matplotlib | 3.8.2 | Custom (BSD-style) | Plotting library |

### Database & Storage
| Package | Version | License | Purpose |
|---------|---------|---------|---------|
| sqlalchemy | 2.0.23 | MIT | SQL toolkit and ORM |
| redis | 5.0.1 | MIT | Redis client |

### Cloud & Security
| Package | Version | License | Purpose |
|---------|---------|---------|---------|
| boto3 | 1.34.0 | Apache-2.0 | AWS SDK |
| cryptography | 41.0.8 | Apache-2.0/BSD | Cryptographic recipes |

### CLI & Utilities
| Package | Version | License | Purpose |
|---------|---------|---------|---------|
| click | 8.1.7 | BSD-3-Clause | Command line interface |
| pydantic | 2.5.1 | MIT | Data validation |
| pytest | 7.4.3 | MIT | Testing framework |

## 🧪 Testing Features

The application includes comprehensive package testing:

### Test Categories
1. **HTTP Requests**: Test external API calls with requests
2. **Data Processing**: Pandas DataFrame operations with numpy
3. **Database**: SQLAlchemy in-memory database operations
4. **Security**: Encryption/decryption with cryptography
5. **Validation**: Pydantic model validation
6. **Visualization**: Matplotlib plot generation
7. **Machine Learning**: Basic TensorFlow operations

### Running Tests
```bash
# Run all package tests
python main.py --mode test

# Expected output:
# 🧪 Running all package tests...
# ✅ requests: success
# ✅ pandas/numpy: success
# ✅ sqlalchemy: success
# ✅ cryptography: success
# ✅ pydantic: success
# ✅ matplotlib: success
# ✅ tensorflow: success
```

### Web Interface
```bash
# Start the server
python main.py --mode server

# Test endpoints:
curl http://localhost:5000/health
curl http://localhost:5000/test-packages
```

## 📊 Expected License Distribution

When analyzing this project:
- **BSD variants**: ~40% (pandas, numpy, scikit-learn, flask)
- **Apache-2.0**: ~30% (tensorflow, requests, boto3, cryptography)
- **MIT**: ~25% (sqlalchemy, pydantic, redis, pytest)
- **Other/Custom**: ~5% (matplotlib custom license)

### License Resolution Challenges
1. **Cryptography**: Dual Apache-2.0/BSD licensing
2. **TensorFlow**: Large project with multiple license files
3. **Boto3**: AWS SDK with complex dependency tree
4. **Matplotlib**: Custom BSD-style license

## 🌐 Web Server Features

When running in server mode:
- **Flask Development Server**: localhost:5000
- **Health Check**: `/health` endpoint
- **Package Testing**: `/test-packages` endpoint
- **JSON Responses**: Structured test results

### API Responses
```json
{
  "status": "success",
  "timestamp": "2024-01-01T12:00:00Z",
  "results": [
    {
      "package": "requests",
      "test": "HTTP GET request",
      "status": "success",
      "status_code": 200
    }
  ]
}
```

## 🔍 SBOM Generation for Python

### Using pip-licenses
```bash
# Install pip-licenses
pip install pip-licenses

# Generate license report
pip-licenses --format=json --output-file=licenses.json
pip-licenses --format=csv --output-file=licenses.csv
```

### Using cyclone-dx
```bash
# Install cyclone-dx
pip install cyclonedx-bom

# Generate SBOM
cyclonedx-bom -o sbom.json
```

### Using pip-audit
```bash
# Install pip-audit
pip install pip-audit

# Security audit
pip-audit --format=json --output=audit.json
```

## 📈 Performance Considerations

Some packages have significant resource requirements:

### Resource-Heavy Packages
- **TensorFlow**: ~500MB+ download, GPU support optional
- **Pandas**: Memory-intensive for large datasets
- **Matplotlib**: Font and backend dependencies

### Lightweight Alternatives
For testing purposes, consider:
- **FastAPI** instead of full Django
- **httpx** instead of requests for async
- **polars** instead of pandas for performance

## 🔧 Environment Configuration

### Virtual Environment Management
```bash
# Create named virtual environment
python -m venv sbom-test-env

# Activate
source sbom-test-env/bin/activate  # Unix
# sbom-test-env\Scripts\activate   # Windows

# Deactivate
deactivate
```

### Requirements Management
```bash
# Generate requirements from current environment
pip freeze > requirements-frozen.txt

# Install exact versions
pip install -r requirements-frozen.txt

# Update all packages
pip install --upgrade -r requirements.txt
```

## 🐛 Troubleshooting

### Common Installation Issues

1. **TensorFlow Installation**:
   ```bash
   # For macOS Apple Silicon
   pip install tensorflow-macos

   # For older systems
   pip install tensorflow==2.13.0
   ```

2. **Cryptography Compilation**:
   ```bash
   # Install build dependencies
   pip install --upgrade pip setuptools wheel
   # On macOS: brew install libffi openssl
   # On Ubuntu: apt-get install libffi-dev libssl-dev
   ```

3. **matplotlib Backend Issues**:
   ```bash
   # Set backend before importing
   export MPLBACKEND=Agg
   python main.py --mode test
   ```

### Debug Commands
```bash
# Check pip configuration
pip config list

# Verbose installation
pip install --verbose package-name

# Check package information
pip show package-name

# List installed packages
pip list

# Check for conflicts
pip check
```

## 🔄 Customization

### Adding New Packages
1. Add to `requirements.txt`
2. Install: `pip install -r requirements.txt`
3. Add test function in `main.py`
4. Update package documentation

### Testing Specific License Types
```bash
# Add GPL packages (careful with compatibility)
# numpy-quaternion==2022.4.3  # BSD
# imageio==2.31.5              # BSD
# pillow==10.1.0               # PIL License (BSD-like)
```

## 📋 CI/CD Integration

### GitHub Actions Example
```yaml
name: Python SBOM Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: actions/setup-python@v2
      with:
        python-version: '3.9'
    - run: pip install -r requirements.txt
    - run: python main.py --mode test
    - run: pip-licenses --format=json > licenses.json
```

## 📚 Learning Resources

### License Understanding
- [Python Package Licenses](https://packaging.python.org/guides/analyzing-pypi-package-downloads/)
- [BSD vs MIT vs Apache](https://choosealicense.com/)
- [GPL Compatibility](https://www.gnu.org/licenses/gpl-faq.html)

### SBOM Tools for Python
- [CycloneDX Python](https://github.com/CycloneDX/cyclonedx-python)
- [pip-licenses](https://github.com/raimon49/pip-licenses)
- [pip-audit](https://github.com/pypa/pip-audit)

---

This Python project provides comprehensive testing for pip package license resolution and demonstrates real-world usage patterns across multiple domains including web development, data science, and cloud integration.