# Video 6: Deploying and Interacting with Programs

## Introduction
[Duration: 0:00-0:30]

Welcome back to our Solana tutorial series! In the previous video, we created and deployed our first Solana program. Today, we're going to learn how to interact with deployed programs using web3.js and build a simple frontend application.

By the end of this video, you'll be able to create client applications that can communicate with your Solana programs, read account data, and send transactions to the network.

## Understanding Client-Side Interaction
[Duration: 0:30-2:00]

Before we dive into coding, let's understand how client applications interact with Solana programs:

### Key Components:
1. **Connection**: Establishing communication with an RPC node
2. **Keypairs**: Managing wallet keys for signing transactions
3. **Transactions**: Packaging instructions for the network
4. **Instructions**: Telling programs what actions to perform
5. **Accounts**: Reading and writing data to program accounts

### Data Flow:
1. Client creates a transaction with instructions
2. Transaction is signed by the user's wallet
3. Transaction is sent to the Solana network
4. Validators process the transaction
5. Program executes the instructions
6. Results are stored in accounts
7. Client reads updated account data

## Setting Up the Development Environment
[Duration: 2:00-4:00]

Let's set up our environment for building client applications.

### Creating the Project Directory:
```bash
# Create a directory for our client project
mkdir ~/solana-projects/hello_solana_frontend
cd ~/solana-projects/hello_solana_frontend
```

### Initializing a Node.js Project:
```bash
# Initialize a new Node.js project
npm init -y

# Install required dependencies
npm install @solana/web3.js @solana/buffer-layout
npm install --save-dev typescript ts-node @types/node
```

### Setting Up TypeScript:
Create a tsconfig.json file:
```json
{
  "compilerOptions": {
    "target": "es2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*"]
}
```

## Creating a Basic Connection
[Duration: 4:00-6:30]

Let's start by creating a basic connection to the Solana network.

### Creating the Connection File:
Create src/connection.ts:
```typescript
import { Connection, clusterApiUrl } from '@solana/web3.js';

// Create a connection to the devnet
const connection = new Connection(clusterApiUrl('devnet'), 'confirmed');

// Function to get connection info
async function getConnectionInfo() {
  const version = await connection.getVersion();
  const slot = await connection.getSlot();
  
  console.log('Connection to Solana cluster established!');
  console.log('Cluster version:', version['solana-core']);
  console.log('Current slot:', slot);
}

getConnectionInfo().catch(console.error);

export default connection;
```

### Running the Connection Script:
```bash
# Compile TypeScript
npx tsc

# Run the script
node dist/connection.js
```

## Managing Wallets and Keypairs
[Duration: 6:30-9:00]

Let's learn how to manage wallets and keypairs in our client applications.

### Creating a Wallet Management File:
Create src/wallet.ts:
```typescript
import { Keypair, PublicKey } from '@solana/web3.js';
import fs from 'fs';

// Generate a new keypair
function generateKeypair(): Keypair {
  const keypair = Keypair.generate();
  console.log('New wallet generated:');
  console.log('Public Key:', keypair.publicKey.toBase58());
  return keypair;
}

// Load keypair from file
function loadKeypairFromFile(filepath: string): Keypair {
  const secretKey = Uint8Array.from(
    JSON.parse(fs.readFileSync(filepath, 'utf-8'))
  );
  return Keypair.fromSecretKey(secretKey);
}

// Save keypair to file
function saveKeypairToFile(keypair: Keypair, filepath: string): void {
  fs.writeFileSync(filepath, JSON.stringify(Array.from(keypair.secretKey)));
  console.log('Keypair saved to:', filepath);
}

// Get wallet balance
async function getBalance(publicKey: PublicKey) {
  // We'll implement this after setting up our connection
}

export { generateKeypair, loadKeypairFromFile, saveKeypairToFile };
```

### Testing Wallet Functions:
Create src/test-wallet.ts:
```typescript
import { generateKeypair, saveKeypairToFile } from './wallet';

// Generate and save a new keypair
const keypair = generateKeypair();
saveKeypairToFile(keypair, 'test-wallet.json');
```

Run the test:
```bash
npx tsc
node dist/test-wallet.js
```

## Creating Instructions for Our Program
[Duration: 9:00-12:00]

Now let's create instructions to interact with our deployed program.

### Understanding Instructions:
Instructions contain:
1. **Program ID**: The public key of the program to call
2. **Accounts**: List of accounts the program will access
3. **Data**: Serialized instruction data

### Creating Instruction Builders:
Create src/instructions.ts:
```typescript
import { PublicKey, TransactionInstruction } from '@solana/web3.js';

// Our program ID (replace with your actual program ID)
const PROGRAM_ID = new PublicKey('YOUR_PROGRAM_ID_HERE');

// Function to create a "store data" instruction
function createStoreDataInstruction(
  programId: PublicKey,
  account: PublicKey,
  data: Buffer
): TransactionInstruction {
  return new TransactionInstruction({
    keys: [
      {
        pubkey: account,
        isSigner: false,
        isWritable: true,
      },
    ],
    programId,
    data,
  });
}

export { PROGRAM_ID, createStoreDataInstruction };
```

