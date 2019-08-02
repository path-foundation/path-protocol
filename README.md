# PATH protocol  [![Build Status](https://travis-ci.org/path-foundation/path-protocol.svg?branch=master)](https://travis-ci.org/path-foundation/path-protocol)

PATH protocol smart contracts.

[API Reference](./docs/api.md)

### How do I get set up? ###

Prerequisites:
* On Windows, install [OpenSSL-Win64](https://slproweb.com/products/Win32OpenSSL.html) (1.0.2 version - version 1.1.1 is missing a library needed by eccrypto)
* Install node.js ^8.11.3 and npm
* For MacOS install command line tools, by running `xcode-select --install`
* For Windows install build tools, by running `npm install -g windows-build-tools` from Admin Powershell
* For Linux, install build-essentials: `sudo apt-get install build-essential`
* Install truffle: npm install -g truffle
* Install Ganache: http://truffleframework.com/ganache
* Run Ganache
* npm install -g truffle-flattener
* Solidity (by Juan Blanco) extension for VS Code # Optional
* Set TEST_MNEMONIC environment variable to the same mnemonic as used by Ganache; update .travis.yml and .solcover.js

Prereqs for building documentation:
* Install solc (native):
    * Mac:
        * brew update
        * brew upgrade
        * brew tap ethereum/ethereum
        * brew install solidity
    * Ubuntu:
        * sudo apt-get install software-properties-common
        * sudo add-apt-repository ppa:ethereum/ethereum -y
        * sudo apt-get update
        * sudo apt-get install solc
    * Windows:
        * Download the latest from https://github.com/ethereum/solidity/releases
        * Unzip to c:\Program Files\windows-solidity
        * Add c:\Program Files\windows-solidity to PATH env variable

Build:
* `git clone https://github.com/path-foundation/path-protocol.git && cd path-protocol`
* `npm install`
* `truffle compile`
* `truffle migrate`
* `truffle test`

If using VS Code, add the following user settings (Preferences -> Settings)

```
"solidity.compileUsingRemoteVersion": "latest",
"solidity.packageDefaultDependenciesContractsDirectory": "",
"solidity.packageDefaultDependenciesDirectory": "node_modules",
```

Deploy:
* `truffle migrate --reset`

Unit Test:
* `truffle test`

For functional tests use https://aleybovich.github.io/smart-contract-executor/

### Who do I talk to? ###

* Andrey: info@pathfoundation.io
