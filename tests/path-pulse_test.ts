import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure that users can create goals",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    let block = chain.mineBlock([
      Tx.contractCall(
        "path-pulse",
        "create-goal",
        [
          types.utf8("Learn Clarity"),
          types.utf8("Master Clarity programming language"),
          types.uint(1640995200), // deadline
          types.bool(false) // not private
        ],
        deployer.address
      ),
    ]);
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    
    const [receipt] = block.receipts;
    assertEquals(receipt.result, '(ok u1)');
  },
});

Clarinet.test({
  name: "Ensure that only goal owner can add milestones",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const wallet1 = accounts.get("wallet_1")!;

    // First create a goal
    let block = chain.mineBlock([
      Tx.contractCall(
        "path-pulse",
        "create-goal",
        [
          types.utf8("Learn Clarity"),
          types.utf8("Master Clarity programming language"),
          types.uint(1640995200),
          types.bool(false)
        ],
        deployer.address
      ),
    ]);

    // Try to add milestone as different user
    block = chain.mineBlock([
      Tx.contractCall(
        "path-pulse",
        "add-milestone",
        [types.uint(1), types.utf8("Complete basic syntax")],
        wallet1.address
      ),
    ]);

    assertEquals(block.receipts[0].result, `(err u102)`);
  },
});