## Building and Sending Transactions
[Duration: 12:00-15:30]

Let's create transactions that include our instructions and send them to the network.

### Creating Transaction Functions:
Update src/instructions.ts:
```typescript
import { 
  PublicKey, 
  TransactionInstruction, 
  Transaction, 
  Keypair,
  sendAndConfirmTransaction,
} from '@solana/web3.js';
import { connection } from './connection';

// Our program ID (replace with your actual program ID)
const PROGRAM_ID = new PublicKey('YOUR_PROGRAM_ID_HERE');

// Function to create a "store data" instruction
function createStoreDataInstruction(
  programId: PublicKey,
  account: PublicKey,
  data: Buffer
): TransactionInstruction {
  return new TransactionInstruction({
    keys: [
      {
        pubkey: account,
        isSigner: false,
        isWritable: true,
      },
    ],
    programId,
    data,
  });
}

// Function to send a transaction
async function sendTransaction(
  instruction: TransactionInstruction,
  payer: Keypair,
  signers: Keypair[] = []
): Promise<string> {
  const transaction = new Transaction().add(instruction);
  
  // Add payer to signers if not already included
  if (!signers.includes(payer)) {
    signers.push(payer);
  }
  
  const signature = await sendAndConfirmTransaction(
    connection,
    transaction,
    signers,
    {
      commitment: 'confirmed',
    }
  );
  
  console.log('Transaction sent with signature:', signature);
  return signature;
}

export { 
  PROGRAM_ID, 
  createStoreDataInstruction, 
  sendTransaction 
};
```

## Reading Account Data
[Duration: 15:30-18:00]

Let's learn how to read data from accounts on the Solana network.

### Creating Account Reading Functions:
Create src/account.ts:
```typescript
import { PublicKey, AccountInfo } from '@solana/web3.js';
import { connection } from './connection';

// Function to get account info
async function getAccountInfo(
  accountPublicKey: PublicKey
): Promise<AccountInfo<Buffer> | null> {
  try {
    const accountInfo = await connection.getAccountInfo(accountPublicKey);
    return accountInfo;
  } catch (error) {
    console.error('Error fetching account info:', error);
    return null;
  }
}

// Function to get account data as string
async function getAccountDataAsString(
  accountPublicKey: PublicKey
): Promise<string | null> {
  const accountInfo = await getAccountInfo(accountPublicKey);
  
  if (accountInfo === null) {
    console.log('Account not found');
    return null;
  }
  
  // Convert buffer data to string
  const data = accountInfo.data.toString('utf-8');
  console.log('Account data:', data);
  return data;
}

// Function to get account balance
async function getAccountBalance(
  accountPublicKey: PublicKey
): Promise<number> {
  const balance = await connection.getBalance(accountPublicKey);
  console.log('Account balance:', balance, 'lamports');
  return balance;
}

export { getAccountInfo, getAccountDataAsString, getAccountBalance };
```

## Putting It All Together
[Duration: 18:00-21:30]

Let's create a complete example that ties everything together.

### Creating a Main Application:
Create src/index.ts:
```typescript
import { Keypair, PublicKey } from '@solana/web3.js';
import { 
  generateKeypair, 
  loadKeypairFromFile, 
  saveKeypairToFile 
} from './wallet';
import { 
  PROGRAM_ID, 
  createStoreDataInstruction, 
  sendTransaction 
} from './instructions';
import { 
  getAccountDataAsString, 
  getAccountBalance 
} from './account';
import { connection } from './connection';

async function main() {
  console.log('Starting Solana client application...');
  
  // Load or create wallet
  let wallet: Keypair;
  try {
    wallet = loadKeypairFromFile('wallet.json');
    console.log('Loaded existing wallet:', wallet.publicKey.toBase58());
  } catch (error) {
    console.log('Creating new wallet...');
    wallet = generateKeypair();
    saveKeypairToFile(wallet, 'wallet.json');
  }
  
  // Get wallet balance
  await getAccountBalance(wallet.publicKey);
  
  // For testing, we'll need to create an account for our program to use
  // In a real application, you would have a proper account creation process
  const testAccount = Keypair.generate();
  console.log('Test account:', testAccount.publicKey.toBase58());
  
  // Create instruction data
  const instructionData = Buffer.from('Hello, Solana!', 'utf-8');
  
  // Create instruction
  const instruction = createStoreDataInstruction(
    PROGRAM_ID,
    testAccount.publicKey,
    instructionData
  );
  
  try {
    // Send transaction (this will likely fail without proper account setup)
    // We'll cover proper account initialization in future videos
    console.log('Would send transaction with instruction data:', instructionData.toString());
    
    // For now, let's just demonstrate reading
    console.log('Reading from a known account...');
    // Replace with an actual account address you want to read
    // const accountToRead = new PublicKey('SOME_ACCOUNT_ADDRESS');
    // await getAccountDataAsString(accountToRead);
    
  } catch (error) {
    console.error('Error sending transaction:', error);
  }
}

main().catch(console.error);
```

