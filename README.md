# README #

Alpha version of the PATH contract. 

### What is this repository for? ###

* Version 0.0.1

### How do I get set up? ###

* Install node.js ^7.7.3 and npm
* Install truffle: npm install -g truffle
* Install Ganache: http://truffleframework.com/ganache
* Run Ganache
* truffle compile
* truffle migrate
* truffle test

If using VS Code, make sure you have the user setting "solidity.compileUsingRemoteVersion": "latest"

Also, truffle is sometimes lagging with ethereum compiler version included in it; 
to upgrade etehreum compiler for your truffle install:

`cd /Users/<username>/.local/share/npm/lib/node_modules/truffle`

Then open `package.json`, change `solc` version to the desired one, save and run `npm install`.

For functional tests use https://aleybovich.github.io/smart-contract-executor/

### Contribution guidelines ###

* Ask

### Who do I talk to? ###

* info@pathfoundation.io