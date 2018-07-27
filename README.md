# PATH protocol  [![Build Status](https://travis-ci.org/path-foundation/path-protocol.svg?branch=master)](https://travis-ci.org/path-foundation/path-protocol)

PATH protocol smart contracts. 

### What is this repository for? ###

* Version 0.0.2

### How do I get set up? ###

Prerequisites:
* Install node.js ^8.11.3 and npm
* Install truffle: npm install -g truffle
* Install Ganache: http://truffleframework.com/ganache
* Run Ganache
    * In Ganache settings, set mnemonic to "kiwi just service vital feature rural vibrant copy pledge useless fee forum" - this is so that we can have hardcoded private keys in the tests (truffle doesn't give you an option to retrieve those)
* npm install -g truffle-flattener # Optional, if you want to flatten contracts
* Solidity (by Juan Blanco) extension for VS Code # Optional
* For MacOS install command line tools, by running `xcode-select --install`
* For Windows install build tools, by running `npm install -g windows-build-tools`

Build:
* https://github.com/path-foundation/path-protocol.git && cd path-protocol
* npm install
* truffle compile
* truffle migrate
* truffle test

If using VS Code, add the following user settings (Preferences -> Settings)

```
"solidity.compileUsingRemoteVersion": "latest",
"solidity.packageDefaultDependenciesContractsDirectory": "",
"solidity.packageDefaultDependenciesDirectory": "node_modules",
```

Also, truffle is sometimes lagging with ethereum compiler version included in it; 
to upgrade etehreum compiler for your truffle install:

`cd /Users/<username>/.local/share/npm/lib/node_modules/truffle`

or (when using nvm as a node version manager)

`cd /Users/<username>/.nvm/versions/node/v8.10.0/lib/node_modules/truffle`

Then open `package.json`, change `solc` version to the desired one, save and run `npm install`.

For functional tests use https://aleybovich.github.io/smart-contract-executor/

### Who do I talk to? ###

* info@pathfoundation.io
