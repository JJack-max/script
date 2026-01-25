import {
    Connection,
    Keypair,
    PublicKey,
    Transaction,
    SystemProgram,
    sendAndConfirmTransaction,
    TransactionInstruction,
} from "@solana/web3.js";
import * as borsh from "borsh";
import fs from "fs";
import path from "path";

// --------- Borsh schema for Counter ---------
class Counter {
    value: bigint = 0n;
    constructor(fields: { value: bigint } | undefined = undefined) {
        if (fields) this.value = fields.value;
    }
}

const CounterSchema = { struct: { value: "u64" } } as const;

// --------- 指令 Enum ---------
enum InstructionEnum {
    Increment = 0,
    Decrement = 1,
    Multiply = 2,
}

// --------- Serialize instruction ---------
function serializeInstruction(instruction: { type: InstructionEnum; factor?: bigint }): Buffer {
    if (instruction.type === InstructionEnum.Multiply) {
        if (instruction.factor === undefined) throw new Error("Multiply requires a factor");
        const buffer = Buffer.alloc(1 + 8);
        buffer.writeUInt8(InstructionEnum.Multiply, 0);
        buffer.writeBigUInt64LE(instruction.factor, 1);
        return buffer;
    } else {
        return Buffer.from([instruction.type]);
    }
}

// --------- 配置 ---------
const connection = new Connection("http://127.0.0.1:8899", "confirmed");

// 使用本地 keypair
const payerKeypairPath = path.join(process.env.HOME || "", ".config/solana/id.json");
const payer = Keypair.fromSecretKey(
    Uint8Array.from(JSON.parse(fs.readFileSync(payerKeypairPath, "utf-8")))
);

// 创建计数器账户
const COUNTER_KEYPAIR = Keypair.generate();

// Program ID (替换为你部署的 program id)
const PROGRAM_ID = new PublicKey("Bbwu3udWpVeoQLHMYUsjwwBLhXJXDF1GSWiHTxmdXzXx");

// --------- 功能函数 ---------
async function createCounterAccount() {
    const lamports = await connection.getMinimumBalanceForRentExemption(8); // u64 -> 8 bytes
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
    console.log("Counter account created:", COUNTER_KEYPAIR.publicKey.toBase58());
}

async function sendInstruction(instruction: { type: InstructionEnum; factor?: bigint }) {
    const ix = new TransactionInstruction({
        keys: [{ pubkey: COUNTER_KEYPAIR.publicKey, isSigner: false, isWritable: true }],
        programId: PROGRAM_ID,
        data: serializeInstruction(instruction),
    });

    const tx = new Transaction().add(ix);
    await sendAndConfirmTransaction(connection, tx, [payer]);
    console.log(`Instruction ${InstructionEnum[instruction.type]} sent`);
}

async function getCounterValue() {
    const accountInfo = await connection.getAccountInfo(COUNTER_KEYPAIR.publicKey);
    if (!accountInfo) {
        console.log("Account not found");
        return;
    }
    // Borsh deserialize
    const counterData: any = borsh.deserialize(CounterSchema, accountInfo.data);
    console.log("Counter value:", counterData.value.toString());
}

// --------- 测试流程 ---------
(async () => {
    await createCounterAccount();

    await sendInstruction({ type: InstructionEnum.Increment });
    await sendInstruction({ type: InstructionEnum.Increment });
    await sendInstruction({ type: InstructionEnum.Decrement });
    await sendInstruction({ type: InstructionEnum.Multiply, factor: 5n });

    await getCounterValue(); // 输出最终计数器值
})();
