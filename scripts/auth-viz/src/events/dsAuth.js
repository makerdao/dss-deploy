const { getRawLogs } = require('../helper');

// ------------------------------------------------------------

module.exports.getDSAuthEvents = async contract => {
  const setAuth = await getLogSetAuthorityEvents(contract);
  const setOwner = await getLogSetOwnerEvents(contract);
  return setAuth.concat(setOwner);
};

// ------------------------------------------------------------

const getLogSetAuthorityEvents = async contract => {
  const raw = await getRawLogs(contract, {}, 'LogSetAuthority');
  return raw.map(log => {
    return {
      type: 'LogSetAuthority',
      blockNumber: log.blockNumber,
      logIndex: log.logIndex,
      src: log.address,
      authority: log.returnValues.authority
    };
  });
};

const getLogSetOwnerEvents = async contract => {
  const raw = await getRawLogs(contract, {}, 'LogSetOwner');
  return raw.map(log => {
    return {
      type: 'LogSetOwner',
      blockNumber: log.blockNumber,
      logIndex: log.logIndex,
      src: log.address,
      owner: log.returnValues.owner
    };
  });
};
