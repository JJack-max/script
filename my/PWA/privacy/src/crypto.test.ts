import { describe, it, expect } from 'vitest';
import { encryptText, decryptText } from './cryptoUtils';

describe('Symmetric Encryption', () => {
    it('should encrypt and decrypt text correctly', () => {
        const text = 'Hello, World!';
        const secretKey = 'my-secret-key';

        // Encrypt
        const encryptResult = encryptText(text, secretKey);
        expect(encryptResult.success).toBe(true);
        expect(encryptResult.data).toBeDefined();

        // Decrypt
        const decryptResult = decryptText(encryptResult.data!, secretKey);
        expect(decryptResult.success).toBe(true);
        expect(decryptResult.data).toBe(text);
    });

    it('should fail to decrypt with wrong key', () => {
        const text = 'Hello, World!';
        const secretKey = 'my-secret-key';
        const wrongKey = 'wrong-key';

        // Encrypt
        const encryptResult = encryptText(text, secretKey);
        expect(encryptResult.success).toBe(true);
        expect(encryptResult.data).toBeDefined();

        // Try to decrypt with wrong key
        const decryptResult = decryptText(encryptResult.data!, wrongKey);
        expect(decryptResult.success).toBe(false);
        expect(decryptResult.data).toBeUndefined();
        expect(decryptResult.error).toBeDefined();
    });

    it('should handle empty text encryption', () => {
        const text = '';
        const secretKey = 'my-secret-key';

        // Try to encrypt empty text
        const result = encryptText(text, secretKey);
        expect(result.success).toBe(false);
        expect(result.error).toBe('Text cannot be empty');
    });

    it('should handle empty key encryption', () => {
        const text = 'Hello, World!';
        const secretKey = '';

        // Try to encrypt with empty key
        const result = encryptText(text, secretKey);
        expect(result.success).toBe(false);
        expect(result.error).toBe('Secret key cannot be empty');
    });
});