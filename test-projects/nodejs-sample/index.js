const express = require('express');
const _ = require('lodash');
const axios = require('axios');
const moment = require('moment');
const { v4: uuidv4 } = require('uuid');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const winston = require('winston');
const cors = require('cors');
const helmet = require('helmet');
const Joi = require('joi');
require('dotenv').config();

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Configure Winston logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
});

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Test endpoint to demonstrate package usage
app.get('/test-packages', async (req, res) => {
  try {
    logger.info('Testing various npm packages');

    // Test lodash
    const numbers = [1, 2, 3, 4, 5];
    const shuffled = _.shuffle(numbers);
    logger.info(`Lodash shuffle test: ${shuffled}`);

    // Test moment.js
    const now = moment();
    const formatted = now.format('YYYY-MM-DD HH:mm:ss');
    logger.info(`Moment.js format test: ${formatted}`);

    // Test UUID generation
    const testUuid = uuidv4();
    logger.info(`UUID generation test: ${testUuid}`);

    // Test bcrypt (password hashing)
    const plainPassword = 'testpassword';
    const hashedPassword = await bcrypt.hash(plainPassword, 10);
    logger.info(`Bcrypt hash test: Password hashed successfully`);

    // Test JWT token generation
    const payload = { userId: testUuid, email: 'test@example.com' };
    const token = jwt.sign(payload, 'secret-key', { expiresIn: '1h' });
    logger.info(`JWT generation test: Token created successfully`);

    // Test Joi validation
    const schema = Joi.object({
      name: Joi.string().min(3).max(30).required(),
      email: Joi.string().email().required()
    });

    const testData = { name: 'Test User', email: 'test@example.com' };
    const { error } = schema.validate(testData);
    logger.info(`Joi validation test: ${error ? 'Failed' : 'Passed'}`);

    // Prepare response
    const response = {
      timestamp: formatted,
      uuid: testUuid,
      lodashShuffle: shuffled,
      bcryptHash: hashedPassword.substring(0, 20) + '...',
      jwtToken: token.substring(0, 20) + '...',
      joiValidation: error ? 'Failed' : 'Passed',
      message: 'All package tests completed successfully!'
    };

    res.json(response);

  } catch (error) {
    logger.error('Error testing packages:', error);
    res.status(500).json({ error: 'Package testing failed' });
  }
});

// Test axios HTTP client
app.get('/test-axios', async (req, res) => {
  try {
    logger.info('Testing axios HTTP client');
    
    // Make a test HTTP request
    const response = await axios.get('https://jsonplaceholder.typicode.com/posts/1', {
      timeout: 5000
    });

    res.json({
      message: 'Axios test successful',
      data: response.data,
      status: response.status
    });

  } catch (error) {
    logger.error('Axios test failed:', error.message);
    res.status(500).json({ error: 'Axios test failed' });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: moment().toISOString(),
    uptime: process.uptime(),
    nodeVersion: process.version,
    packages: {
      express: 'OK',
      lodash: 'OK',
      moment: 'OK',
      uuid: 'OK',
      bcrypt: 'OK',
      jsonwebtoken: 'OK',
      winston: 'OK',
      axios: 'OK',
      cors: 'OK',
      helmet: 'OK',
      joi: 'OK'
    }
  });
});

// Start server
app.listen(PORT, () => {
  logger.info(`🚀 SBOM Test Server running on port ${PORT}`);
  logger.info('Available endpoints:');
  logger.info('  GET /health - Health check');
  logger.info('  GET /test-packages - Test all packages');
  logger.info('  GET /test-axios - Test HTTP client');
});

// Test function for direct execution
function testPackagesDirectly() {
  console.log('🧪 Testing Node.js packages directly...\n');

  // Test each package
  console.log('1. Testing lodash...');
  const testArray = [1, 2, 3, 4, 5];
  console.log(`   Original: [${testArray}]`);
  console.log(`   Shuffled: [${_.shuffle([...testArray])}]`);
  console.log(`   Chunk by 2: ${JSON.stringify(_.chunk(testArray, 2))}`);

  console.log('\n2. Testing moment.js...');
  const now = moment();
  console.log(`   Current time: ${now.format('YYYY-MM-DD HH:mm:ss')}`);
  console.log(`   Relative time: ${now.fromNow()}`);
  console.log(`   Add 7 days: ${now.add(7, 'days').format('YYYY-MM-DD')}`);

  console.log('\n3. Testing UUID...');
  for (let i = 0; i < 3; i++) {
    console.log(`   UUID ${i + 1}: ${uuidv4()}`);
  }

  console.log('\n4. Testing Winston logger...');
  logger.info('This is an info message');
  logger.warn('This is a warning message');
  logger.error('This is an error message');

  console.log('\n✅ All packages tested successfully!');
}

// Run tests if called directly (not as a module)
if (require.main === module) {
  testPackagesDirectly();
}

module.exports = app;