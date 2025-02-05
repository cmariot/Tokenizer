const {buildModule} = require("@nomicfoundation/hardhat-ignition/modules");

const AlphaCoin42Module = buildModule("AlphaCoin42Module", (m) => {
    const token = m.contract("AlphaCoin42");
    return { token };
});

export default AlphaCoin42Module;