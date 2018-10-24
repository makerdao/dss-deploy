const { getRawLogs } = require('./shared');
const { signatures, message } = require('./shared');

// ------------------------------------------------------------

const ignore = [
  'null',
  'root',
  'deploy',
  'daiMove',
  'moveDgx',
  'moveEth',
  'moveRep',
  'spotDgx',
  'spotEth',
  'spotRep',
  'daiGuard'
];

// ------------------------------------------------------------

module.exports.fromGraph = async (graph, sig) => {
  const events = await Promise.all(
    graph.nodes().map(async label => {
      if (ignore.includes(label)) return [];
      const contract = graph.node(label).contract;

      switch (label) {
        case 'vat':
          const vatNotes = await fromContract(contract, sig, 'Note');
          message(vatNotes.length, type(sig), label);
          return vatNotes;

        default:
          const dsNotes = await fromContract(contract, sig, 'LogNote');
          message(dsNotes.length, type(sig), label);
          return dsNotes;
      }
    })
  );

  return [].concat.apply([], events);
};

// ------------------------------------------------------------

const fromContract = async (contract, sig, eventName) => {
  const raw = await getRawLogs(contract, { sig }, eventName);

  return raw.map(log => {
    const guy = log.returnValues.foo;
    return {
      blockNumber: log.blockNumber,
      logIndex: log.logIndex,
      src: log.address,
      guy: '0x' + guy.substr(guy.length - 40),
      type: type(sig)
    };
  });
};

// ------------------------------------------------------------

const type = sig => {
  switch (sig) {
    case signatures.rely:
      return 'rely';
    case signatures.deny:
      return 'deny';
    default:
      throw new Error(`unknown event sig: ${sig}`);
  }
};

// ------------------------------------------------------------
