const bip39 = require('bip39');
const hdkey = require('ethereumjs-wallet/hdkey');

module.exports.generateAddressesFromSeed = (seed, count) => {
    const hdwallet = hdkey.fromMasterSeed(bip39.mnemonicToSeed(seed));
    const walletHdpath = "m/44'/60'/0'/0/";

    const accounts = [];
    for (let i = 0; i < count; i++) {
        const wallet = hdwallet.derivePath(walletHdpath + i).getWallet();
        const address = wallet.getAddressString();
        const publicKey = wallet.getPublicKey().toString('hex');
        const privateKey = wallet.getPrivateKey().toString('hex');
        accounts.push({ address, privateKey, publicKey });
    }

    return accounts;
};
