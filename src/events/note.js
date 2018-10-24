const { RELY, DENY } = require('../constants');
const { getRawLogs } = require('../helper');

// ------------------------------------------------------------

module.exports.getDSNoteEvents = async (contract, sig) => {
  return await getNoteEvents(contract, sig, 'LogNote');
};

module.exports.getVatNoteEvents = async (contract, sig) => {
  return await getNoteEvents(contract, sig, 'Note');
};

// ------------------------------------------------------------

const getNoteEvents = async (contract, sig, EventName) => {
  const raw = await getRawLogs(contract, { sig }, EventName);

  let type = '';
  if (sig === RELY) {
    type = 'rely';
  } else if (sig === DENY) {
    type = 'deny';
  } else {
    throw new Error(`unknown event sig: ${sig}`);
  }

  return raw.map(log => {
    const guy = log.returnValues.foo;
    return {
      blockNumber: log.blockNumber,
      logIndex: log.logIndex,
      src: log.address,
      guy: '0x' + guy.substr(guy.length - 40),
      type
    };
  });
};
