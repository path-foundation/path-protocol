//const artifacts = global.artifacts;

/* eslint-disable no-undef */
const Migrations = artifacts.require('./Migrations.sol');
/* eslint-enable no-undef */

module.exports = (deployer) => {
    deployer.deploy(Migrations);
};
