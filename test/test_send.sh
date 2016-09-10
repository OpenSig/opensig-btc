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
runTest node $baseDir/src/index.js send
wait $! 2>/dev/null
assertError "calling send with no argument results in an error" $'\n'"  error: missing required argument \`amount'"

# no --to argument
runTest node $baseDir/src/index.js send 1000
wait $! 2>/dev/null
assertError "calling send with no --to argument results in an error" "  error: missing required argument --to"

# send with no funds
echo '{ "expectedURL":"https://blockchain.info/unspent?active=1M9jofAErijG4eiPUy19Qxot1KkPRRzyet", "testType":"response", "file":"test_files/blockchain.info/utxo_response-no_free_outputs.json" }' > testURLResponse1
runTest node $baseDir/src/index.js send 1000 --to test_files/hello_world.txt -w test_files/wallet/alt-wallet-1  --test-blockchain-api
wait $! 2>/dev/null
assertError "send with no funds generates insufficient funds error" "insufficient funds"
rm -f testURLResponse*

# send locally
echo '{ "expectedURL":"https://blockchain.info/unspent?active=1M9jofAErijG4eiPUy19Qxot1KkPRRzyet", "testType":"response", "file":"test_files/blockchain.info/utxo_response-single_output.json" }' > testURLResponse1
runTest node $baseDir/src/index.js send 5430 --to test_files/hello_world.txt -w test_files/wallet/alt-wallet-1 --test-blockchain-api
wait $! 2>/dev/null
assertFile "send 5430 to hello_world.txt and output to console" test_files/sign/hello_world-sign-single_input-local.out
rm -f testURLResponse*

# sign with simulated blockchain
echo '{ "expectedURL":"https://blockchain.info/unspent?active=1M9jofAErijG4eiPUy19Qxot1KkPRRzyet", "testType":"response", "file":"test_files/blockchain.info/utxo_response-single_output.json" }' > testURLResponse1
cp test_files/sign/hello_world-sign-single_input.post testURLResponse2
runTest node $baseDir/src/index.js send 5430 --to test_files/hello_world.txt -p -w test_files/wallet/alt-wallet-1  --test-blockchain-api
wait $! 2>/dev/null
assertFile "send 5430 to hello_world.txt with simulated api" test_files/sign/hello_world-sign-single_input-published.out
rm -f testURLResponse*

# send 1000 locally to hello_world public address
echo '{ "expectedURL":"https://blockchain.info/unspent?active=1M9jofAErijG4eiPUy19Qxot1KkPRRzyet", "testType":"response", "file":"test_files/blockchain.info/utxo_response-single_output.json" }' > testURLResponse1
runTest node $baseDir/src/index.js send 1000 --to 13hCoaeW632HQHpzvMmiyNbVWk8Bfpvz14 -w test_files/wallet/alt-wallet-1 --test-blockchain-api
wait $! 2>/dev/null
assertFile "send 1000 to public address and output to console" test_files/send/send-1000-to-hello_world-with_fee-10000.out
rm -f testURLResponse*

# send 1000 fee 1 locally to public address
echo '{ "expectedURL":"https://blockchain.info/unspent?active=1M9jofAErijG4eiPUy19Qxot1KkPRRzyet", "testType":"response", "file":"test_files/blockchain.info/utxo_response-single_output.json" }' > testURLResponse1
runTest node $baseDir/src/index.js send 1000 --fee 1 --to 13hCoaeW632HQHpzvMmiyNbVWk8Bfpvz14 -w test_files/wallet/alt-wallet-1 --test-blockchain-api
wait $! 2>/dev/null
assertFile "send 1000 to public address with fee of 1 and output to console" test_files/send/send-1000-to-hello_world-with_fee-1.out
rm -f testURLResponse*

# send from wif
echo '{ "expectedURL":"https://blockchain.info/unspent?active=15J4SyQ9yCGetJ8uUyUoqjULASspzJMgAa", "testType":"response", "file":"test_files/blockchain.info/utxo_response-single_output.json" }' > testURLResponse1
runTest node $baseDir/src/index.js send 1000 --from L3ZugXLgbaWpq1hgeRCWKBrAsNYK2Y7Pq64HciUP7K2nVJhGvr2u --to 13hCoaeW632HQHpzvMmiyNbVWk8Bfpvz14 -w test_files/wallet/alt-wallet-1 --test-blockchain-api
wait $! 2>/dev/null
assertFile "send 1000 from work wif and output to console" test_files/send/send-1000-from-work-with_fee-10000.out
rm -f testURLResponse*

