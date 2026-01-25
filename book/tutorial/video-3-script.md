# Video 3: Setting Up Development Environment

## Introduction
[Duration: 0:00-0:30]

Welcome back to our Solana tutorial series! In the previous videos, we learned what Solana is and explored its ecosystem. Today, we're getting hands-on by setting up our development environment.

By the end of this video, you'll have a fully functional Solana development environment on your machine, and you'll have created your first Solana account. Let's get started!

## System Requirements
[Duration: 0:30-1:30]

Before we begin, let's check the system requirements:

### Minimum Requirements:
- Operating System: Linux, macOS, or Windows with WSL
- RAM: 8GB minimum (16GB recommended)
- Disk Space: 50GB free space
- Internet Connection: Required for downloading tools and dependencies

### Recommended Setup:
- Operating System: macOS or Linux (Windows with WSL2)
- RAM: 16GB or more
- Disk Space: 100GB free space
- SSD Storage: For better performance

Note: While Solana can run on Windows natively, the development experience is smoother on Unix-like systems. We'll be using Windows with WSL2 for this tutorial.

## Installing Rust
[Duration: 1:30-4:00]

Solana programs are written in Rust, so we need to install the Rust toolchain first.

### On macOS/Linux:
1. Open your terminal
2. Run the following command:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```
3. Follow the on-screen instructions
4. Restart your terminal or run:
   ```bash
   source $HOME/.cargo/env
   ```
5. Verify the installation:
   ```bash
   rustc --version
   cargo --version
   ```

### On Windows with WSL:
1. Install WSL2 if you haven't already:
   ```powershell
   wsl --install
   ```
2. Open your WSL terminal
3. Follow the macOS/Linux instructions above

### Installing Rust Components:
After installing Rust, we need to add some components:
```bash
rustup component add rustfmt
rustup component add clippy
```

We also need to install the wasm32-unknown-unknown target for building Solana programs:
```bash
rustup target add wasm32-unknown-unknown
```

## Installing Solana CLI
[Duration: 4:00-6:30]

The Solana CLI (Command Line Interface) is essential for interacting with the Solana network, deploying programs, and managing accounts.

### Installation:
1. Run this command to download and install the Solana CLI:
   ```bash
   sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
   ```
2. Add Solana to your PATH by adding this line to your shell profile (~/.bashrc, ~/.zshrc, etc.):
   ```bash
   export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
   ```
3. Reload your shell configuration:
   ```bash
   source ~/.bashrc  # or ~/.zshrc
   ```
4. Verify the installation:
   ```bash
   solana --version
   ```

### Updating Solana:
To update to the latest version:
```bash
solana-install update
```

## Setting Up a Wallet
[Duration: 6:30-9:00]

Now we'll create a wallet to interact with the Solana network.

### Creating a File System Wallet:
1. Generate a new keypair:
   ```bash
   solana-keygen new
   ```
2. This will create a new keypair file at ~/.config/solana/id.json and display your public key (wallet address)
3. To check your wallet address:
   ```bash
   solana address
   ```
4. To check your wallet balance:
   ```bash
   solana balance
   ```

### Wallet Security:
Important notes about wallet security:
- Never share your private key (the contents of id.json)
- Consider using hardware wallets for production use
- You can create multiple wallets for different purposes:
   ```bash
   solana-keygen new -o ~/my_wallet.json
   solana config set -k ~/my_wallet.json
   ```

## Configuring the Local Environment
[Duration: 9:00-11:00]

Let's configure our Solana CLI to work with different networks.

### Checking Current Configuration:
```bash
solana config get
```

### Setting Network Configuration:
Solana has several networks:
1. **Mainnet Beta**: The production network
2. **Devnet**: For development and testing (recommended for learning)
3. **Testnet**: For testing protocol changes
4. **Local**: For local development

Let's set our configuration to devnet:
```bash
solana config set --url devnet
```

### Airdropping SOL:
To get some test SOL on devnet:
```bash
solana airdrop 1
```
Note: You might need to run this command a few times as there are rate limits.

### Checking Your Balance:
```bash
solana balance
```

## Creating Your First Solana Account
[Duration: 11:00-13:30]

In Solana, accounts are fundamental data structures that store state. Let's create our first account.

### Understanding Accounts:
In Solana, accounts are not just wallets - they're data storage locations that can hold:
- SOL tokens
- Program data
- Smart contract state

### Creating a New Account:
1. Generate a new keypair for our account:
   ```bash
   solana-keygen new -o ~/test_account.json
   ```
2. Check the public key of the new account:
   ```bash
   solana address -k ~/test_account.json
   ```
3. Airdrop some SOL to this account:
   ```bash
   solana airdrop 1 ~/test_account.json
   ```
4. Check the account balance:
   ```bash
   solana balance ~/test_account.json
   ```

### Inspecting Account Data:
To get detailed information about an account:
```bash
solana account ~/test_account.json
```

This shows:
- Balance in SOL
- Account owner (system program for regular accounts)
- Account data size
- Whether the account is executable (for programs)

## First Transaction
[Duration: 13:30-15:30]

Let's send our first transaction on Solana.

### Transfer SOL:
1. First, check your main wallet balance:
   ```bash
   solana balance
   ```
2. Transfer 0.1 SOL to your test account:
   ```bash
   solana transfer ~/test_account.json 0.1
   ```
3. Check both balances:
   ```bash
   solana balance
   solana balance ~/test_account.json
   ```

### Exploring the Transaction:
After sending the transaction, you'll get a transaction signature. You can view this transaction in the Solana Explorer:
1. Copy the transaction signature
2. Go to https://explorer.solana.com
3. Paste the signature in the search bar

## Setting Up a Code Editor
[Duration: 15:30-17:00]

For development, we recommend using Visual Studio Code with the Solana extension:

1. Install Visual Studio Code
2. Install the "Solana" extension by Solana Labs
3. Install the "Rust" extension by rust-lang
4. Install the "CodeLLDB" extension for debugging

### Project Structure:
Create a directory for your Solana projects:
```bash
mkdir ~/solana-projects
cd ~/solana-projects
```

## Verifying Your Setup
[Duration: 17:00-18:30]

Let's verify that everything is working correctly:

1. Check Rust installation:
   ```bash
   rustc --version
   cargo --version
   ```
2. Check Solana CLI:
   ```bash
   solana --version
   solana config get
   ```
3. Check wallet and balance:
   ```bash
   solana address
   solana balance
   ```
4. Create a simple test transaction:
   ```bash
   solana transfer --help
   ```

If all these commands work without errors, your development environment is ready!

## Troubleshooting Common Issues
[Duration: 18:30-20:00]

### Issue 1: Command not found
If you get "command not found" errors:
1. Check your PATH environment variable
2. Restart your terminal
3. Re-source your shell configuration

### Issue 2: Permission denied
If you get permission errors:
1. Check file permissions on your keypair files
2. Ensure your user owns the ~/.config/solana directory

### Issue 3: Network connectivity issues
If you can't connect to devnet:
1. Check your internet connection
2. Try changing RPC endpoints:
   ```bash
   solana config set --url https://api.devnet.solana.com
   ```

### Issue 4: Airdrop failures
If airdrops fail:
1. Try again after a few minutes
2. Use a different RPC endpoint
3. Check if you've exceeded rate limits

## Conclusion
[Duration: 20:00-20:30]

Congratulations! You've successfully set up your Solana development environment and created your first account. In the next video, we'll dive into Solana's account model and learn how to write our first Solana program.

If you encountered any issues during setup, please check the troubleshooting section or leave a comment with your specific error. In the next video, we'll start writing code!

## Resources
- Rust Installation: https://www.rust-lang.org/tools/install
- Solana CLI Installation: https://docs.solana.com/cli/install-solana-cli-tools
- Solana Wallet Guide: https://docs.solana.com/wallet-guide
- Visual Studio Code: https://code.visualstudio.com
- Solana Explorer: https://explorer.solana.com