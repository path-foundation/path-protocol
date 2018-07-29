/* eslint no-param-reassign: off, no-return-assign: off */
const shell = require('shelljs');
const Mustache = require('mustache');
const fs = require('fs');
const parseNatspec = require('./parse-natspec');

const cmd = 'solc   --pretty-json   --allow-paths ./contracts   --combined-json abi,ast,compact-format,devdoc,hashes,interface,metadata,opcodes,srcmap,srcmap-runtime,userdoc   openzeppelin-solidity=/Users/leyboan1/dev/cry/path-protocol/node_modules/openzeppelin-solidity $(find ./contracts -type f -name "*.sol"  -not -path "*token/*" -not -path "*test/*")';

//console.log(cmd);

const json = JSON.parse(shell.exec(cmd, { silent: true }).stdout);

//fs.writeFileSync('./docs/abi.json', JSON.stringify(json, null, 2));

const excludeContracts = [
    'PathToken',
    'TransferAndCallback',
    'TransferAndCallbackInterface',
    'TransferAndCallbackReceiver',
    'Migrations',
    'Deputable',
];

// Modify json
const contracts = [];
Object.keys(json.contracts).forEach(cname => {
    if (cname.includes('node_modules')) return;

    // Contract name
    const contractName = cname.split(':')[1];
    // File name
    const sourceName = cname.split(':')[0];

    const source = json.sources[sourceName];

    if (excludeContracts.includes(contractName)) return;

    const contractSrc = source.AST.nodes.find(node => node.nodeType === 'ContractDefinition' && node.name === contractName);

    const jsonContract = json.contracts[cname];
    const abi = JSON.parse(jsonContract.abi);
    const devdocs = JSON.parse(jsonContract.devdoc);
    const userdocs = JSON.parse(jsonContract.userdoc);

    const funcs = [];

    abi.filter(f => f.type === 'function').sort((a, b) => ((a.name > b.name) ? 1 : -1)).forEach(f => {
        const sig = `${f.name}(${f.inputs.map(i => i.type).join(',')})`;
        const devdoc = devdocs.methods[sig] || { details: null, params: null };
        const userdoc = userdocs.methods[sig] || { notice: null };

        if (!devdoc && !userdoc) return;

        const display = `${f.name}(${f.inputs.map(i => `${i.type} ${i.name}`).join(', ')})`;

        // Anchor replaces spaces with `-` and removes all other non alphanumerics
        const displayAnchor = display.trim().toLowerCase()
            .replace(/[^a-zA-Z0-9_ ]+/g, '')
            .replace(/\s+/g, '-');

        const func = {
            name: f.name,
            inputs: JSON.parse(JSON.stringify(f.inputs || [])),
            inputsExist: f.inputs.length > 0,
            outputs: JSON.parse(JSON.stringify(f.outputs || [])),
            outputsExist: f.outputs.length > 0,
            sig,
            display,
            displayAnchor,
            devdoc: devdoc.details,
            devdocExists: !!devdoc.details,
            userdoc: userdoc.notice,
            userdocExists: !!userdoc.notice,
            constant: f.constant,
            payable: f.stateMutability === 'payable',
        };

        // For output variables that are missing name, create a default name
        // for display purposes
        func.outputs.filter(o => !o.name).forEach(o => o.name = `_${o.type}`);

        // Add input descriptions
        func.inputs.forEach(i => {
            if (devdoc.params && devdoc.params[i.name]) {
                i.desc = devdoc.params[i.name];
            }
        });

        funcs.push(func);

        const funcSource = contractSrc.nodes.find(node => node.nodeType === 'FunctionDefinition' && node.name === func.name);
        if (funcSource) {
            const doc = parseNatspec(funcSource.documentation);

            // Add output description
            func.outputs.forEach(o => {
                o.desc = doc[`return:${o.name}`];
            });
        }
    });

    const contract = {
        name: contractName,
        doc: {},
        funcs,
    };
    contracts.push(contract);

    if (contractSrc) {
        const doc = parseNatspec(contractSrc.documentation);
        contract.doc = {
            title: doc.title,
            notice: doc.notice,
            titleExists: !!doc.title,
            noticeExists: !!doc.notice,
        };
    }
});

const contractsData = { contracts };

//fs.writeFileSync('docs/data.json', JSON.stringify(contractsData, null, 2));

const template = fs.readFileSync(`${__dirname}/api.mustache`);

const md = Mustache.render(template.toString(), contractsData);

fs.writeFileSync('docs/api.md', md);

//console.log(md);
