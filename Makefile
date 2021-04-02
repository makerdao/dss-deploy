build  :; DAPP_BUILD_OPTIMIZE=0 DAPP_BUILD_OPTIMIZE_RUNS=0 dapp --use solc:0.6.12 build
clean  :; dapp clean
test   :; DAPP_BUILD_OPTIMIZE=0 DAPP_BUILD_OPTIMIZE_RUNS=0 dapp --use solc:0.6.12 test -v ${TEST_FLAGS}
