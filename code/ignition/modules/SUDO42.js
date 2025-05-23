import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const SUDO42Module = buildModule("SUDO42Module", (m) => {
    const token = m.contract("SUDO42");
    return { token };
});

export default SUDO42Module;
