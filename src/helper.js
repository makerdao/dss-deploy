const Web3 = require('web3');

const url = process.env.ETH_RPC_URL
  ? process.env.ETH_RPC_URL
  : 'http://localhost:2000';

module.exports.web3 = new Web3(new Web3.providers.HttpProvider(url));
