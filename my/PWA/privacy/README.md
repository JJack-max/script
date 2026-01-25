# Symmetric Encryption PWA

A Progressive Web App for symmetric encryption and decryption using AES algorithm.

## Features

- 🔐 Symmetric encryption/decryption with AES
- 🌐 Works offline as a PWA
- 📱 Responsive design
- 🎨 Modern UI with dark mode support
- 📋 Copy to clipboard functionality
- 🔑 Secret key generation

## Technology Stack

- React 18 with TypeScript
- Vite for build tool
- crypto-js for encryption
- CSS3 for styling

## Getting Started

1. Install dependencies:
   ```bash
   npm install
   ```

2. Start the development server:
   ```bash
   npm run dev
   ```

3. Build for production:
   ```bash
   npm run build
   ```

4. Preview the production build:
   ```bash
   npm run preview
   ```

## Usage

1. Enter a secret key (or generate one)
2. Enter text to encrypt
3. Click "Encrypt" to encrypt the text
4. Copy the encrypted text and share it securely
5. To decrypt, paste the encrypted text and enter the same secret key
6. Click "Decrypt" to retrieve the original text

## Security Notes

- All encryption/decryption happens locally in your browser
- No data is sent to any server
- Your secret key is never stored or transmitted
- For maximum security, use a strong secret key

## PWA Features

- Installable on mobile devices
- Works offline
- Fast loading with service worker caching