/* eslint-disable no-undef */
const Certificates = artifacts.require('Certificates');
const Issuers = artifacts.require('Issuers');
const Escrow = artifacts.require('Escrow');
const PathToken = artifacts.require('PathToken');
const PublicKeys = artifacts.require('PublicKeys');
const fs = require('fs');
const networkDetector = require('./networkDetector');
/* eslint-enable no-undef */

module.exports = async (deployer) => {
    deployer.deploy(PathToken)
        .then(() => {
            deployer.deploy(Issuers)
                .then(async () => {
                    deployer.deploy(PublicKeys)
                        .then(async () => {
                            deployer.deploy(Certificates, Issuers.address)
                                .then(async () => {
                                    deployer.deploy(Escrow, PathToken.address, Certificates.address, PublicKeys.address)
                                        .then(async () => {
                                            console.log('==================================================');
                                            console.log('======= Contracts deployed: ======================');
                                            console.log(`PathToken: ${PathToken.address}`);
                                            console.log(`Issuers: ${Issuers.address}`);
                                            console.log(`Certificates: ${Certificates.address}`);
                                            console.log(`Escrow: ${Escrow.address}`);
                                            console.log(`PublicKeys: ${PublicKeys.address}`);
                                            console.log('==================================================');
                                            const network = await networkDetector.getNetworkName(PathToken.web3);
                                            // Write abi's to files

                                            const abi = {
                                                PathToken: { address: PathToken.address, abi: PathToken.abi },
                                                Issuers: { address: Issuers.address, abi: Issuers.abi },
                                                Certificates: { address: Certificates.address, abi: Certificates.abi },
                                                Escrow: { address: Escrow.address, abi: Escrow.abi },
                                                PublicKeys: { address: PublicKeys.address, abi: PublicKeys.abi },
                                            };

                                            fs.writeFileSync(`./build/${network}.abi.json`, JSON.stringify(abi));
                                        });
                                });
                        });
                });
        });
};
