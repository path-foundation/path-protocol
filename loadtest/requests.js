// // truffle exec loadtest/requests.js --network=ropsten
// /* eslint prefer-destructuring: off, no-plusplus: off,
// no-await-in-loop: off, no-loop-func: off, no-return-assign: off */

// const contract = artifacts.require('Requests');
// const { sha256 } = require('js-sha256');

// // Ropsten
// const contractAddress = '0xa77f1f7103e40c375a9ff4413fdb60d78c7f2e28';

// module.exports = async (callback) => {
//     const instance = await contract.at(contractAddress);
//     const accounts = contract.currentProvider.addresses;

//     async function getTxnCount (account) {
//         return new Promise((resolve, reject) => {
//             contract.web3.eth.getTransactionCount(account, (err, count) => {
//                 resolve(count);
//             });
//         });
//     }

//     async function writeData() {
//         const user = accounts[1];
//         let gas = 0;

//         //for (const user of users) {
//         console.log(`Adding requests for ${user}`);

//         const promises = [];

//         let nonce = await getTxnCount(accounts[0]);

//         for (let i = 0; i < 110; i++) {
//             console.log([user, user, `0x${sha256(`${i}`)}`]);
//             promises.push(instance.addRequest(user, user, `0x${sha256(`${i}`)}`, { nonce: nonce++ })
//                 .then(tx => {
//                     gas += tx.receipt.gasUsed;
//                     console.log('');
//                 }));
//         }

//         try {
//             await Promise.all(promises);
//         } catch (error) {
//             console.error(error);
//         }

//         console.log(gas);
//     }

//     async function getUserRequestCount(account) {
//         const cnt = await instance.getUserRequestCount(account);

//         console.log(cnt.toNumber());

//         return cnt;
//     }

//     async function readData() {
//         const cnt = await getUserRequestCount(accounts[1]);
//         console.log(cnt);

//         //const promises = [];

//         for (let i = 0; i < cnt; i++) {
//             //promises.push(instance.getRequest(accounts[1], i));
//             console.log(`Request: ${await instance.getRequest(accounts[1], i)}`);
//         }

//         // Promise.all(promises)
//         //     .then(data => console.log(data));
//     }

//     //await writeData();
//     await readData();
//     //await getUserRequestCount();

//     callback('done');
// };
