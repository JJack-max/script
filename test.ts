// 高信息密度加密示例（XOR + 可选压缩）
import * as zlib from 'zlib';

// 异或加密/解密函数
function xorEncryptDecrypt(input: Uint8Array, key: number): Uint8Array {
    const output = new Uint8Array(input.length);
    for (let i = 0; i < input.length; i++) {
        output[i] = input[i] ^ key;
    }
    return output;
}

// 将字符串转 Uint8Array
function stringToUint8Array(str: string): Uint8Array {
    return new TextEncoder().encode(str);
}

// 将 Uint8Array 转字符串
function uint8ArrayToString(arr: Uint8Array): string {
    return new TextDecoder().decode(arr);
}

// 示例使用
const plaintext = "HELLO, THIS IS A TEST MESSAGE!";

// 1️⃣ 直接 XOR（密文长度 = 明文长度）
const key = 42;
const encrypted = xorEncryptDecrypt(stringToUint8Array(plaintext), key);
const decrypted = xorEncryptDecrypt(encrypted, key);

console.log("XOR Encrypted (hex):", Buffer.from(encrypted).toString('hex'));
console.log("XOR Decrypted:", uint8ArrayToString(decrypted));

// 2️⃣ 可选：压缩 + XOR（密文长度可能 < 明文长度）
const compressed = zlib.deflateSync(Buffer.from(plaintext));
const encryptedCompressed = xorEncryptDecrypt(new Uint8Array(compressed), key);
const decryptedCompressed = xorEncryptDecrypt(encryptedCompressed, key);
const decompressed = zlib.inflateSync(Buffer.from(decryptedCompressed));

console.log("Compressed + XOR Encrypted (hex):", Buffer.from(encryptedCompressed).toString('hex'));
console.log("Compressed + XOR Decrypted:", decompressed.toString());
