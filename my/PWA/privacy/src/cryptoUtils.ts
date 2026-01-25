import CryptoJS from 'crypto-js';

export interface EncryptionResult {
    success: boolean;
    data?: string;
    error?: string;
}

/**
 * Encrypts text using AES encryption
 * @param text - Text to encrypt
 * @param secretKey - Secret key for encryption
 * @returns Encryption result with encrypted data or error message
 */
export function encryptText(text: string, secretKey: string): EncryptionResult {
    try {
        if (!text.trim()) {
            return { success: false, error: 'Text cannot be empty' };
        }

        if (!secretKey.trim()) {
            return { success: false, error: 'Secret key cannot be empty' };
        }

        const encrypted = CryptoJS.AES.encrypt(text, secretKey).toString();
        return { success: true, data: encrypted };
    } catch (error) {
        return { success: false, error: 'Encryption failed: ' + (error as Error).message };
    }
}

/**
 * Decrypts text using AES decryption
 * @param encryptedText - Encrypted text to decrypt
 * @param secretKey - Secret key for decryption
 * @returns Decryption result with decrypted data or error message
 */
export function decryptText(encryptedText: string, secretKey: string): EncryptionResult {
    try {
        if (!encryptedText.trim()) {
            return { success: false, error: 'Encrypted text cannot be empty' };
        }

        if (!secretKey.trim()) {
            return { success: false, error: 'Secret key cannot be empty' };
        }

        const bytes = CryptoJS.AES.decrypt(encryptedText, secretKey);
        const decrypted = bytes.toString(CryptoJS.enc.Utf8);

        if (!decrypted) {
            return { success: false, error: 'Decryption failed. Invalid key or corrupted data.' };
        }

        return { success: true, data: decrypted };
    } catch (error) {
        return { success: false, error: 'Decryption failed: ' + (error as Error).message };
    }
}

/**
 * Generates a random secret key
 * @param length - Length of the key (default: 32)
 * @returns Random secret key
 */
export function generateSecretKey(length: number = 32): string {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()';
    let result = '';
    for (let i = 0; i < length; i++) {
        result += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return result;
}