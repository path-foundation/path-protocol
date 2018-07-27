/* eslint-disable no-undef */
const Certificates = artifacts.require('Certificates');
const Issuers = artifacts.require('Issuers');
const Escrow = artifacts.require('Escrow');
const PathToken = artifacts.require('PathToken');
const PublicKeys = artifacts.require('PublicKeys');
/* eslint-enable no-undef */

module.exports = function (deployer) {
    deployer.deploy(PathToken)
        .then(() => {
            deployer.deploy(Issuers)
                .then(() => {
                    deployer.deploy(PublicKeys)
                        .then(() => {
                            deployer.deploy(Certificates, Issuers.address)
                                .then(() => {
                                    deployer.deploy(Escrow, PathToken.address, Certificates.address, PublicKeys.address)
                                        .then(() => {
                                            console.log('==================================================');
                                            console.log('======= Contracts deployed: ======================');
                                            console.log(`PathToken: ${PathToken.address}`);
                                            console.log(`Issuers: ${Issuers.address}`);
                                            console.log(`Certificates: ${Certificates.address}`);
                                            console.log(`Escrow: ${Escrow.address}`);
                                            console.log(`PublicKeys: ${PublicKeys.address}`);
                                            console.log('==================================================');
                                        });
                                });
                        });
                });
        });
};
