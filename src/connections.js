// ------------------------------------------------------------

// iterates over events and adds / removes edges accordingly
module.exports.connections = async (events, graph) => {
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

// ------------------------------------------------------------

// reverse lookup a label from an address
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

// ------------------------------------------------------------