# send from private key
echo '{ "expectedURL":"https://blockchain.info/unspent?active=15J4SyQ9yCGetJ8uUyUoqjULASspzJMgAa", "testType":"response", "file":"test_files/blockchain.info/utxo_response-single_output.json" }' > testURLResponse1
runTest node $baseDir/src/index.js send 1000 --from bd6a451d5d3c008a9d7acaeb6f76a3fa55f638b60fba42255efd5d50f6c8e7ef --to 13hCoaeW632HQHpzvMmiyNbVWk8Bfpvz14 -w test_files/wallet/alt-wallet-1 --test-blockchain-api
wait $! 2>/dev/null
assertFile "send 1000 from private key and output to console" test_files/send/send-1000-from-work-with_fee-10000.out
rm -f testURLResponse*

# send from label
echo '{ "expectedURL":"https://blockchain.info/unspent?active=15J4SyQ9yCGetJ8uUyUoqjULASspzJMgAa", "testType":"response", "file":"test_files/blockchain.info/utxo_response-single_output.json" }' > testURLResponse1
runTest node $baseDir/src/index.js send 1000 --from work --to 13hCoaeW632HQHpzvMmiyNbVWk8Bfpvz14 -w test_files/wallet/alt-wallet-1 --test-blockchain-api
wait $! 2>/dev/null
assertFile "send 1000 from label and output to console" test_files/send/send-1000-from-work-with_fee-10000.out
rm -f testURLResponse*

# send to label
echo '{ "expectedURL":"https://blockchain.info/unspent?active=15J4SyQ9yCGetJ8uUyUoqjULASspzJMgAa", "testType":"response", "file":"test_files/blockchain.info/utxo_response-single_output.json" }' > testURLResponse1
runTest node $baseDir/src/index.js send 1000 --from work --to personal -w test_files/wallet/alt-wallet-1 --test-blockchain-api
wait $! 2>/dev/null
assertFile "send 1000 from label to label and output to console" test_files/send/send-1000-from-work-to-personal.out
rm -f testURLResponse*

# send [1000, 2000] locally to hello_world public address
echo '{ "expectedURL":"https://blockchain.info/unspent?active=1M9jofAErijG4eiPUy19Qxot1KkPRRzyet", "testType":"response", "file":"test_files/blockchain.info/utxo_response-single_output.json" }' > testURLResponse1
runTest node $baseDir/src/index.js send 1000 2000 --to 13hCoaeW632HQHpzvMmiyNbVWk8Bfpvz14 -w test_files/wallet/alt-wallet-1 --test-blockchain-api
wait $! 2>/dev/null
assertFile "send two amounts to public address and output to console" test_files/send/send-two_amounts-to-hello_world-with_fee-10000.out
rm -f testURLResponse*

# send ten amounts locally to hello_world public address
echo '{ "expectedURL":"https://blockchain.info/unspent?active=1M9jofAErijG4eiPUy19Qxot1KkPRRzyet", "testType":"response", "file":"test_files/blockchain.info/utxo_response-single_output.json" }' > testURLResponse1
runTest node $baseDir/src/index.js send 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000 --to 13hCoaeW632HQHpzvMmiyNbVWk8Bfpvz14 -w test_files/wallet/alt-wallet-1 --test-blockchain-api
wait $! 2>/dev/null
assertFile "send ten amounts to public address and output to console" test_files/send/send-ten_amounts-to-hello_world-with_fee-10000.out
rm -f testURLResponse*

# send all locally to hello_world public address
echo '{ "expectedURL":"https://blockchain.info/unspent?active=1M9jofAErijG4eiPUy19Qxot1KkPRRzyet", "testType":"response", "file":"test_files/blockchain.info/utxo_response-single_output.json" }' > testURLResponse1
runTest node $baseDir/src/index.js send all --to 13hCoaeW632HQHpzvMmiyNbVWk8Bfpvz14 -w test_files/wallet/alt-wallet-1 --test-blockchain-api
wait $! 2>/dev/null
assertFile "send all to public address and output to console" test_files/send/send-all-to-hello_world-with_fee-10000.out
rm -f testURLResponse*

fi;


if [[ $subtest -eq 0 ]] ; then displayOverallResult; fi


