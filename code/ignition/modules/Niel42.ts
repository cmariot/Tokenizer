import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("NielModule", (m) => {
  const contract = m.contract("Niel42");
  return { contract };
});
