import { describe, it } from "node:test";
import { network } from "hardhat";
// We don't have Ethereum specific assertions in Hardhat 3 yet
import assert from "node:assert/strict";

/*
 * `node:test` uses `describe` and `it` to define tests, similar to Mocha.
 * `describe` blocks support async functions, simplifying the setup of tests.
 */
// describe("Niel42", async function () {
//   /*
//    * In Hardhat 3, there isn't a single global connection to a network. Instead,
//    * you have a `network` object that allows you to connect to different
//    * networks.
//    *
//    * You can create multiple network connections using `network.connect`.
//    * It takes two optional parameters and returns a `NetworkConnection` object.
//    *
//    * Its parameters are:
//    *
//    * 1. The name of the network configuration to use (from `config.networks`).
//    *
//    * 2. The `ChainType` to use.
//    *
//    * Providing a `ChainType` ensures the connection is aware of the kind of
//    * chain it's using, potentially affecting RPC interactions for HTTP
//    * connections, and changing the simulation behavior for EDR networks.
//    * It also ensures the network connection has the correct TypeScript type and
//    * viem extensions (e.g. Optimisim L2 actions).
//    *
//    * If you don't provide a `ChainType`, it will be inferred from the network
//    * config, and default to `generic` if not specified in the config. In either
//    * case, the connection will have a generic TypeScript type and no viem
//    * extensions.
//    *
//    * Every time you call `network.connect` with an EDR network config name, a
//    * new instance of EDR will be created. Each of these instances has its own
//    * state and blockchain, and they have no communication with each other.
//    *
//    * Examples:
//    *
//    * - `await network.connect({network: "sepolia", chainType: "l1"})`: Connects
//    *   to the `sepolia` network config, treating it as an "l1" network with the
//    *   appropriate viem extensions.
//    *
//    * - `await network.connect({network: "hardhatOp", chainType: "optimism"})`:
//    *   Creates a new EDR instance in Optimism mode, using the `hardhatOp`
//    *   network config.
//    *
//    * - `await network.connect()`: Creates a new EDR instance with the default
//    *    network config (i.e. `hardhat`), the `generic` chain type, and no
//    *    viem extensions.
//    *
//    * Each network connection object has a `provider` property and other
//    * network-related fields added by plugins, like `viem` and `networkHelpers`.
//    */
// });

// Utilitaire pour initialiser le réseau et déployer le contrat à chaque test
async function deployNiel42Fixture() {
  const connection = await network.connect();
  const viem = connection.viem;
  const publicClient = await viem.getPublicClient();
  const signers = await viem.getWalletClients();
  const owner = signers[0];
  const addr1 = signers[1];
  const addr2 = signers[2];
  // @ts-ignore
  const deployment = await viem.deployContract("Niel42", [], { account: owner });
  const read = deployment.read;
  const write = deployment.write;
  return {
    deployment,   // contient address, abi, etc.
    read,         // fonctions read-only
    write,        // fonctions write (transactions)
    owner,        // le propriétaire du contrat
    addr1,        // un autre compte pour les tests
    addr2,        // un autre compte pour les tests
    publicClient, // client public pour interagir avec le contrat (par exemple, pour récupérer les événements)
  };
}

describe("Niel42 - Construction", async function () {

  it("Should have 'Niel42' as name", async () => {
    const { read } = await deployNiel42Fixture();
    assert.equal(await read.name(), "Niel42");
  });

  it("Should have 'N42' as symbol", async () => {
    const { read } = await deployNiel42Fixture();
    assert.equal(await read.symbol(), "N42");
  });

  it("Should have 18 decimals", async () => {
    const { read } = await deployNiel42Fixture();
    assert.equal(await read.decimals(), 18);
  });

  it("Should have a total supply of 1,000,000 * 10^18", async () => {
    const { read } = await deployNiel42Fixture();
    const totalSupply = await read.totalSupply();
    const expected = BigInt("1000000") * (BigInt("10") ** BigInt("18"));
    assert.equal(totalSupply, expected);
  });

  it("Should assign the total supply to the owner", async () => {
    const { read, owner } = await deployNiel42Fixture();
    const ownerBalance = await read.balanceOf([owner.account.address]);
    const totalSupply = await read.totalSupply();
    assert.equal(ownerBalance, totalSupply);
  });

  it("Should emit a Transfer event with the total supply", async () => {
    const { deployment, read, owner, publicClient } = await deployNiel42Fixture();
    const events = await publicClient.getContractEvents({
      address: deployment.address,
      abi: deployment.abi,
      eventName: "Transfer",
      fromBlock: 0n,
      strict: true,
    });
    assert.equal(events.length, 1);
    const event = events[0];
    assert.equal(event.args._from.toLowerCase(), "0x0000000000000000000000000000000000000000");
    assert.equal(event.args._to.toLowerCase(), owner.account.address.toLowerCase());
    assert.equal(event.args._value, await read.totalSupply());
  });
});

