/**
 * Environment Variable Configuration Tests
 * 
 * Standalone tests that don't require Firebase emulators.
 * Tests the generateAgoraToken function's environment variable validation.
 */

// Set NODE_ENV before any imports
process.env.NODE_ENV = 'test';
process.env.AGORA_APP_ID = 'test_app_id_12345';
process.env.AGORA_APP_CERTIFICATE = 'test_certificate_67890';

const functions = require('firebase-functions');

// Import generateAgoraToken - this will initialize Firebase Admin
const { generateAgoraToken } = require('../index');

describe('Environment Variable Configuration (Standalone)', () => {
  let originalEnv;

  beforeAll(() => {
    // Save original environment
    originalEnv = { ...process.env };
  });

  beforeEach(() => {
    // Reset to original environment before each test
    process.env = { ...originalEnv };
  });

  afterAll(() => {
    // Restore original environment
    process.env = originalEnv;
  });

  test('1. generateAgoraToken succeeds with valid environment variables', () => {
    process.env.AGORA_APP_ID = 'test_app_id_12345';
    process.env.AGORA_APP_CERTIFICATE = 'test_certificate_67890';
    
    const token = generateAgoraToken('test_channel', 12345);
    
    expect(token).toBeDefined();
    expect(typeof token).toBe('string');
    expect(token.length).toBeGreaterThan(0);
  });

  test('2. generateAgoraToken throws error when AGORA_APP_ID is missing', () => {
    delete process.env.AGORA_APP_ID;
    process.env.AGORA_APP_CERTIFICATE = 'test_certificate';
    
    expect(() => {
      generateAgoraToken('test_channel', 12345);
    }).toThrow('AGORA_APP_ID');
  });

  test('3. generateAgoraToken throws error when AGORA_APP_CERTIFICATE is missing', () => {
    process.env.AGORA_APP_ID = 'test_app_id';
    delete process.env.AGORA_APP_CERTIFICATE;
    
    expect(() => {
      generateAgoraToken('test_channel', 12345);
    }).toThrow('AGORA_APP_CERTIFICATE');
  });

  test('4. generateAgoraToken throws error when both variables are missing', () => {
    delete process.env.AGORA_APP_ID;
    delete process.env.AGORA_APP_CERTIFICATE;
    
    expect(() => {
      generateAgoraToken('test_channel', 12345);
    }).toThrow(/AGORA_APP_ID.*AGORA_APP_CERTIFICATE/);
  });

  test('5. error message includes database context [DB: elajtech]', () => {
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

  test('6. generateAgoraToken throws error when variables are empty strings', () => {
    process.env.AGORA_APP_ID = '';
    process.env.AGORA_APP_CERTIFICATE = '';
    
    expect(() => {
      generateAgoraToken('test_channel', 12345);
    }).toThrow('AGORA_APP_ID');
  });

  test('7. throws HttpsError with failed-precondition code', () => {
    delete process.env.AGORA_APP_ID;
    
    try {
      generateAgoraToken('test_channel', 12345);
      fail('Should have thrown an error');
    } catch (error) {
      expect(error).toBeInstanceOf(functions.https.HttpsError);
      expect(error.code).toBe('failed-precondition');
    }
  });

  test('8. generates consistent tokens for same inputs', () => {
    process.env.AGORA_APP_ID = 'test_app_id';
    process.env.AGORA_APP_CERTIFICATE = 'test_certificate';
    
    const token1 = generateAgoraToken('channel', 12345, 'publisher', 3600);
    const token2 = generateAgoraToken('channel', 12345, 'publisher', 3600);
    
    expect(token1).toBe(token2);
  });
});
