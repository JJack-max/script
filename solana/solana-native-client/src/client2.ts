import {
  Connection,
  Keypair,
  PublicKey,
  Transaction,
  SystemProgram,
  sendAndConfirmTransaction,
  TransactionInstruction,
} from "@solana/web3.js";
import { serialize, deserialize, field } from "@dao-xyz/borsh";
import fs from "fs";
import path from "path";
import { Buffer } from "buffer";

// --------- Counter struct ---------
class Counter {
  @field({ type: "u64" })
  value: bigint = 0n;

  constructor(fields?: { value: bigint }) {
    if (fields) this.value = fields.value;
  }
}

// --------- Instruction base & subclasses ---------
abstract class Instruction {
}

class Increment extends Instruction {
}

class Decrement extends Instruction {
}

class Multiply extends Instruction {
  @field({ type: "u64" })
  factor: bigint;

  constructor(factor: bigint) {
    super();
    this.factor = factor;
  }
}

// --------- Solana setup ---------
const connection = new Connection("http://127.0.0.1:8899", "confirmed");
const payerKeypairPath = path.join(process.env.HOME || "", ".config/solana/id.json");
const payer = Keypair.fromSecretKey(
  Uint8Array.from(JSON.parse(fs.readFileSync(payerKeypairPath, "utf-8")))
);
const COUNTER_KEYPAIR = Keypair.generate();
const PROGRAM_ID = new PublicKey("Bbwu3udWpVeoQLHMYUsjwwBLhXJXDF1GSWiHTxmdXzXx");

// --------- Create counter account ---------
async function createCounterAccount() {
  const lamports = await connection.getMinimumBalanceForRentExemption(8);
  const tx = new Transaction().add(
    SystemProgram.createAccount({
      fromPubkey: payer.publicKey,
      newAccountPubkey: COUNTER_KEYPAIR.publicKey,
      lamports,
      space: 8,
      programId: PROGRAM_ID,
    })
  );
  await sendAndConfirmTransaction(connection, tx, [payer, COUNTER_KEYPAIR]);
  console.log("✅ Counter account created:", COUNTER_KEYPAIR.publicKey.toBase58());
}

// --------- Send instruction ---------
async function sendInstruction(instruction: Instruction) {
  // ✅ serialize() 返回 Uint8Array，需转换为 Buffer
  const data = Buffer.from(serialize(instruction));
  const ix = new TransactionInstruction({
    keys: [{ pubkey: COUNTER_KEYPAIR.publicKey, isSigner: false, isWritable: true }],
    programId: PROGRAM_ID,
    data,
  });
  await sendAndConfirmTransaction(connection, new Transaction().add(ix), [payer]);
  console.log(`✅ Instruction ${instruction} sent`);
}

// --------- Fetch & decode counter value ---------
async function getCounterValue() {
  const accountInfo = await connection.getAccountInfo(COUNTER_KEYPAIR.publicKey);
  if (!accountInfo) return console.log("⚠️ Account not found");

  const counter = deserialize(new Uint8Array(accountInfo.data), Counter) as Counter;
  console.log("📊 Counter value:", counter.value.toString());
}

// --------- Main flow ---------
(async () => {
  await createCounterAccount();
  await sendInstruction(new Increment());
  await sendInstruction(new Increment());
  await sendInstruction(new Decrement());
  await sendInstruction(new Multiply(5n));
  await getCounterValue();
})();
