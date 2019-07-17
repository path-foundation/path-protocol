/* eslint object-shorthand: off */
const HDWalletProvider = require('truffle-hdwallet-provider');

const mnemonic = process.env.TEST_MNEMONIC;
const apiKey = process.env.INFURA_API_KEY;
module.exports = {
    compilers: {
        solc: {
            version: "0.4.24",
            optimizer: {
                enabled: true,
                runs: 200,
            },
        }
    },
    networks: {
        development: {
            host: '127.0.0.1',
            port: 7545,
            network_id: '*', // Match any network id
        },
        ropsten: {
            provider: function () {
                return new HDWalletProvider(mnemonic, `https://ropsten.infura.io/${apiKey}`, 0, 10);
            },
            network_id: '3',
            gas: 4712388,
            gasPrice: 70000000000,
        },
    },
};
