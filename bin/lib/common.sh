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

# Start verbose output
set -x

# Set exported variables
export ADDRESS_DIR=${ADDRESS_DIR:-$PWD}
export ETH_GAS=${ETH_GAS:-"7000000"}
unset SOLC_FLAGS

