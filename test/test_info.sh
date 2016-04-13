#!/bin/sh
#
# opensig bash test file
# 
# Tests the info function and some wallet management 
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

# dump default wallet
runTest node $baseDir/src/index.js info wallet
assertRE "info wallet outputs the default wallet file contents as plain text" "^[A-Za-z0-9]{34}.[5KL][A-Za-z0-9]{51}.*"

# dump specified wallet
runTest node $baseDir/src/index.js -w test_files/wallet/alt-wallet-1 info wallet
assertFile "With the -w option, opensig uses the specified wallet file rather than the default" test_files/wallet/alt-wallet-1-output

# specify non-existent wallet
runTest node $baseDir/src/index.js -w non-existent-file info wallet
assertError "dumping a non-existent file raises an error" "no such file or directory non-existent-file"

# specify unreadable wallet
touch myWallet
chmod u-r myWallet
runTest node $baseDir/src/index.js -w myWallet info wallet
assertError "dumping an unreadable file raises an error" "permission denied myWallet"
rm -f myWallet

# get info from WIF
runTest node $baseDir/src/index.js info L2MTsGktvDV6QdbFg2k3Ugjv2WiTdNLPPFY5Pm6Z2ALRF4eL9iGo
assert "get full info from WIF that doesn't match wallet" "1AQxYUGz5sPwqtPpCbuBcS3PwKARKXQZdR	L2MTsGktvDV6QdbFg2k3Ugjv2WiTdNLPPFY5Pm6Z2ALRF4eL9iGo	undefined"

# get info from WIF that matches wallet
runTest node $baseDir/src/index.js info L3ZugXLgbaWpq1hgeRCWKBrAsNYK2Y7Pq64HciUP7K2nVJhGvr2u -w test_files/wallet/alt-wallet-1
assert "get full info from WIF in wallet" "15J4SyQ9yCGetJ8uUyUoqjULASspzJMgAa	L3ZugXLgbaWpq1hgeRCWKBrAsNYK2Y7Pq64HciUP7K2nVJhGvr2u	Work"

# get public address from WIF
runTest node $baseDir/src/index.js info L2MTsGktvDV6QdbFg2k3Ugjv2WiTdNLPPFY5Pm6Z2ALRF4eL9iGo -a
assert "get public address from WIF" "1AQxYUGz5sPwqtPpCbuBcS3PwKARKXQZdR"

# get info from label
runTest node $baseDir/src/index.js info Work -w test_files/wallet/alt-wallet-1
assert "get full info from label in wallet" "15J4SyQ9yCGetJ8uUyUoqjULASspzJMgAa	L3ZugXLgbaWpq1hgeRCWKBrAsNYK2Y7Pq64HciUP7K2nVJhGvr2u	Work"

# get default public address from label
runTest node $baseDir/src/index.js info Work -w test_files/wallet/alt-wallet-1 -a
assert "get default info from label in wallet" "15J4SyQ9yCGetJ8uUyUoqjULASspzJMgAa"

# get default info from label (case insensitive)
runTest node $baseDir/src/index.js info peRsOnAl -w test_files/wallet/alt-wallet-1
assert "get default info from case insensitive label in wallet" "1M9jofAErijG4eiPUy19Qxot1KkPRRzyet	L33c5Gv8Ggt99PFDPieZ5fk56u1dZVChjGsHbrRAz9yagytNs32a	Personal"

# get info with non-existent label
runTest node $baseDir/src/index.js info wibble -w test_files/wallet/alt-wallet-1
assertError "error raised if try to get info from label that does not exist in the wallet" "argument is not a valid wallet label, private key, readable file or wif"

# get info no argument
runTest node $baseDir/src/index.js info -w test_files/wallet/alt-wallet-1
assert "get default address full info with no argument" "1M9jofAErijG4eiPUy19Qxot1KkPRRzyet	L33c5Gv8Ggt99PFDPieZ5fk56u1dZVChjGsHbrRAz9yagytNs32a	Personal"

# get info default-key
runTest node $baseDir/src/index.js info default-key -w test_files/wallet/alt-wallet-1
assert "get default-key address full info" "1M9jofAErijG4eiPUy19Qxot1KkPRRzyet	L33c5Gv8Ggt99PFDPieZ5fk56u1dZVChjGsHbrRAz9yagytNs32a	Personal"

# get public address no argument
runTest node $baseDir/src/index.js info -w test_files/wallet/alt-wallet-1 -a
assert "get default public address with no argument" "1M9jofAErijG4eiPUy19Qxot1KkPRRzyet"

# get info for file
runTest node $baseDir/src/index.js info test_files/verify/bitcoin.pdf
assert "get info for bitcoin.pdf" "16mCZiajppD94NWzZPHhiD21XBXRvdMqg1	L3AZRRSYbR3HD2c4iwctFwvdwzJ6DgZEaMZPjc6qW11rBCYAmEfL	test_files/verify/bitcoin.pdf";

# get public key for file
runTest node $baseDir/src/index.js info -a test_files/verify/bitcoin.pdf
assert "get public key for bitcoin.pdf" "16mCZiajppD94NWzZPHhiD21XBXRvdMqg1"

# get uncompressed info for file
runTest node $baseDir/src/index.js info test_files/verify/bitcoin.pdf -f "<pubu>	<wifu>	<label>"
assert "get uncompressed info for bitcoin.pdf" "1KuL3LiJuSzK7PCcQwpL8fBZVEum521szW	5KAR7SUYB4dmTHgDAxRSfH4zmBGCc3crJ5CsTsYgY3GbhqFpVPn	test_files/verify/bitcoin.pdf";

# get uncompressed public key for file
runTest node $baseDir/src/index.js info test_files/verify/bitcoin.pdf -f "<pubu>"
assert "get uncompressed public key for bitcoin.pdf" "1KuL3LiJuSzK7PCcQwpL8fBZVEum521szW"

# --full
runTest node $baseDir/src/index.js info Work -w test_files/wallet/alt-wallet-1 --full
assertFile "--full displays full info" test_files/wallet/info-work-full

fi;


# import WIF to wallet
# empty wallet


if [[ $subtest -eq 0 ]] ; then displayOverallResult; fi


