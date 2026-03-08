/**
 * Jest Configuration for AndroCare360 Cloud Functions Tests
 * 
 * This configuration sets up Jest for testing Cloud Functions with
 * Firebase Emulator Suite integration.
 */

module.exports = {
  // Use Node.js test environment
  testEnvironment: 'node',

  // Test file patterns
  testMatch: ['**/test/**/*.test.js'],

  // Coverage collection
  collectCoverageFrom: [
    'index.js',
    '!**/node_modules/**',
    '!**/test/**',
  ],

  // Coverage thresholds
  coverageThreshold: {
    global: {
      statements: 80,
      branches: 80,
      functions: 80,
      lines: 80,
    },
  },

  // Setup files
  setupFilesAfterEnv: ['<rootDir>/test/setup.js'],

  // Test timeout (increased for emulator operations)
  testTimeout: 10000,

  // Verbose output
  verbose: true,

  // Force exit after tests complete
  forceExit: true,

  // Detect open handles
  detectOpenHandles: true,
};
