# Python SBOM Test Application
# A sample Python application for testing SBOM generation with various pip packages

import sys
import json
import logging
from datetime import datetime, timezone
from pathlib import Path

# Import test packages with different license types
import requests
import pandas as pd
import numpy as np
import flask
from flask import Flask, jsonify, request
import sqlalchemy
from sqlalchemy import create_engine
import click
import pytest
import pydantic
from pydantic import BaseModel
import fastapi
import uvicorn
import redis
import boto3
import cryptography
from cryptography.fernet import Fernet
import matplotlib.pyplot as plt
import scikit_learn
import tensorflow as tf

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class SBOMTestApp:
    """Main test application class"""
    
    def __init__(self):
        self.app = Flask(__name__)
        self.setup_routes()
        logger.info("🐍 Python SBOM Test Application initialized")
    
    def setup_routes(self):
        """Setup Flask routes for testing"""
        
        @self.app.route('/health')
        def health_check():
            return jsonify({
                'status': 'healthy',
                'timestamp': datetime.now(timezone.utc).isoformat(),
                'python_version': sys.version,
                'packages': self.get_package_info()
            })
        
        @self.app.route('/test-packages')
        def test_packages():
            """Test all imported packages"""
            try:
                results = self.run_all_tests()
                return jsonify({
                    'status': 'success',
                    'results': results,
                    'timestamp': datetime.now(timezone.utc).isoformat()
                })
            except Exception as e:
                logger.error(f"Package testing failed: {e}")
                return jsonify({
                    'status': 'error',
                    'error': str(e)
                }), 500
    
    def get_package_info(self):
        """Get information about imported packages"""
        packages = {}
        
        # Test each package
        test_modules = [
            'requests', 'pandas', 'numpy', 'flask', 'sqlalchemy',
            'click', 'pytest', 'pydantic', 'fastapi', 'uvicorn',
            'redis', 'boto3', 'cryptography', 'matplotlib', 
            'sklearn', 'tensorflow'
        ]
        
        for module in test_modules:
            try:
                mod = sys.modules.get(module)
                if mod:
                    version = getattr(mod, '__version__', 'Unknown')
                    packages[module] = {
                        'version': version,
                        'status': 'loaded'
                    }
                else:
                    packages[module] = {'status': 'not_loaded'}
            except Exception as e:
                packages[module] = {
                    'status': 'error',
                    'error': str(e)
                }
        
        return packages
    
    def test_requests(self):
        """Test requests HTTP library"""
        logger.info("Testing requests library...")
        try:
            # Make a test HTTP request
            response = requests.get('https://httpbin.org/json', timeout=5)
            return {
                'package': 'requests',
                'test': 'HTTP GET request',
                'status': 'success',
                'status_code': response.status_code,
                'response_size': len(response.text)
            }
        except Exception as e:
            return {
                'package': 'requests',
                'test': 'HTTP GET request',
                'status': 'error',
                'error': str(e)
            }
    
    def test_pandas_numpy(self):
        """Test pandas and numpy libraries"""
        logger.info("Testing pandas and numpy libraries...")
        try:
            # Create test data with pandas and numpy
            data = {
                'numbers': np.random.randint(1, 100, 10),
                'floats': np.random.random(10),
                'categories': np.random.choice(['A', 'B', 'C'], 10)
            }
            
            df = pd.DataFrame(data)
            stats = {
                'mean': df['numbers'].mean(),
                'std': df['numbers'].std(),
                'count': len(df)
            }
            
            return {
                'package': 'pandas/numpy',
                'test': 'DataFrame creation and statistics',
                'status': 'success',
                'stats': {k: float(v) for k, v in stats.items()},
                'shape': df.shape
            }
        except Exception as e:
            return {
                'package': 'pandas/numpy',
                'test': 'DataFrame creation and statistics',
                'status': 'error',
                'error': str(e)
            }
    
    def test_sqlalchemy(self):
        """Test SQLAlchemy ORM"""
        logger.info("Testing SQLAlchemy...")
        try:
            # Create in-memory SQLite database
            engine = create_engine('sqlite:///:memory:')
            
            # Test connection
            with engine.connect() as conn:
                result = conn.execute(sqlalchemy.text("SELECT 1 as test")).fetchone()
                
            return {
                'package': 'sqlalchemy',
                'test': 'In-memory database connection',
                'status': 'success',
                'result': result[0] if result else None
            }
        except Exception as e:
            return {
                'package': 'sqlalchemy',
                'test': 'In-memory database connection',
                'status': 'error',
                'error': str(e)
            }
    
    def test_cryptography(self):
        """Test cryptography library"""
        logger.info("Testing cryptography library...")
        try:
            # Generate encryption key and encrypt/decrypt test data
            key = Fernet.generate_key()
            cipher_suite = Fernet(key)
            
            test_message = b"Hello, SBOM testing!"
            encrypted = cipher_suite.encrypt(test_message)
            decrypted = cipher_suite.decrypt(encrypted)
            
            return {
                'package': 'cryptography',
                'test': 'Encryption/decryption',
                'status': 'success',
                'message_length': len(test_message),
                'encrypted_length': len(encrypted),
                'decryption_match': decrypted == test_message
            }
        except Exception as e:
            return {
                'package': 'cryptography',
                'test': 'Encryption/decryption',
                'status': 'error',
                'error': str(e)
            }
    
    def test_pydantic(self):
        """Test Pydantic data validation"""
        logger.info("Testing Pydantic...")
        try:
            class TestModel(BaseModel):
                name: str
                age: int
                email: str
            
            # Test valid data
            valid_data = TestModel(
                name="Test User",
                age=30,
                email="test@example.com"
            )
            
            return {
                'package': 'pydantic',
                'test': 'Data model validation',
                'status': 'success',
                'model_dict': valid_data.model_dump()
            }
        except Exception as e:
            return {
                'package': 'pydantic',
                'test': 'Data model validation',
                'status': 'error',
                'error': str(e)
            }
    
    def test_matplotlib(self):
        """Test matplotlib plotting (without displaying)"""
        logger.info("Testing matplotlib...")
        try:
            # Create a simple plot
            plt.figure(figsize=(6, 4))
            x = np.linspace(0, 10, 100)
            y = np.sin(x)
            plt.plot(x, y)
            plt.title('SBOM Test Plot')
            
            # Save to memory (don't display)
            import io
            buffer = io.BytesIO()
            plt.savefig(buffer, format='png')
            buffer.seek(0)
            plot_size = len(buffer.getvalue())
            plt.close()
            
            return {
                'package': 'matplotlib',
                'test': 'Plot generation',
                'status': 'success',
                'plot_size_bytes': plot_size
            }
        except Exception as e:
            return {
                'package': 'matplotlib',
                'test': 'Plot generation',
                'status': 'error',
                'error': str(e)
            }
    
    def test_tensorflow(self):
        """Test TensorFlow basic operations"""
        logger.info("Testing TensorFlow...")
        try:
            # Simple tensor operations
            a = tf.constant([[1, 2], [3, 4]])
            b = tf.constant([[2, 0], [1, 3]])
            c = tf.matmul(a, b)
            
            return {
                'package': 'tensorflow',
                'test': 'Matrix multiplication',
                'status': 'success',
                'result_shape': c.shape.as_list(),
                'tf_version': tf.__version__
            }
        except Exception as e:
            return {
                'package': 'tensorflow',
                'test': 'Matrix multiplication',
                'status': 'error',
                'error': str(e)
            }
    
    def run_all_tests(self):
        """Run all package tests"""
        logger.info("🧪 Running all package tests...")
        
        tests = [
            self.test_requests,
            self.test_pandas_numpy,
            self.test_sqlalchemy,
            self.test_cryptography,
            self.test_pydantic,
            self.test_matplotlib,
            self.test_tensorflow
        ]
        
        results = []
        for test_func in tests:
            try:
                result = test_func()
                results.append(result)
            except Exception as e:
                results.append({
                    'package': test_func.__name__.replace('test_', ''),
                    'status': 'error',
                    'error': str(e)
                })
        
        return results
    
    def run(self, host='127.0.0.1', port=5000, debug=True):
        """Run the Flask application"""
        logger.info(f"🚀 Starting Flask app on {host}:{port}")
        self.app.run(host=host, port=port, debug=debug)


