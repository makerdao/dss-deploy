const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:2000'));

module.exports.RELY = web3.eth.abi.encodeFunctionSignature('rely(address)');
module.exports.DENY = web3.eth.abi.encodeFunctionSignature('deny(address)');
module.exports.TESTCHAIN = 'http://localhost:2000';
