import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("NielModule", (m: any) => {
  const contract = m.contract("Niel42");
  return { contract };
});
