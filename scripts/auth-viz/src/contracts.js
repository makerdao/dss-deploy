const path = require('path');
const fs = require('mz/fs');
const { web3 } = require('./helper');

// -----------------------------------------------------------------------------

// adds nodes to a graph for all the contracts we are interested in based on
// the contents of the output directory of a testchain deployment
module.exports.contracts = async (graph, testchainOutputDir) => {
  return await setNodes(
    graph,
    await addresses(testchainOutputDir),
    await abis(testchainOutputDir)
  );
};

// -----------------------------------------------------------------------------

const setNodes = async (graph, addresses, abis) => {
  // Null
  graph.setNode('null', {
    label: 'NULL',
    contract: new web3.eth.Contract(
      [],
      '0x0000000000000000000000000000000000000000'
    )
  });

  // Root
  graph.setNode('root', {
    label: 'root',
    contract: new web3.eth.Contract([], addresses.ETH_FROM)
  });

  // Deployer
  graph.setNode('deploy', {
    label: 'DssDeploy',
    contract: new web3.eth.Contract(abis.DssDeploy, addresses.MCD_DEPLOY)
  });
  graph.setNode('vatFab', {
    label: 'VatFab',
    contract: new web3.eth.Contract(
      abis.VatFab,
      await graph
        .node('deploy')
        .contract.methods.vatFab()
        .call()
    )
  });
  graph.setNode('pitFab', {
    label: 'PitFab',
    contract: new web3.eth.Contract(
      abis.PitFab,
      await graph
        .node('deploy')
        .contract.methods.pitFab()
        .call()
    )
  });
  graph.setNode('dripFab', {
    label: 'DripFab',
    contract: new web3.eth.Contract(
      abis.DripFab,
      await graph
        .node('deploy')
        .contract.methods.dripFab()
        .call()
    )
  });
  graph.setNode('vowFab', {
    label: 'VowFab',
    contract: new web3.eth.Contract(
      abis.VowFab,
      await graph
        .node('deploy')
        .contract.methods.vowFab()
        .call()
    )
  });
  graph.setNode('catFab', {
    label: 'CatFab',
    contract: new web3.eth.Contract(
      abis.CatFab,
      await graph
        .node('deploy')
        .contract.methods.catFab()
        .call()
    )
  });
  graph.setNode('tokenFab', {
    label: 'TokenFab',
    contract: new web3.eth.Contract(
      abis.TokenFab,
      await graph
        .node('deploy')
        .contract.methods.tokenFab()
        .call()
    )
  });
  graph.setNode('guardFab', {
    label: 'GuardFab',
    contract: new web3.eth.Contract(
      abis.GuardFab,
      await graph
        .node('deploy')
        .contract.methods.guardFab()
        .call()
    )
  });
  graph.setNode('daiJoinFab', {
    label: 'DaiJoinFab',
    contract: new web3.eth.Contract(
      abis.DaiJoinFab,
      await graph
        .node('deploy')
        .contract.methods.daiJoinFab()
        .call()
    )
  });
  graph.setNode('daiMoveFab', {
    label: 'DaiMoveFab',
    contract: new web3.eth.Contract(
      abis.DaiMoveFab,
      await graph
        .node('deploy')
        .contract.methods.daiMoveFab()
        .call()
    )
  });
  graph.setNode('flapFab', {
    label: 'FlapFab',
    contract: new web3.eth.Contract(
      abis.FlapFab,
      await graph
        .node('deploy')
        .contract.methods.flapFab()
        .call()
    )
  });
  graph.setNode('flopFab', {
    label: 'FlopFab',
    contract: new web3.eth.Contract(
      abis.FlopFab,
      await graph
        .node('deploy')
        .contract.methods.flopFab()
        .call()
    )
  });
  graph.setNode('flipFab', {
    label: 'FlipFab',
    contract: new web3.eth.Contract(
      abis.FlipFab,
      await graph
        .node('deploy')
        .contract.methods.flipFab()
        .call()
    )
  });
  graph.setNode('spotFab', {
    label: 'SpotFab',
    contract: new web3.eth.Contract(
      abis.SpotFab,
      await graph
        .node('deploy')
        .contract.methods.spotFab()
        .call()
    )
  });
  graph.setNode('proxyFab', {
    label: 'ProxyFab',
    contract: new web3.eth.Contract(
      abis.ProxyFab,
      await graph
        .node('deploy')
        .contract.methods.proxyFab()
        .call()
    )
  });

  // Core
  graph.setNode('vat', {
    label: 'Vat',
    contract: new web3.eth.Contract(abis.Vat, addresses.MCD_VAT)
  });

  // UI
  graph.setNode('pit', {
    label: 'Pit',
    contract: new web3.eth.Contract(abis.Pit, addresses.MCD_PIT)
  });

  // Stability Fee Collection
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

const addresses = async dir => {
  const json = await fs.readFile(path.join(dir, 'addresses.json'));
  return JSON.parse(json);
};

// -----------------------------------------------------------------------------

const abis = async dir => {
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
