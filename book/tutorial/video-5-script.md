# Video 5: Writing Your First Solana Program

## Introduction
[Duration: 0:00-0:30]

Welcome back to our Solana tutorial series! In the previous video, we dove deep into Solana's account model and program architecture. Today, we're getting our hands dirty by writing our very first Solana program.

By the end of this video, you'll have created, built, and deployed a simple Solana program to the devnet. This is where we transition from theory to practice!

## Project Setup
[Duration: 0:30-2:00]

Let's start by creating our project structure and setting up the development environment.

### Creating the Project Directory:
```bash
# Create a directory for our Solana projects
mkdir ~/solana-projects
cd ~/solana-projects

# Create a directory for our first program
mkdir hello_solana
cd hello_solana
```

### Initializing a Cargo Project:
Solana programs are written in Rust and use Cargo as the build system:
```bash
# Initialize a new Rust library project
cargo init --lib

# This creates a Cargo.toml file and a src/lib.rs file
```

### Configuring Cargo.toml:
Let's update our Cargo.toml file to make it suitable for Solana development:

```toml
[package]
name = "hello_solana"
version = "0.1.0"
edition = "2021"

[dependencies]
solana-program = "~1.16.0"

[lib]
crate-type = ["cdylib", "rlib"]
```

Key points about this configuration:
- `solana-program` is the core Solana program library
- `crate-type = ["cdylib", "rlib"]` specifies that we're building both a dynamic library (for deployment) and a Rust library (for testing)

## Understanding the Program Structure
[Duration: 2:00-4:30]

Before we start coding, let's understand the structure of a Solana program.

### Entry Point:
Every Solana program must have an entry point function that the runtime calls. This function receives:
1. `program_id`: The public key of the program
2. `accounts`: A slice of account information
3. `instruction_data`: Raw byte data for the instruction

### Account Information:
The `AccountInfo` struct contains:
- Public key of the account
- Lamport balance
- Data slice
- Owner program ID
- Flags for mutability and signer status

### Instruction Processing:
The entry point function processes instructions based on the instruction data and interacts with the provided accounts.

## Writing Our First Program
[Duration: 4:30-10:00]

Let's write a simple program that stores a message in an account.

### Updating src/lib.rs:
Replace the contents of src/lib.rs with:

```rust
use solana_program::{
    account_info::AccountInfo,
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    pubkey::Pubkey,
};

// Declare the entry point for our program
entrypoint!(process_instruction);

// The main function that processes instructions
fn process_instruction(
    program_id: &Pubkey,           // Public key of the program
    accounts: &[AccountInfo],      // Accounts involved in the transaction
    instruction_data: &[u8],       // Instruction data
) -> ProgramResult {
    // Log a message to the Solana logs
    msg!("Hello, Solana!");
    
    // For now, we'll just return Ok
    Ok(())
}
```

### Adding More Functionality:
Let's enhance our program to actually store data in an account:

```rust
use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    program_error::ProgramError,
    pubkey::Pubkey,
};

entrypoint!(process_instruction);

fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    msg!("Hello, Solana!");
    
    // Get the account to store data
    let accounts_iter = &mut accounts.iter();
    let account = next_account_info(accounts_iter)?;
    
    // Check that the account is owned by our program
    if account.owner != program_id {
        msg!("Account is not owned by this program");
        return Err(ProgramError::IncorrectProgramId);
    }
    
    // Store the instruction data in the account
    let mut account_data = account.try_borrow_mut_data()?;
    account_data.copy_from_slice(instruction_data);
    
    msg!("Data stored successfully");
    Ok(())
}
```

## Building the Program
[Duration: 10:00-12:00]

Now let's build our program to ensure everything works correctly.

### Setting Up the Build Environment:
First, we need to ensure we have the correct target:
```bash
rustup target add wasm32-unknown-unknown
```

### Building the Program:
```bash
# Build the program
cargo build-bpf

# This creates a deploy directory with our program
```

Note: If you're using newer versions of Solana, you might need to use:
```bash
cargo build-sbf
```

### Understanding the Build Output:
The build process creates:
1. A BPF (Berkeley Packet Filter) bytecode file (.so)
2. This is the compiled program that will be deployed to Solana

### Common Build Issues:
- Missing dependencies: Ensure solana-program is in Cargo.toml
- Target not installed: Run rustup target add wasm32-unknown-unknown
- Version conflicts: Check that Solana CLI and program versions match

## Testing Locally
[Duration: 12:00-15:00]

Before deploying to devnet, let's test our program locally using the Solana test validator.

### Starting the Test Validator:
```bash
# Start a local test validator
solana-test-validator

# This will run in the foreground, so open a new terminal for other commands
```

