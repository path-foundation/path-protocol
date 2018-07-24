/* Use this tool to generate test public key/address */
const EC = require('elliptic').ec;
const BN = require('bn.js');

const ec = new EC('secp256k1');
const { keccak256 } = require('js-sha3');

// const privateKey = Buffer.alloc(32, 0);
// privateKey[31] = 1;

// console.log(`PK::${privateKey.toString('hex')}`);

const generateKeys = (privateKey) => {
    const G = ec.g; // Generator point
    const pk = new BN(privateKey); // private key as big number

    const pubPoint = G.mul(pk); // EC multiplication to determine public point

    const x = pubPoint.getX().toBuffer(); //32 bit x co-ordinate of public point
    const y = pubPoint.getY().toBuffer(); //32 bit y co-ordinate of public point

    const publicKey = Buffer.concat([x, y]);

    //console.log(`public key::${publicKey.toString('hex')}`);

    const publicKeyHash = keccak256(publicKey); // keccak256 hash of  publicKey

    const buf2 = Buffer.from(publicKeyHash, 'hex');

    // Address is the last 20 bytes of public key hash
    const address = `0x${buf2.slice(-20).toString('hex')}`;
    return { address, publicKey: publicKey.toString('hex') };
};

module.exports.generateKeys = generateKeys;
