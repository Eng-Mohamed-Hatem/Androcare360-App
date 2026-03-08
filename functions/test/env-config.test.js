/**
 * Environment Variable Configuration Tests
 * 
 * File: functions/test/env-config.test.js
 * 
 * Purpose: Validate the migration from functions.config() to process.env
 * for Agora credentials (Tasks 1 & 2 of agora-env-migration spec)
 * 
 * Requirements Validated:
 * - 1.1: Function reads AGORA_APP_ID from process.env
 * - 1.2: Function reads AGORA_APP_CERTIFICATE from process.env
 * - 2.1: Throws error when AGORA_APP_ID is missing
 * - 2.2: Throws error when AGORA_APP_CERTIFICATE is missing
 * - 2.3: Error messages prefixed with [DB: elajtech]
 * - 3.1-3.4: Detailed error messages list missing variables
 * - 8.1-8.3: Unit tests verify environment variable configuration
 */

const functions = require('firebase-functions');

// CRITICAL: Import setup.js BEFORE index.js to avoid Firebase initialization conflicts
const { admin, db } = require('./setup');

// Import generateAgoraToken function from index.js
// This function is exported for testing when NODE_ENV=test or FUNCTIONS_EMULATOR=true
const { generateAgoraToken } = require('../index');

describe('Environment Variable Configuration', () => {
  let originalEnv;

  beforeEach(() => {
    // Save original environment
    originalEnv = { ...process.env };
  });

  afterEach(() => {
    // Restore original environment
    process.env = originalEnv;
  });

  test('generateAgoraToken succeeds with valid environment variables', () => {
    // Validates: Requirements 1.1, 1.2, 8.3
    process.env.AGORA_APP_ID = 'test_app_id_12345';
    process.env.AGORA_APP_CERTIFICATE = 'test_certificate_67890';
    
    const token = generateAgoraToken('test_channel', 12345);
    
    expect(token).toBeDefined();
    expect(typeof token).toBe('string');
    expect(token.length).toBeGreaterThan(0);
  });

  test('generateAgoraToken throws error when AGORA_APP_ID is missing', () => {
    // Validates: Requirements 2.1, 3.1, 8.2
    delete process.env.AGORA_APP_ID;
    process.env.AGORA_APP_CERTIFICATE = 'test_certificate';
    
    expect(() => {
      generateAgoraToken('test_channel', 12345);
    }).toThrow('AGORA_APP_ID');
    
    expect(() => {
      generateAgoraToken('test_channel', 12345);
    }).toThrow(functions.https.HttpsError);
  });

  test('generateAgoraToken throws error when AGORA_APP_CERTIFICATE is missing', () => {
    // Validates: Requirements 2.2, 3.2, 8.2
    process.env.AGORA_APP_ID = 'test_app_id';
    delete process.env.AGORA_APP_CERTIFICATE;
    
    expect(() => {
      generateAgoraToken('test_channel', 12345);
    }).toThrow('AGORA_APP_CERTIFICATE');
    
    expect(() => {
      generateAgoraToken('test_channel', 12345);
    }).toThrow(functions.https.HttpsError);
  });

  test('generateAgoraToken throws error when both variables are missing', () => {
    // Validates: Requirements 3.3, 8.2
    delete process.env.AGORA_APP_ID;
    delete process.env.AGORA_APP_CERTIFICATE;
    
    expect(() => {
      generateAgoraToken('test_channel', 12345);
    }).toThrow(/AGORA_APP_ID.*AGORA_APP_CERTIFICATE/);
    
    try {
      generateAgoraToken('test_channel', 12345);
      fail('Should have thrown an error');
    } catch (error) {
      expect(error.message).toContain('AGORA_APP_ID');
      expect(error.message).toContain('AGORA_APP_CERTIFICATE');
    }
  });

  test('error message includes database context [DB: elajtech]', () => {
    // Validates: Requirements 2.3, 3.4, 8.2
    delete process.env.AGORA_APP_ID;
    process.env.AGORA_APP_CERTIFICATE = 'test_certificate';
    
    expect(() => {
      generateAgoraToken('test_channel', 12345);
    }).toThrow('[DB: elajtech]');
    
    try {
      generateAgoraToken('test_channel', 12345);
      fail('Should have thrown an error');
    } catch (error) {
      expect(error.message).toMatch(/^\[DB: elajtech\]/);
      expect(error.message).toContain('Missing environment variables');
      expect(error.message).toContain('Please ensure your .env file');
    }
  });

  test('generateAgoraToken throws error when variables are empty strings', () => {
    // Validates: Enhanced validation for empty values
    process.env.AGORA_APP_ID = '';
    process.env.AGORA_APP_CERTIFICATE = '';
    
    expect(() => {
      generateAgoraToken('test_channel', 12345);
    }).toThrow('AGORA_APP_ID');
  });

  test('throws HttpsError with failed-precondition code', () => {
    // Validates: Correct error type and code
    delete process.env.AGORA_APP_ID;
    
    try {
      generateAgoraToken('test_channel', 12345);
      fail('Should have thrown an error');
    } catch (error) {
      expect(error).toBeInstanceOf(functions.https.HttpsError);
      expect(error.code).toBe('failed-precondition');
    }
  });

  test('generates consistent tokens for same inputs', () => {
    // Validates: Token generation consistency
    process.env.AGORA_APP_ID = 'test_app_id';
    process.env.AGORA_APP_CERTIFICATE = 'test_certificate';
    
    const token1 = generateAgoraToken('channel', 12345, 'publisher', 3600);
    const token2 = generateAgoraToken('channel', 12345, 'publisher', 3600);
    
    expect(token1).toBe(token2);
  });
});
