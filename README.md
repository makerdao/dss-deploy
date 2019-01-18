# Multi Collateral Dai Deployment

This repository contains the smart contract code and bash scripts for deploying the whole `dss` system and provides an initial set up.


### TODO

- Add Dai Saving Rates Module
- Add Cage Module

## Additional Documentation

`dss` is also documented in the [wiki](https://github.com/makerdao/dss/wiki) and in [DEVELOPING.md](https://github.com/makerdao/dss/blob/master/DEVELOPING.md)

## Deployment

### Prerequisites:

- seth/dapp (https://dapp.tools/)

### Steps:
- `export ETH_FROM=YOUR_DEPLOYMENT_ACCOUNT`
- `export ETH_PASSWORD=ACCOUNT_PASSWORD_FILE_PATH`
- `export ETH_KEYSTORE=KEYSTORE_PATH` (If not using the default one)
- `export SETH_CHAIN=<kovan || ropsten || rinkeby || mainnet>` or `export ETH_RPC_URL=YOUR_RPC_NODE_URL`
- `./bin/deploy-all`