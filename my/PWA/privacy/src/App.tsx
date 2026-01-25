import React, { useState, useEffect } from 'react'
import { encryptText, decryptText } from './cryptoUtils'
import './App.css'

function App() {
    const [inputText, setInputText] = useState('')
    const [encryptedText, setEncryptedText] = useState('')
    const [decryptInput, setDecryptInput] = useState('')
    const [decryptedText, setDecryptedText] = useState('')
    const secretKey = 'my-secret-key-2025' // Hardcoded secret key

    // Encrypt text automatically when input changes
    useEffect(() => {
        if (inputText.trim()) {
            const result = encryptText(inputText, secretKey)
            if (result.success && result.data) {
                setEncryptedText(result.data)
            } else {
                setEncryptedText('')
            }
        } else {
            setEncryptedText('')
        }
    }, [inputText])

    // Decrypt text automatically when decrypt input changes
    useEffect(() => {
        if (decryptInput.trim()) {
            const result = decryptText(decryptInput, secretKey)
            if (result.success && result.data) {
                setDecryptedText(result.data)
            } else {
                setDecryptedText('')
            }
        } else {
            setDecryptedText('')
        }
    }, [decryptInput])

    const copyToClipboard = async (text: string) => {
        try {
            if (navigator.clipboard && window.isSecureContext) {
                // Use Clipboard API if available and in secure context
                await navigator.clipboard.writeText(text)
            } else {
                // Fallback method
                const textArea = document.createElement('textarea')
                textArea.value = text
                document.body.appendChild(textArea)
                textArea.focus()
                textArea.select()
                document.execCommand('copy')
                document.body.removeChild(textArea)
            }
        } catch (err) {
            console.error('Failed to copy text: ', err)
        }
    }

    return (
        <div className="app">
            <header className="app-header">
                <h1>保密工具</h1>
            </header>

            <main className="app-main">
                <div className="input-section">
                    <div className="form-group">
                        <label htmlFor="inputText">加密:</label>
                        <textarea
                            id="inputText"
                            value={inputText}
                            onChange={(e) => setInputText(e.target.value)}
                            placeholder="Enter text to encrypt"
                            rows={4}
                        />
                        {encryptedText && (
                            <div className="result-box">
                                <label>Encrypted Text:</label>
                                <pre>{encryptedText}</pre>
                                <button
                                    onClick={() => copyToClipboard(encryptedText)}
                                    className="copy-btn"
                                >
                                    Copy
                                </button>
                            </div>
                        )}
                    </div>

                    <div className="form-group">
                        <label htmlFor="decryptInput">解密:</label>
                        <textarea
                            id="decryptInput"
                            value={decryptInput}
                            onChange={(e) => setDecryptInput(e.target.value)}
                            placeholder="Enter encrypted text to decrypt"
                            rows={4}
                        />
                        {decryptedText && (
                            <div className="result-box">
                                <label>Decrypted Text:</label>
                                <pre>{decryptedText}</pre>
                                <button
                                    onClick={() => copyToClipboard(decryptedText)}
                                    className="copy-btn"
                                >
                                    Copy
                                </button>
                            </div>
                        )}
                    </div>
                </div>
            </main>

            <footer className="app-footer">
                <p>Your data never leaves your device. All encryption/decryption happens locally.</p>
            </footer>
        </div>
    )
}

export default App