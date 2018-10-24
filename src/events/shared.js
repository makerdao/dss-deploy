const { web3 } = require('../helper');

// ------------------------------------------------------------

module.exports.signatures = {
  rely: web3.eth.abi.encodeFunctionSignature('rely(address)'),
  deny: web3.eth.abi.encodeFunctionSignature('deny(address)')
};

// ------------------------------------------------------------

module.exports.message = (count, name, label) => {
  console.log(`found ${count} ${name} events for ${label}`);
};

// ------------------------------------------------------------

module.exports.getRawLogs = async (contract, filter, eventName) => {
  return await contract.getPastEvents(eventName, {
    filter,
    fromBlock: 0,
    toBlock: web3.eth.blockNumber
  });
};

// ------------------------------------------------------------
