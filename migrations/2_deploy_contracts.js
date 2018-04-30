/* eslint-disable no-undef */
const Certificates = artifacts.require('Certificates');
const Issuers = artifacts.require('Issuers');
const Escrow = artifacts.require('Escrow');
const PathToken = artifacts.require('PathToken');
/* eslint-enable no-undef */

module.exports = function (deployer) {
    deployer.deploy(PathToken)
        .then(() => {
            deployer.deploy(Issuers)
                .then(() => {
                    deployer.deploy(Certificates, Issuers.address)
                        .then(() => {
                            deployer.deploy(Escrow, PathToken.address, Certificates.address)
                                .then(() => {
                                    console.log('==================================================');
                                    console.log('======= Contracts deployed: ======================');
                                    console.log(`PathToken: ${PathToken.address}`);
                                    console.log(`Issuers: ${Issuers.address}`);
                                    console.log(`Certificates: ${Certificates.address}`);
                                    console.log(`Escrow: ${Escrow.address}`);
                                    console.log('==================================================');
                                });
                        });
                });
        });
};
