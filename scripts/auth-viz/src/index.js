const { nodes } = require('./nodes');
const { label } = require('./helper');
const { getVatNoteEvents, getDSNoteEvents } = require('./events/note');
const { getDSAuthEvents } = require('./events/dsAuth');
const { RELY, DENY, TESTCHAIN } = require('./constants');

const dot = require('graphlib-dot');
const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.HttpProvider(TESTCHAIN));

// -----------------------------------------------------------------------------
// Build Edges
// -----------------------------------------------------------------------------

const apply = async (events, graph) => {
  events.map(event => {
    const node = label(event.src, graph);
    switch (event.type) {
      case 'rely':
        graph.setEdge(label(event.src, graph), label(event.guy, graph), 'rely');
        break;

      case 'deny':
        graph.removeEdge(
          label(event.src, graph),
          label(event.guy, graph),
          'deny'
        );
        break;

      case 'LogSetOwner':
        const edges = graph.outEdges(node);
        console.log(edges);
        break;
    }
  });

  return graph;
};

// -----------------------------------------------------------------------------
// Fetch All Events
// -----------------------------------------------------------------------------

const fetchEvents = async graph => {
  let events = [];
  events = events.concat(await rely(graph));
  events = events.concat(await deny(graph));
  events = events.concat(await dsAuth(graph));
  return events;
};

const dsAuth = async graph => {
  const events = await Promise.all(
    graph.nodes().map(async label => {
      const node = graph.node(label);
      switch (label) {
        case 'null':
        case 'root':
        case 'vat':
        case 'pit':
        case 'drip':
        case 'cat':
        case 'vow':
        case 'flap':
        case 'flop':
        case 'daiJoin':
        case 'daiMove':
        case 'joinDgx':
        case 'moveDgx':
        case 'flipDgx':
        case 'spotDgx':
        case 'joinEth':
        case 'moveEth':
        case 'flipEth':
        case 'spotEth':
        case 'joinRep':
        case 'moveRep':
        case 'flipRep':
        case 'spotRep':
          console.log(`found 0 DSAuth events for ${label}`);
          return [];
        default:
          const authEvents = await getDSAuthEvents(node.contract);
          console.log(`found ${authEvents.length} DSAuth events for ${label}`);
          return authEvents;
      }
    })
  );

  return [].concat.apply([], events);
};

const rely = async graph => {
  return await fetchNoteEvents(graph, RELY, 'rely');
};

const deny = async graph => {
  return await fetchNoteEvents(graph, DENY, 'deny');
};

const fetchNoteEvents = async (graph, sig, name) => {
  const events = await Promise.all(
    graph.nodes().map(async label => {
      const node = graph.node(label);
      switch (label) {
        case 'null':
        case 'root':
        case 'deploy':
        case 'daiMove':
        case 'moveDgx':
        case 'moveEth':
        case 'moveRep':
        case 'spotDgx':
        case 'spotEth':
        case 'spotRep':
        case 'daiGuard':
          console.log(`found 0 ${name} events for ${label}`);
          return [];
        case 'vat':
          const vatNotes = await getVatNoteEvents(node.contract, sig);
          console.log(`found ${vatNotes.length} ${name} events for ${label}`);
          return vatNotes;
        default:
          const dsNotes = await getDSNoteEvents(node.contract, sig);
          console.log(`found ${dsNotes.length} ${name} events for ${label}`);
          return dsNotes;
      }
    })
  );

  return [].concat.apply([], events);
};

// -----------------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------------

const main = async () => {
  const testchainOutputDir = process.argv[2];
  if (!testchainOutputDir) {
    throw new Error('you must provide a path to the testchain output dir');
  }

  let graph = await nodes(testchainOutputDir);

  const events = await fetchEvents(graph);
  const sorted = events.sort((a, b) => {
    if (a.blockNumber === b.blockNumber) {
      return a.logIndex - b.logIndex;
    }
    return a.blockNumber - b.blockNumber;
  });

  graph = await apply(sorted, graph);

  console.log(dot.write(graph));
};

try {
  main();
} catch (err) {
  console.error(err);
  process.exit(1);
}
