// ------------------------------------------------------------

// iterates over events and adds / removes edges accordingly
module.exports.connections = async (events, graph) => {
  events.map(event => {
    const src = label(event.src, graph);
    switch (event.type) {
      case 'rely': {
        const guy = label(event.guy, graph);
        graph.setEdge(src, guy, 'rely');
        break;
      }

      case 'deny': {
        const guy = label(event.guy, graph);
        graph.removeEdge(src, guy, 'deny');
        break;
      }

      case 'LogSetOwner': {
        const owner = label(event.owner, graph);
        graph.setEdge(src, owner, 'rely');
        console.log(graph.outEdges(src));
        break;
      }
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
