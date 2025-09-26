# Node.js SBOM Test Project

A sample Node.js Express application for testing SBOM generation and license resolution with various npm packages.

## 🎯 Purpose

This project includes popular npm packages with different license types to test package resolution capabilities:
- MIT licensed packages (express, lodash, axios)
- Mixed license scenarios
- Security-related packages (bcrypt, helmet, jsonwebtoken)
- Database packages (mongoose)

## 🏗️ Project Structure

```
nodejs-sample/
├── package.json          # npm package configuration
├── index.js              # Main application code
├── .env.example          # Environment variables template
└── README.md            # This file
```

## 🚀 Quick Start

### Prerequisites
- Node.js 18.0+ and npm 9.0+
- Optional: yarn or pnpm as alternative package managers

### Installation and Setup
```bash
# Install dependencies
npm install

# Copy environment template
cp .env.example .env

# Run the application
npm start

# Or run tests directly
node index.js
```

### Development Mode
```bash
# Install development dependencies
npm install

# Run with auto-restart
npm run dev

# Run tests
npm test
```

## 📦 Included Packages

### Production Dependencies
| Package | Version | License | Purpose |
|---------|---------|---------|---------|
| express | ^4.18.2 | MIT | Web application framework |
| lodash | ^4.17.21 | MIT | Utility library |
| axios | ^1.6.0 | MIT | HTTP client |
| moment | ^2.29.4 | MIT | Date manipulation |
| uuid | ^9.0.1 | MIT | UUID generation |
| bcrypt | ^5.1.1 | MIT | Password hashing |
| jsonwebtoken | ^9.0.2 | MIT | JWT token handling |
| mongoose | ^8.0.3 | MIT | MongoDB ODM |
| winston | ^3.11.0 | MIT | Logging library |
| dotenv | ^16.3.1 | BSD-2-Clause | Environment variables |
| cors | ^2.8.5 | MIT | CORS middleware |
| helmet | ^7.1.0 | MIT | Security middleware |
| joi | ^17.11.0 | BSD-3-Clause | Data validation |

### Development Dependencies
| Package | Version | License | Purpose |
|---------|---------|---------|---------|
| jest | ^29.7.0 | MIT | Testing framework |
| nodemon | ^3.0.2 | MIT | Development server |
| webpack | ^5.89.0 | MIT | Module bundler |
| typescript | ^5.3.2 | Apache-2.0 | Type checking |
| eslint | ^8.55.0 | MIT | Code linting |
| prettier | ^3.1.0 | MIT | Code formatting |

## 🧪 Testing Features

The application provides several endpoints for testing:

### API Endpoints
```bash
# Health check
curl http://localhost:3000/health

# Test all packages
curl http://localhost:3000/test-packages

# Test HTTP client
curl http://localhost:3000/test-axios
```

### Direct Testing
```bash
# Run package tests without server
node index.js
```

## 🔧 Scripts Available

```bash
# Start the application
npm start

# Run tests
npm test

# Build for production
npm run build

# Development with auto-restart
npm run dev
```

## 📊 Expected Package Analysis

When analyzing this project with npm-based SBOM tools:
- **Total packages**: ~200+ (including transitive dependencies)
- **License distribution**:
  - MIT: ~85%
  - BSD variants: ~10%
  - Apache-2.0: ~3%
  - Others: ~2%

### Package Resolution Results
Most packages should resolve successfully through:
1. npm registry metadata
2. GitHub repository licenses
3. Package.json license fields

## 🌐 Server Features

When running as a server (`npm start`):
- **Port**: 3000 (configurable via PORT env var)
- **Security**: Helmet middleware enabled
- **CORS**: Cross-origin requests allowed
- **Logging**: Winston structured logging
- **Validation**: Joi data validation examples

### Environment Variables
```bash
# Server configuration
PORT=3000
NODE_ENV=development

# Security
JWT_SECRET=your-jwt-secret-here

# Database (example)
MONGODB_URI=mongodb://localhost:27017/sbom-test

# Logging
LOG_LEVEL=info
```

## 🔍 SBOM Analysis Tools

For Node.js projects, you can use various SBOM tools:

### npm audit
```bash
# Check for vulnerabilities
npm audit

# Generate audit report
npm audit --json > audit-report.json
```

### License Checker
```bash
# Install license checker
npm install -g license-checker

# Generate license report
license-checker --json > licenses.json
license-checker --csv > licenses.csv
```

### SBOM Generation
```bash
# Using cyclone-dx
npm install -g @cyclonedx/bom
cyclonedx-bom -o sbom.json

# Using SPDX tools
# (Requires additional setup)
```

## 📈 Package Testing Results

The test endpoints demonstrate:

1. **Lodash**: Array manipulation, utility functions
2. **Moment.js**: Date formatting and manipulation
3. **UUID**: Unique identifier generation
4. **Bcrypt**: Password hashing (async operations)
5. **JWT**: Token generation and validation
6. **Joi**: Schema validation
7. **Axios**: HTTP requests with error handling
8. **Winston**: Structured logging

## 🚨 Security Considerations

This project includes security-focused packages:
- **helmet**: Sets various HTTP headers
- **bcrypt**: Secure password hashing
- **jsonwebtoken**: JWT implementation
- **cors**: CORS policy management

### Security Testing
```bash
# Check for known vulnerabilities
npm audit

# Update packages
npm update

# Check outdated packages
npm outdated
```

## 🔄 Customization

### Adding New Packages
1. Install package: `npm install package-name`
2. Update `index.js` to import and test
3. Add test endpoint if needed
4. Document in package table

### Testing Different License Types
```bash
# Add packages with different licenses
npm install some-bsd-package
npm install some-apache-package
npm install some-gpl-package  # (be careful with copyleft)
```

## 🐛 Troubleshooting

### Common Issues
1. **Port conflicts**: Change PORT in .env
2. **Module not found**: Run `npm install`
3. **Permission errors**: Check file permissions
4. **Network timeouts**: Check firewall/proxy settings

### Debug Commands
```bash
# Verbose npm install
npm install --verbose

# Check npm configuration
npm config list

# Clear npm cache
npm cache clean --force

# Check package info
npm info package-name
```

### Development Tips
```bash
# Run with debugging
DEBUG=* node index.js

# Check package tree
npm list

# Find duplicate packages
npm ls --depth=0
```

---

This Node.js project provides a comprehensive test suite for npm package license resolution and SBOM generation across various package types and use cases.