## Testing with a Real Program
[Duration: 21:30-24:00]

Let's test our client with a real program. We'll use a simple program that's already deployed.

### Using the Memo Program:
The Memo program is a simple program deployed on all Solana networks that stores messages.

```typescript
import { 
  Connection, 
  clusterApiUrl, 
  Keypair, 
  PublicKey,
  Transaction,
  TransactionInstruction,
  sendAndConfirmTransaction
} from '@solana/web3.js';

async function sendMemo() {
  // Connect to devnet
  const connection = new Connection(clusterApiUrl('devnet'), 'confirmed');
  
  // Load wallet
  const wallet = Keypair.generate(); // In practice, load from file
  
  // Airdrop some SOL for testing
  const airdropSignature = await connection.requestAirdrop(
    wallet.publicKey,
    1000000000 // 1 SOL
  );
  await connection.confirmTransaction(airdropSignature);
  
  // Memo program ID
  const memoProgramId = new PublicKey(
    'MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr'
  );
  
  // Create memo instruction
  const memoInstruction = new TransactionInstruction({
    keys: [
      {
        pubkey: wallet.publicKey,
        isSigner: true,
        isWritable: false,
      },
    ],
    programId: memoProgramId,
    data: Buffer.from('Hello from our Solana client!'),
  });
  
  // Create and send transaction
  const transaction = new Transaction().add(memoInstruction);
  const signature = await sendAndConfirmTransaction(
    connection,
    transaction,
    [wallet]
  );
  
  console.log('Memo sent with signature:', signature);
}

sendMemo().catch(console.error);
```

## Building a Simple Web Interface
[Duration: 24:00-27:00]

Let's create a simple web interface to interact with our Solana program.

### Setting Up a Web Project:
```bash
# Install web dependencies
npm install express cors
npm install --save-dev @types/express @types/cors

# Create a public directory for static files
mkdir public
```

### Creating a Simple Web Server:
Create src/server.ts:
```typescript
import express, { Request, Response } from 'express';
import cors from 'cors';
import { Keypair } from '@solana/web3.js';

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Endpoint to generate a new wallet
app.get('/api/wallet', (req: Request, res: Response) => {
  const keypair = Keypair.generate();
  res.json({
    publicKey: keypair.publicKey.toBase58(),
    secretKey: Array.from(keypair.secretKey),
  });
});

// Endpoint to send a memo
app.post('/api/memo', async (req: Request, res: Response) => {
  try {
    const { message } = req.body;
    // Implementation would go here
    res.json({ success: true, message: 'Memo sent successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to send memo' });
  }
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
```

### Creating a Simple Frontend:
Create public/index.html:
```html
<!DOCTYPE html>
<html>
<head>
    <title>Solana Client Demo</title>
    <script src="https://unpkg.com/@solana/web3.js@latest/lib/index.iife.min.js"></script>
</head>
<body>
    <h1>Solana Client Demo</h1>
    
    <div>
        <h2>Wallet Information</h2>
        <button id="generateWallet">Generate Wallet</button>
        <div id="walletInfo"></div>
    </div>
    
    <div>
        <h2>Send Memo</h2>
        <input type="text" id="memoInput" placeholder="Enter your message">
        <button id="sendMemo">Send Memo</button>
        <div id="transactionResult"></div>
    </div>

    <script>
        // Frontend JavaScript would go here
        document.getElementById('generateWallet').addEventListener('click', async () => {
            try {
                const response = await fetch('/api/wallet');
                const wallet = await response.json();
                document.getElementById('walletInfo').innerHTML = 
                    `<p>Public Key: ${wallet.publicKey}</p>`;
            } catch (error) {
                console.error('Error generating wallet:', error);
            }
        });
    </script>
</body>
</html>
```

## Best Practices for Client Development
[Duration: 27:00-28:30]

### 1. Error Handling:
Always implement proper error handling for network requests and transactions.

### 2. Connection Management:
Reuse connections rather than creating new ones for each request.

### 3. Transaction Confirmation:
Use appropriate commitment levels ('processed', 'confirmed', 'finalized') based on your needs.

### 4. Wallet Integration:
Consider using wallet adapters like @solana/wallet-adapter for production applications.

### 5. Security:
Never expose private keys in client-side code. Use wallet providers for user interactions.

## Conclusion
[Duration: 28:30-29:00]

In this video, we've learned how to interact with Solana programs using web3.js, create client applications, and build simple web interfaces. We've covered the fundamentals of connecting to the network, managing wallets, creating transactions, and reading account data.

In the next video, we'll dive deeper into Solana's transaction model and learn about instructions, compute budgets, and fees.

If you found this tutorial helpful, please like and subscribe. In the comments, let me know what kind of Solana programs you're most interested in building!

## Resources
- Solana Web3.js Documentation: https://solana-labs.github.io/solana-web3.js/
- Solana Wallet Adapter: https://github.com/solana-labs/wallet-adapter
- Memo Program: https://github.com/solana-labs/solana-program-library/tree/master/memo
- Solana Cookbook: https://solanacookbook.com/
- Solana Explorer: https://explorer.solana.com