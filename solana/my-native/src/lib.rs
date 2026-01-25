use std::borrow::Borrow;

use borsh::{BorshDeserialize, BorshSerialize};
use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    program_error::ProgramError,
    pubkey::Pubkey,
};

use solana_program::declare_id;

declare_id!("Bbwu3udWpVeoQLHMYUsjwwBLhXJXDF1GSWiHTxmdXzXx");

/// Define instruction enum
#[derive(BorshSerialize, BorshDeserialize, Debug)]
pub enum Instruction {
    Increment,
    Decrement,
    Multiply { factor: u64 }, // Add multiplication option
}

/// State stored in each account
#[derive(BorshSerialize, BorshDeserialize, Debug, Default)]
pub struct Counter {
    pub value: u64,
}

entrypoint!(process_instruction);

fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {    
    // Deserialize instruction
    let instruction = Instruction::try_from_slice(instruction_data)
        .map_err(|_| ProgramError::InvalidInstructionData)?;

    msg!("Received instruction: {:?}", instruction);

    // Get the first account as counter account
    let accounts_iter = &mut accounts.iter();
    let account = next_account_info(accounts_iter)?;

    if account.owner != program_id {
        msg!("Account does not have the correct program id");
        return Err(ProgramError::IncorrectProgramId);
    }

    // Deserialize account data
    let mut counter = if account.data_is_empty() {
        Counter::default()
    } else {
        Counter::try_from_slice(&account.data.borrow())?
    };

    // Route to different logic
    match instruction {
        Instruction::Increment => {
            counter.value = counter.value.saturating_add(1);
            msg!("Incremented counter to {}", counter.value);
        }
        Instruction::Decrement => {
            counter.value = counter.value.saturating_sub(1);
            msg!("Decremented counter to {}", counter.value);
        }
        Instruction::Multiply { factor } => {
            counter.value = counter.value.saturating_mul(factor);
            msg!("Multiplied counter by {} to get {}", factor, counter.value);
        }
    }

    // Serialize back to account data
    counter.serialize(&mut &mut account.data.borrow_mut()[..])?;

    Ok(())
}
