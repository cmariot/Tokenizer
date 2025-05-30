import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Niel42MultiSigModule", (m: any) => {
  const deployer = m.getAccount(0);
  const contract = m.contract("Niel42MultiSig", [[deployer], 1]);
  return { contract };
});
