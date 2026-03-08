/**
 * Jest Configuration for Standalone Tests (No Emulators)
 * 
 * This configuration is for tests that don't require Firebase emulators.
 */

module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/test/env-vars.test.js'],
  testTimeout: 5000,
  verbose: true,
  forceExit: true,
};
