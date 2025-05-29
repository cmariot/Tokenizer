import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Niel42MultiSigModule", (m) => {
  const contract = m.contract("Niel42MultiSig");
  return { contract };
});
