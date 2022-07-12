const instance = await NftMarket.deployed();

// this commands must be in one line for the truffle console to accept them (when pasting them into the console)
// command save without formatting cmd + m + s
instance.mintToken('https://gateway.pinata.cloud/ipfs/QmaLF2YPvkCSRoSHitZWzfxDmJ3umuC2feuvakrc6bx8rg','500000000000000000',{value:'25000000000000000',from:accounts[0]});
instance.mintToken('https://gateway.pinata.cloud/ipfs/QmaQBv7ZTJXsCTcQGBLeSwvzMFCmegtkuVFat2cAJBNAKs','300000000000000000',{ value: '25000000000000000', from: accounts[0]});
