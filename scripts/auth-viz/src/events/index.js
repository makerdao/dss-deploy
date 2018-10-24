const note = require('./note');
const dsAuth = require('./dsAuth');
const { signatures } = require('./shared');

// ------------------------------------------------------------

// returns a sorted list of all relevant events
module.exports.events = async graph => {
  let events = [];

  events = events.concat(await rely(graph));
  events = events.concat(await deny(graph));
  events = events.concat(await logSetOwner(graph));
  events = events.concat(await logSetAuthority(graph));

  return sort(events);
};

// ------------------------------------------------------------

const sort = events => {
  return events.sort((a, b) => {
    if (a.blockNumber === b.blockNumber) {
      return a.logIndex - b.logIndex;
    }
    return a.blockNumber - b.blockNumber;
  });
};

// ------------------------------------------------------------

const rely = async graph => {
  return await note.fromGraph(graph, signatures.rely);
};

const deny = async graph => {
  return await note.fromGraph(graph, signatures.deny);
};

const logSetOwner = async graph => {
  return await dsAuth.fromGraph(graph, 'LogSetOwner');
};

const logSetAuthority = async graph => {
  return await dsAuth.fromGraph(graph, 'LogSetAuthority');
};

// ------------------------------------------------------------
