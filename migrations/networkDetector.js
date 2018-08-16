module.exports.getNetworkName = (web3) => {
    // web3 v1
    if (web3.eth.net && web3.eth.net.getNetworkType) {
        return web3.eth.net.getNetworkType();
    }

    return new Promise((resolve, reject) => {
        web3.version.getNetwork((err, netId) => {
            if (err) {
                reject(err);
                return;
            }

            switch (netId) {
                case '1':
                    resolve('main');
                    break;
                case '2': // morden
                    resolve('morden');
                    break;
                case '3': // ropsten
                    resolve('ropsten');
                    break;
                case '4': // rinkeby
                    resolve('rinkeby');
                    break;
                default: // custom
                    resolve('private');
            }
        });
    });
};
