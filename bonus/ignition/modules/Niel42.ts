import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("NielModule", (m) => {
  const counter = m.contract("Niel42");
  return { counter };
});