### Configuring CLI for Local Testing:
In a new terminal:
```bash
# Set CLI to use localhost
solana config set --url localhost

# Check the configuration
solana config get

# Airdrop some SOL for testing
solana airdrop 10
```

### Deploying to Local Validator:
```bash
# Deploy the program (from the hello_solana directory)
solana program deploy target/deploy/hello_solana.so

# This will return the program ID
```

### Testing the Program:
Let's create a simple test script to interact with our program:

1. Create a test account:
```bash
solana-keygen new -o test_account.json
```

2. Send a transaction to our program:
```bash
# This will call our program with some data
# We'll need to write a client script for this
```

## Writing a Test Client
[Duration: 15:00-18:00]

To properly test our program, let's write a simple client in Rust.

### Creating a Client Project:
```bash
# Create a new directory for our client
cd ~/solana-projects
mkdir hello_solana_client
cd hello_solana_client
cargo init
```

### Adding Dependencies to Cargo.toml:
```toml
[package]
name = "hello_solana_client"
version = "0.1.0"
edition = "2021"

[dependencies]
solana-client = "~1.16.0"
solana-program = "~1.16.0"
solana-sdk = "~1.16.0"
```

### Writing the Client Code:
In src/main.rs:
```rust
use solana_client::rpc_client::RpcClient;
use solana_program::{pubkey::Pubkey, system_instruction};
use solana_sdk::{
    commitment_config::CommitmentConfig,
    signature::{Keypair, Signer},
    transaction::Transaction,
};
use std::str::FromStr;

fn main() {
    // Connect to the local validator
    let rpc_client = RpcClient::new_with_commitment(
        "http://localhost:8899".to_string(),
        CommitmentConfig::confirmed(),
    );
    
    // Load our wallet keypair
    let wallet = Keypair::new();
    
    // Airdrop some SOL for testing
    match rpc_client.request_airdrop(&wallet.pubkey(), 1_000_000_000) {
        Ok(sig) => println!("Airdrop signature: {}", sig),
        Err(err) => println!("Error: {}", err),
    }
    
    println!("Client setup complete!");
}
```

## Deploying to Devnet
[Duration: 18:00-20:00]

Now let's deploy our program to the devnet for broader testing.

### Switching to Devnet:
```bash
# Configure CLI to use devnet
solana config set --url devnet

# Airdrop some SOL
solana airdrop 2
```

### Deploying the Program:
```bash
# Deploy to devnet
solana program deploy target/deploy/hello_solana.so

# Note the program ID that's returned
```

### Verifying Deployment:
```bash
# Check program information
solana program show <PROGRAM_ID>

# View in Solana Explorer
# Go to https://explorer.solana.com/address/<PROGRAM_ID>?cluster=devnet
```

## Program Upgradeability
[Duration: 20:00-21:30]

One important concept is program upgradeability. By default, programs deployed with `solana program deploy` are upgradeable.

### Making Programs Immutable:
To make a program immutable:
```bash
solana program deploy --final target/deploy/hello_solana.so
```

### Upgrading Programs:
To upgrade an existing program:
```bash
solana program deploy target/deploy/hello_solana.so --program-id <EXISTING_PROGRAM_ID>
```

## Troubleshooting Common Issues
[Duration: 21:30-23:00]

### Issue 1: Build Errors
- Check that all dependencies are correctly specified in Cargo.toml
- Ensure you're using compatible versions of solana-program and CLI
- Verify the target is installed with `rustup target list --installed`

### Issue 2: Deployment Failures
- Ensure you have sufficient SOL balance
- Check that you're connected to the correct network
- Verify the program file exists at the expected path

### Issue 3: Program Execution Errors
- Check the program logs with `solana logs`
- Verify account ownership and constraints
- Ensure instruction data is correctly formatted

## Conclusion
[Duration: 23:00-23:30]

Congratulations! You've successfully created, built, and deployed your first Solana program. We've covered the entire development cycle from project setup to deployment.

In the next video, we'll learn how to interact with our deployed programs using web3.js and build a simple frontend to interact with our program.

If you encountered any issues during this process, please check the troubleshooting section or leave a comment with your specific error. The Solana development community is very supportive, and you'll find help on forums like Solana Stack Exchange.

## Resources
- Solana Program Docs: https://docs.solana.com/developing/on-chain-programs/overview
- Solana Program Examples: https://github.com/solana-labs/solana-program-library
- Rust Programming Language: https://www.rust-lang.org/
- Solana Test Validator: https://docs.solana.com/developing/test-validator
- Solana Explorer: https://explorer.solana.com