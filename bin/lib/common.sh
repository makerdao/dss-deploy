#!/usr/bin/env bash

# Set fail flags
set -eo pipefail

# Set internal paths
BIN_DIR=${BIN_DIR:-$(cd "${BASH_SOURCE[0]%/*}/.."&&pwd)}
LIB_DIR=${LIB_DIR:-$BIN_DIR/lib}

# Declare functions
message() {
    echo
    echo ----------------------------------------------
    echo "$@"
    echo ----------------------------------------------
    echo
}

dappBuild() {
  [[ -n $SKIP_BUILD || -n $DAPP_SKIP_BUILD ]] && return

  (cd "$BIN_DIR/.." || exit 1
    dapp "$@" build --extract
  )
}

# Start verbose output
set -x

# Set exported variables
export DAPP_OUT=${DAPP_OUT:-$BIN_DIR/../out}
export ADDRESS_DIR=${ADDRESS_DIR:-$PWD}
export ETH_GAS=${ETH_GAS:-"7000000"}
unset SOLC_FLAGS
