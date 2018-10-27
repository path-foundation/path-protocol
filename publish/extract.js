/* Script extracts abi and contract name and overwrites the original file */
const fs = require('fs');

const fileName = process.argv[2];

const fileString = fs.readFileSync(fileName, 'utf8');

const json = JSON.parse(fileString);

const newJson = {
    contractName: json.contractName,
    abi: json.abi,
};

fs.writeFileSync(fileName, JSON.stringify(newJson, null, 2));
