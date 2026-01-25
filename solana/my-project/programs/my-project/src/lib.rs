use anchor_lang::prelude::*;

declare_id!("A6S7jnFNrUN8mds8Cx1E4Tx2yLXjKbCd2FGjQANwyZCL");

#[program]
pub mod my_project {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        msg!("Greetings from: {:?}", ctx.program_id);
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize {}
