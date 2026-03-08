/**
 * Environment Variable Configuration Tests (Standalone)
 * 
 * These tests run without Firebase emulators since they only test
 * the generateAgoraToken function's environment variable validation.
 */

const functions = require('firebase-functions');

// Set NODE_ENV to test to enable exports
process.env.NODE_ENV = 'test';

// Mock Agora SDK to avoid actual token generation
jest.mock('agora-access-token', () => ({
  RtcTokenBuilder: {
    buildTokenWithUid: jest.fn(() => 'mock_token_12345'),
  },
  RtcRole: {
    PUBLISHER: 1,
    SUBSCRIBER: 2,
  },
}));

// Import after mocking
const { generateAgoraToken } = require('../index');

describe('Environment Variable Configuration', () => {
  let originalEnv;

  beforeEach(() => {
    originalEnv = { ...process.env };
  });

  afterEach(() => {
    process.env = originalEnv;
  });

  test('generateAgoraToken succeeds with valid environment variables', () => {
    process.env.AGORA_APP_ID = 'test_app_id_12345';
    process.env.AGORA_APP_CERTIFICATE = 'test_certificate_67890';
    
    const token = generateAgoraToken('test_channel', 12345);
    
    expect(token).toBeDefined();
    expect(typeof token).toBe('string');
    expect(token.length).toBeGreaterThan(0);
  });

  test('generateAgoraToken throws error when AGORA_APP_ID is missing', () => {
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
    process.env.AGORA_APP_ID = '';
    process.env.AGORA_APP_CERTIFICATE = '';
    
    expect(() => {
      generateAgoraToken('test_channel', 12345);
    }).toThrow('AGORA_APP_ID');
  });

  test('throws HttpsError with failed-precondition code', () => {
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
    process.env.AGORA_APP_ID = 'test_app_id';
    process.env.AGORA_APP_CERTIFICATE = 'test_certificate';
    
    const token1 = generateAgoraToken('channel', 12345, 'publisher', 3600);
    const token2 = generateAgoraToken('channel', 12345, 'publisher', 3600);
    
    expect(token1).toBe(token2);
  });
});