describe("Niel42 - balanceOf", async function () {

  it("Should return the balance of the owner", async () => {
    // All the tokens are assigned to the owner at deployment
    const { read, owner } = await deployNiel42Fixture();
    const ownerBalance = await read.balanceOf([owner.account.address]);
    const totalSupply = await read.totalSupply();
    assert.equal(ownerBalance, totalSupply);
  });

  it("Should return 0 for an address with no balance", async () => {
    const { read, owner, addr1 } = await deployNiel42Fixture();
    assert.notEqual(addr1.account.address.toLowerCase(), owner.account.address.toLowerCase());
    const ownerBalance = await read.balanceOf([owner.account.address]);
    const totalSupply = await read.totalSupply();
    assert.equal(ownerBalance, totalSupply);
    const addr1Balance = await read.balanceOf([addr1.account.address]);
    assert.equal(addr1Balance, 0n);
  });

});

describe("Niel42 - transfer", async function () {

  it("Should transfer tokens between accounts", async () => {
    const { read, write, owner, addr1 } = await deployNiel42Fixture();
    const amount = BigInt("10000");
    await write.transfer([addr1.account.address, amount], { account: owner.account.address });
    const totalSupply = await read.totalSupply();
    const ownerBalance = await read.balanceOf([owner.account.address]);
    const addr1Balance = await read.balanceOf([addr1.account.address]);
    assert.equal(ownerBalance, totalSupply - amount);
    assert.equal(addr1Balance, amount);
  });

  it("Should fail if the sender does not have enough tokens", async () => {
    const { write, owner, addr1 } = await deployNiel42Fixture();
    const amount = BigInt("1000000") * (BigInt("10") ** BigInt("18")) + BigInt("1");
    await assert.rejects(
      write.transfer([addr1.account.address, amount], { account: owner.account.address }),
      /ERC20: transfer amount exceeds balance/
    );
  });

  it("Should fail if the recipient is the zero address", async () => {
    const { write, owner } = await deployNiel42Fixture();
    const amount = BigInt("100");
    await assert.rejects(
      write.transfer(["0x0000000000000000000000000000000000000000", amount], { account: owner.account.address }),
      /ERC20: transfer to the zero address/
    );
  });

  it("Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event", async () => {
    const { deployment, write, owner, addr1, publicClient } = await deployNiel42Fixture();
    const amount = BigInt("0");
    await write.transfer([addr1.account.address, amount], { account: owner.account.address });
    const events = await publicClient.getContractEvents({
      address: deployment.address,
      abi: deployment.abi,
      eventName: "Transfer",
      strict: true,
    });
    assert.equal(events.length, 1);
    const event = events[0];
    assert.equal(event.args._from.toLowerCase(), owner.account.address.toLowerCase());
    assert.equal(event.args._to.toLowerCase(), addr1.account.address.toLowerCase());
    assert.equal(event.args._value, amount);
  });

});

describe("Niel42 - allowance", async function () {

  // The allowance is the amount of tokens that an owner allows a spender to transfer on their behalf.
  // Use approve to set the allowance.

  it("Should return the allowance of the owner", async () => {
    const { read, write, owner, addr1 } = await deployNiel42Fixture();
    const amount = BigInt("100");
    await write.approve([addr1.account.address, amount], { account: owner.account.address });
    const allowance = await read.allowance([owner.account.address, addr1.account.address]);
    assert.equal(allowance, amount);
  });

  it("Should return 0 for an address with no allowance", async () => {
    const { read, write, owner, addr1, addr2 } = await deployNiel42Fixture();
    const amount = BigInt("100");
    await write.approve([addr1.account.address, amount], { account: owner.account.address });
    const allowance = await read.allowance([owner.account.address, addr2.account.address]);
    assert.equal(allowance, BigInt("0"));
  });

  it("Should allow setting allowance", async () => {
    const { read, write, owner, addr1 } = await deployNiel42Fixture();
    const amount = BigInt("500");
    await write.approve([addr1.account.address, amount], { account: owner.account.address });
    const allowance = await read.allowance([owner.account.address, addr1.account.address]);
    assert.equal(allowance, amount);
  });

  it("Should fail if the spender is the zero address", async () => {
    const { write, owner } = await deployNiel42Fixture();
    const amount = BigInt("100");
    await assert.rejects(
      write.approve(["0x0000000000000000000000000000000000000000", amount], { account: owner.account.address }),
      /ERC20: approve to the zero address/
    );
  });

  it("Should allow spending within the approved allowance", async () => {
    const { read, write, owner, addr1, addr2 } = await deployNiel42Fixture();
    const amount = BigInt("200");
    await write.approve([addr1.account.address, amount], { account: owner.account.address });
    await write.transferFrom([owner.account.address, addr2.account.address, amount], { account: addr1.account.address });
    assert.equal(await read.balanceOf([addr2.account.address]), amount);
    assert.equal(await read.allowance([owner.account.address, addr1.account.address]), BigInt("0"));
  });

  it("Should fail if spender tries to spend more than allowed", async () => {
    const { write, owner, addr1, addr2 } = await deployNiel42Fixture();
    const amount = BigInt("100");
    await write.approve([addr1.account.address, amount], { account: owner.account.address });
    await assert.rejects(
      write.transferFrom([owner.account.address, addr2.account.address, amount + BigInt("1")], { account: addr1.account.address }),
      /ERC20: insufficient allowance/
    );
  });

});

