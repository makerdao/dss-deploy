const path = require('path');

const dagre = require('dagre');
const dot = require('graphlib-dot');
const fs = require('mz/fs');
const Web3 = require('web3');

const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:2000'));

// -----------------------------------------------------------------------------
// Constants
// -----------------------------------------------------------------------------

const RELY = web3.eth.abi.encodeFunctionSignature('rely(address)');
const DENY = web3.eth.abi.encodeFunctionSignature('deny(address)');

// -----------------------------------------------------------------------------
// Read Contract Metadata From Testchain Deployment
// -----------------------------------------------------------------------------

const parseAddressJson = async dir => {
  const json = await fs.readFile(path.join(dir, 'addresses.json'));
  return JSON.parse(json);
};

const getAbis = async dir => {
  const files = (await fs.readdir(dir)).filter(path => path.endsWith('.abi'));

  const contracts = await Promise.all(
    files.map(async file => {
      const abi = (await fs.readFile(path.join(dir, file))).toString();
      return {
        file: path.parse(file).name,
        abi: JSON.parse(abi)
      };
    })
  );

  return contracts.reduce((acc, elem) => {
    acc[elem.file] = elem.abi;
    return acc;
  }, {});
};

// -----------------------------------------------------------------------------
// Construct Nodes
// -----------------------------------------------------------------------------

const contracts = (graph, addresses, abis) => {
  // Deployer
  graph.setNode('null', {
    label: 'NULL',
    contract: new web3.eth.Contract(
      [],
      '0x0000000000000000000000000000000000000000'
    )
  });

  // Deployer
  graph.setNode('deploy', {
    label: 'DssDeploy',
    contract: new web3.eth.Contract(abis.DssDeploy, addresses.MCD_DEPLOY)
  });

  // CDP's
  graph.setNode('vat', {
    label: 'Vat',
    contract: new web3.eth.Contract(abis.Vat, addresses.MCD_VAT)
  });
  graph.setNode('pit', {
    label: 'Pit',
    contract: new web3.eth.Contract(abis.Pit, addresses.MCD_PIT)
  });
  graph.setNode('drip', {
    label: 'Drip',
    contract: new web3.eth.Contract(abis.Drip, addresses.MCD_DRIP)
  });

  // auctions
  graph.setNode('cat', {
    label: 'Cat',
    contract: new web3.eth.Contract(abis.Cat, addresses.MCD_CAT)
  });
  graph.setNode('vow', {
    label: 'Vow',
    contract: new web3.eth.Contract(abis.Vow, addresses.MCD_VOW)
  });
  graph.setNode('flap', {
    label: 'Flapper',
    contract: new web3.eth.Contract(abis.Flapper, addresses.MCD_FLAP)
  });
  graph.setNode('flop', {
    label: 'Flopper',
    contract: new web3.eth.Contract(abis.Flopper, addresses.MCD_FLOP)
  });

  // governance
  graph.setNode('gov', {
    label: 'MKR',
    contract: new web3.eth.Contract(abis.DSToken, addresses.MCD_GOV)
  });
  graph.setNode('mom', {
    label: 'Mom',
    contract: new web3.eth.Contract(abis.DSProxy, addresses.MCD_MOM)
  });

  // DAI
  graph.setNode('dai', {
    label: 'DAI',
    contract: new web3.eth.Contract(abis.DSToken, addresses.MCD_DAI)
  });
  graph.setNode('daiGuard', {
    label: 'DSGuard',
    contract: new web3.eth.Contract(abis.DSGuard, addresses.MCD_DAI_GUARD)
  });
  graph.setNode('daiJoin', {
    label: 'DaiJoin',
    contract: new web3.eth.Contract(abis.DaiJoin, addresses.MCD_JOIN_DAI)
  });
  graph.setNode('daiMove', {
    label: 'DaiMove',
    contract: new web3.eth.Contract(abis.DaiMove, addresses.MCD_MOVE_DAI)
  });

  // DGX
  graph.setNode('pipDgx', {
    label: 'Pip (DGX)',
    contract: new web3.eth.Contract(abis.DSValue, addresses.PIP_DGX)
  });
  graph.setNode('joinDgx', {
    label: 'GemJoin (DGX)',
    contract: new web3.eth.Contract(abis.GemJoin, addresses.MCD_JOIN_DGX)
  });
  graph.setNode('moveDgx', {
    label: 'GemMove (DGX)',
    contract: new web3.eth.Contract(abis.GemMove, addresses.MCD_MOVE_DGX)
  });
  graph.setNode('flipDgx', {
    label: 'Flipper (DGX)',
    contract: new web3.eth.Contract(abis.Flipper, addresses.MCD_FLIP_DGX)
  });
  graph.setNode('spotDgx', {
    label: 'Spotter (DGX)',
    contract: new web3.eth.Contract(abis.Spotter, addresses.MCD_SPOT_DGX)
  });

  // ETH
  graph.setNode('pipEth', {
    label: 'Pip (ETH)',
    contract: new web3.eth.Contract(abis.DSValue, addresses.PIP_ETH)
  });
  graph.setNode('joinEth', {
    label: 'ETHJoin',
    contract: new web3.eth.Contract(abis.ETHJoin, addresses.MCD_JOIN_ETH)
  });
  graph.setNode('moveEth', {
    label: 'GemMove (ETH)',
    contract: new web3.eth.Contract(abis.GemMove, addresses.MCD_MOVE_ETH)
  });
  graph.setNode('flipEth', {
    label: 'Flipper (ETH)',
    contract: new web3.eth.Contract(abis.Flipper, addresses.MCD_FLIP_ETH)
  });
  graph.setNode('spotEth', {
    label: 'Spotter (ETH)',
    contract: new web3.eth.Contract(abis.Spotter, addresses.MCD_SPOT_ETH)
  });

  // REP
  graph.setNode('Rep', {
    label: 'REP',
    contract: new web3.eth.Contract(abis.DSToken, addresses.REP)
  });
  graph.setNode('pipRep', {
    label: 'Pip (REP)',
    contract: new web3.eth.Contract(abis.DSValue, addresses.PIP_REP)
  });
  graph.setNode('joinRep', {
    label: 'GemJoin (REP)',
    contract: new web3.eth.Contract(abis.GemJoin, addresses.MCD_JOIN_REP)
  });
  graph.setNode('moveRep', {
    label: 'GemMove (REP)',
    contract: new web3.eth.Contract(abis.GemMove, addresses.MCD_MOVE_REP)
  });
  graph.setNode('flipRep', {
    label: 'Flipper (REP)',
    contract: new web3.eth.Contract(abis.Flipper, addresses.MCD_FLIP_REP)
  });
  graph.setNode('spotRep', {
    label: 'Spotter (REP)',
    contract: new web3.eth.Contract(abis.Spotter, addresses.MCD_SPOT_REP)
  });

  return graph;
};

