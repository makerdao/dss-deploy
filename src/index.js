const { events } = require('./events');
const { contracts } = require('./contracts');
const { connections } = require('./connections');

const dagre = require('dagre');
const dot = require('graphlib-dot');

// ------------------------------------------------------------

const main = async () => {
  const dir = process.argv[2];
  if (!dir) {
    throw new Error('you must provide a path to the testchain output dir');
  }

  let graph = new dagre.graphlib.Graph();

  graph = await contracts(graph, dir);
  graph = await connections(await events(graph), graph);

  console.log(dot.write(graph));
};

// ------------------------------------------------------------

try {
  main();
} catch (err) {
  console.error(err);
  process.exit(1);
}

// ------------------------------------------------------------
