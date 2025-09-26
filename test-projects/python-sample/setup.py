#!/usr/bin/env python3
"""
Python SBOM Test Setup Script
Installs dependencies and runs basic tests
"""

import subprocess
import sys
import os

def run_command(cmd, description):
    """Run a shell command and handle errors"""
    print(f"\n🔄 {description}...")
    try:
        result = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
        print(f"✅ {description} completed successfully")
        return result
    except subprocess.CalledProcessError as e:
        print(f"❌ {description} failed: {e}")
        if e.stdout:
            print(f"STDOUT: {e.stdout}")
        if e.stderr:
            print(f"STDERR: {e.stderr}")
        return None

def setup_python_environment():
    """Setup Python virtual environment and install dependencies"""
    print("🐍 Setting up Python SBOM Test Environment")
    
    # Check Python version
    python_version = sys.version_info
    print(f"Python version: {python_version.major}.{python_version.minor}.{python_version.micro}")
    
    if python_version < (3, 8):
        print("❌ Python 3.8 or higher is required")
        return False
    
    # Create virtual environment if it doesn't exist
    venv_path = "venv"
    if not os.path.exists(venv_path):
        run_command(f"{sys.executable} -m venv {venv_path}", "Creating virtual environment")
    
    # Determine activation command based on OS
    if os.name == 'nt':  # Windows
        activate_cmd = f"{venv_path}\\Scripts\\activate"
        pip_cmd = f"{venv_path}\\Scripts\\pip"
        python_cmd = f"{venv_path}\\Scripts\\python"
    else:  # Unix/Linux/MacOS
        activate_cmd = f"source {venv_path}/bin/activate"
        pip_cmd = f"{venv_path}/bin/pip"
        python_cmd = f"{venv_path}/bin/python"
    
    # Upgrade pip
    run_command(f"{pip_cmd} install --upgrade pip", "Upgrading pip")
    
    # Install requirements
    if os.path.exists("requirements.txt"):
        run_command(f"{pip_cmd} install -r requirements.txt", "Installing Python dependencies")
    else:
        print("❌ requirements.txt not found")
        return False
    
    # Run tests
    run_command(f"{python_cmd} main.py --mode test", "Running package tests")
    
    print("\n🎉 Python SBOM test environment setup complete!")
    print(f"To activate the virtual environment: {activate_cmd}")
    print(f"To run tests: {python_cmd} main.py --mode test")
    print(f"To start server: {python_cmd} main.py --mode server")
    
    return True

if __name__ == "__main__":
    setup_python_environment()