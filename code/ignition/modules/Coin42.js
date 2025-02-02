import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const Coin42Module = buildModule("Coin42Module", (m) => {
    const token = m.contract("Coin42");
    return { token };
});

export default Coin42Module;