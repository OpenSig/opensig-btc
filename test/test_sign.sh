#!/bin/sh
#
# opensig bash test file
# 
# Tests the sign function
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

# sign no argument
runTest node $baseDir/src/index.js sign
wait $! 2>/dev/null
assertError "calling sign with no argument results in an error" $'\n'"  error: missing required argument \`file'"

# sign with no funds
echo '{ "expectedURL":"https://blockchain.info/unspent?active=1M9jofAErijG4eiPUy19Qxot1KkPRRzyet", "testType":"response", "file":"test_files/blockchain.info/utxo_response-no_free_outputs.json" }' > testURLResponse1
runTest node $baseDir/src/index.js sign test_files/hello_world.txt -w test_files/wallet/alt-wallet-1  --test-blockchain-api
wait $! 2>/dev/null
assertError "sign a file with no funds generates insufficient funds error" "insufficient funds"
rm -f testURLResponse*

# sign locally
echo '{ "expectedURL":"https://blockchain.info/unspent?active=1M9jofAErijG4eiPUy19Qxot1KkPRRzyet", "testType":"response", "file":"test_files/blockchain.info/utxo_response-single_output.json" }' > testURLResponse1
runTest node $baseDir/src/index.js sign test_files/hello_world.txt -w test_files/wallet/alt-wallet-1 --test-blockchain-api
wait $! 2>/dev/null
assertFile "sign hello_world.txt and output to console" test_files/sign/hello_world-sign-single_input-local.out
rm -f testURLResponse*

# sign with simulated blockchain
echo '{ "expectedURL":"https://blockchain.info/unspent?active=1M9jofAErijG4eiPUy19Qxot1KkPRRzyet", "testType":"response", "file":"test_files/blockchain.info/utxo_response-single_output.json" }' > testURLResponse1
cp test_files/sign/hello_world-sign-single_input.post testURLResponse2
runTest node $baseDir/src/index.js sign test_files/hello_world.txt -p -w test_files/wallet/alt-wallet-1  --test-blockchain-api
wait $! 2>/dev/null
assertFile "sign hello_world.txt with simulated api" test_files/sign/hello_world-sign-single_input-published.out
rm -f testURLResponse*

# sign with amount and fee
echo '{ "expectedURL":"https://blockchain.info/unspent?active=1M9jofAErijG4eiPUy19Qxot1KkPRRzyet", "testType":"response", "file":"test_files/blockchain.info/utxo_response-single_output.json" }' > testURLResponse1
runTest node $baseDir/src/index.js sign test_files/hello_world.txt --amount 20000 --fee 12345 -w test_files/wallet/alt-wallet-1 --test-blockchain-api
wait $! 2>/dev/null
assertFile "sign hello_world.txt and output to console" test_files/sign/hello_world-sign-single_input-alt_amount-local.out
rm -f testURLResponse*

fi;


if [[ $subtest -eq 0 ]] ; then displayOverallResult; fi


