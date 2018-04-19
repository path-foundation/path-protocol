const Certificates = artifacts.require("Certificates");
const Issuers = artifacts.require("Issuers");

//const pathTokenAddress = 0x8f0483125fcb9aaaefa9209d8e9d7b9c8b9fb90f; // For test

module.exports = function (deployer) {
    deployer.deploy(Issuers)
        .then(() => {
            console.log(Issuers.address);
            deployer.deploy(Certificates, Issuers.address);
        });
};