@click.command()
@click.option('--mode', default='test', help='Run mode: test, server, or info')
@click.option('--port', default=5000, help='Port for server mode')
@click.option('--host', default='127.0.0.1', help='Host for server mode')
def main(mode, port, host):
    """Python SBOM Test Application
    
    This application tests various Python packages to help with SBOM generation.
    """
    app = SBOMTestApp()
    
    if mode == 'test':
        logger.info("🧪 Running package tests directly...")
        results = app.run_all_tests()
        
        print("\n" + "="*60)
        print("PYTHON PACKAGE TEST RESULTS")
        print("="*60)
        
        success_count = 0
        for result in results:
            status_emoji = "✅" if result['status'] == 'success' else "❌"
            print(f"{status_emoji} {result['package']}: {result['status']}")
            if result['status'] == 'success':
                success_count += 1
            elif 'error' in result:
                print(f"   Error: {result['error']}")
        
        print(f"\n📊 Results: {success_count}/{len(results)} packages tested successfully")
        
    elif mode == 'server':
        logger.info("🌐 Starting Flask server...")
        app.run(host=host, port=port, debug=False)
        
    elif mode == 'info':
        logger.info("📋 Package information:")
        packages = app.get_package_info()
        print(json.dumps(packages, indent=2))
    
    else:
        logger.error(f"Unknown mode: {mode}. Use 'test', 'server', or 'info'")


if __name__ == '__main__':
    main()