// -----------------------------------------------------------------------------
// Build Edges
// -----------------------------------------------------------------------------

const apply = async (events, graph) => {
  events.map(event => {
    switch (event.type) {
      case 'rely':
        const node = label(event.src, graph);
        const edges = graph.outEdges(node);
        console.log(edges);
        graph.setEdge(
          label(event.src, graph),
          label(event.guy, graph),
          'rely',
          'rely'
        );
        break;
      case 'deny':
        graph.removeEdge(
          label(event.src, graph),
          label(event.guy, graph),
          'deny',
          'deny'
        );
        break;
    }
  });

  return graph;
};

// -----------------------------------------------------------------------------
// Reverse Lookup
// -----------------------------------------------------------------------------

const label = (address, graph) => {
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
// Per Contract Event Fetchers
// -----------------------------------------------------------------------------

const getDSAuthEvents = async contract => {
  const setAuth = await getLogSetAuthorityEvents(contract);
  const setOwner = await getLogSetOwnerEvents(contract);
  return setAuth.concat(setOwner);
};

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

const getDSNoteEvents = async (contract, sig) => {
  return await getNoteEvents(contract, sig, 'LogNote');
};

const getVatNoteEvents = async (contract, sig) => {
  return await getNoteEvents(contract, sig, 'Note');
};

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

const getRawLogs = async (contract, filter, EventName) => {
  return await contract.getPastEvents(EventName, {
    filter,
    fromBlock: 0,
    toBlock: web3.eth.blockNumber
  });
};

// -----------------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------------

const main = async () => {
  const testchainOutputDir = process.argv[2];
  if (!testchainOutputDir) {
    throw new Error('you must provide a path to the testchain output dir');
  }

  const addresses = await parseAddressJson(testchainOutputDir);
  const abis = await getAbis(testchainOutputDir);

  let graph = new dagre.graphlib.Graph();
  graph = contracts(graph, addresses, abis);

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

main();