describe("Niel42 - Increase and Decrease Allowance", async function () {

  it("Should increase the allowance", async () => {
    const { read, write, owner, addr1 } = await deployNiel42Fixture();
    const initialAmount = BigInt("200");
    await write.approve([addr1.account.address, initialAmount], { account: owner.account.address });
    const increaseAmount = BigInt("100");
    await write.increaseAllowance([addr1.account.address, increaseAmount], { account: owner.account.address });
    assert.equal(await read.allowance([owner.account.address, addr1.account.address]), initialAmount + increaseAmount);
  });

  it("Should decrease the allowance", async () => {
    const { read, write, owner, addr1 } = await deployNiel42Fixture();
    const initialAmount = BigInt("300");
    await write.approve([addr1.account.address, initialAmount], { account: owner.account.address });
    const decreaseAmount = BigInt("100");
    await write.decreaseAllowance([addr1.account.address, decreaseAmount], { account: owner.account.address });
    assert.equal(await read.allowance([owner.account.address, addr1.account.address]), initialAmount - decreaseAmount);
  });

  it("Should fail if trying to decrease allowance below zero", async () => {
    const { write, owner, addr1 } = await deployNiel42Fixture();
    const initialAmount = BigInt("100");
    await write.approve([addr1.account.address, initialAmount], { account: owner.account.address });
    await assert.rejects(
      write.decreaseAllowance([addr1.account.address, initialAmount + BigInt("1")], { account: owner.account.address }),
      /ERC20: decreased allowance below zero/
    );
  });

});

describe("Niel42 - transferFrom", async function () {

  it("Should allow transferFrom when approved", async () => {
    const { read, write, owner, addr1, addr2 } = await deployNiel42Fixture();
    await write.approve([addr1.account.address, BigInt("200")], { account: owner.account.address });
    await write.transferFrom([owner.account.address, addr2.account.address, BigInt("100")], { account: addr1.account.address });
    assert.equal(await read.balanceOf([addr2.account.address]), BigInt("100"));
  });

  it("Should decrease allowance on transferFrom", async () => {
    const { read, write, owner, addr1, addr2 } = await deployNiel42Fixture();
    await write.approve([addr1.account.address, BigInt("200")], { account: owner.account.address });
    await write.transferFrom([owner.account.address, addr2.account.address, BigInt("100")], { account: addr1.account.address });
    assert.equal(await read.allowance([owner.account.address, addr1.account.address]), BigInt("100"));
  });

  it("Should not allow transferFrom more than allowed", async () => {
    const { write, owner, addr1, addr2 } = await deployNiel42Fixture();
    await write.approve([addr1.account.address, BigInt("100")], { account: owner.account.address });
    await assert.rejects(
      write.transferFrom([owner.account.address, addr2.account.address, BigInt("200")], { account: addr1.account.address }),
      /ERC20: insufficient allowance/
    );
  });

});

describe("Niel42 - Edge Cases", async function () {

  it("Should allow transferring to self", async () => {
    const { read, write, owner } = await deployNiel42Fixture();
    await write.transfer([owner.account.address, BigInt("100")], { account: owner.account.address });
    assert((await read.balanceOf([owner.account.address])) > BigInt("0"));
  });

  it("Should not allow exceeding uint256_max in increaseAllowance", async () => {
    const { write, owner, addr1 } = await deployNiel42Fixture();
    const Maxuint256 = (BigInt("2") ** BigInt("256")) - BigInt("1");
    await write.approve([addr1.account.address, Maxuint256], { account: owner.account.address });
    await assert.rejects(
      write.increaseAllowance([addr1.account.address, BigInt("1")], { account: owner.account.address }),
      /revert/
    );
  });

});


