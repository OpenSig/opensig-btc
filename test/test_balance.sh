#!/bin/sh
#
# opensig bash test file
# 
# Tests the send function
#
# Options: 
#
#   -w  run in-development (working) tests only
#   -s  run as a subtest.  Don't create own instance of test harness.
#

baseDir=..

working=0
subtest=0

while [ $1 ]; do
    case "$1" in
       -w) working=1;;
       -s) subtest=1;;
    esac
    shift;
done


if [[ $subtest -eq 0 ]] ; then source test_harness.sh; fi


#
# Test Cases
#

if [[ $working -eq 0 ]]
then

# no argument
echo '{ "expectedURL":"https://blockchain.info/q/addressbalance/1M9jofAErijG4eiPUy19Qxot1KkPRRzyet", "testType":"response", "data":"100000000" }' > testURLResponse1
runTest node $baseDir/src/index.js balance -w test_files/wallet/alt-wallet-1 --test-blockchain-api
wait $! 2>/dev/null
assert "calling balance with no argument returns the balance for the default wallet key" "100000000"
rm -f testURLResponse*

# label
echo '{ "expectedURL":"https://blockchain.info/q/addressbalance/15J4SyQ9yCGetJ8uUyUoqjULASspzJMgAa", "testType":"response", "data":"1" }' > testURLResponse1
runTest node $baseDir/src/index.js balance Work -w test_files/wallet/alt-wallet-1 --test-blockchain-api
wait $! 2>/dev/null
assert "calling balance with a label returns the balance for that wallet label" "1"
rm -f testURLResponse*

# wif
echo '{ "expectedURL":"https://blockchain.info/q/addressbalance/15J4SyQ9yCGetJ8uUyUoqjULASspzJMgAa", "testType":"response", "data":"1" }' > testURLResponse1
runTest node $baseDir/src/index.js balance L3ZugXLgbaWpq1hgeRCWKBrAsNYK2Y7Pq64HciUP7K2nVJhGvr2u -w test_files/wallet/alt-wallet-1 --test-blockchain-api
wait $! 2>/dev/null
assert "calling balance with a wif returns the balance for that wif" "1"
rm -f testURLResponse*

# private key
echo '{ "expectedURL":"https://blockchain.info/q/addressbalance/15J4SyQ9yCGetJ8uUyUoqjULASspzJMgAa", "testType":"response", "data":"1" }' > testURLResponse1
runTest node $baseDir/src/index.js balance bd6a451d5d3c008a9d7acaeb6f76a3fa55f638b60fba42255efd5d50f6c8e7ef -w test_files/wallet/alt-wallet-1 --test-blockchain-api
wait $! 2>/dev/null
assert "calling balance with a private key returns the balance for that key" "1"
rm -f testURLResponse*

# file
echo '{ "expectedURL":"https://blockchain.info/q/addressbalance/13hCoaeW632HQHpzvMmiyNbVWk8Bfpvz14", "testType":"response", "data":"1" }' > testURLResponse1
runTest node $baseDir/src/index.js balance test_files/hello_world.txt -w test_files/wallet/alt-wallet-1 --test-blockchain-api
wait $! 2>/dev/null
assert "calling balance with a private key returns the balance for that key" "1"
rm -f testURLResponse*

fi;


if [[ $subtest -eq 0 ]] ; then displayOverallResult; fi


