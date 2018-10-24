const { TESTCHAIN } = require('./constants');
const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.HttpProvider(TESTCHAIN));

module.exports.label = (address, graph) => {
  const labels = graph.nodes().filter(label => {
    return (
      graph.node(label).contract.options.address.toLowerCase() ===
      address.toLowerCase()
    );
  });

  if (labels.length === 0) {
    throw new Error(`no nodes found with address ${address}`);
  }

  if (labels.length > 1) {
    throw new Error(`more than one node in the graph with address ${address}`);
  }

  return labels[0];
};

module.exports.getRawLogs = async (contract, filter, EventName) => {
  return await contract.getPastEvents(EventName, {
    filter,
    fromBlock: 0,
    toBlock: web3.eth.blockNumber
  });
};
