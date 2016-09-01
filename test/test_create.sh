#!/bin/sh
#
# opensig bash test file
# 
# Tests the creation of key pairs and some wallet management 
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

# create new key pair
runTest node $baseDir/src/index.js create
assertRE "A new private key, public key and WIF are created on demand" \
"label                   : undefined."\
"identity                : OPENSIG-[A-Za-z0-9]{27,34}-btc."\
"private key             : [0-9a-f]{1,64}."\
"wif compressed          : [5KL][A-Za-z0-9]{51}."\
"wif uncompressed        : [A-Za-z0-9]{51}."\
"public key compressed   : [A-Za-z0-9]{27,34}."\
"public key uncompressed : [A-Za-z0-9]{27,34}"

# create new WIF
runTest node $baseDir/src/index.js create -f "<wif>"
assertRE "A new WIF is created on demand" "^[5KL][A-Za-z0-9]{51}$"

# create -s with no label
runTest node $baseDir/src/index.js create -s
assertError "calling create -s with no label argument raises an error" $'\n'"  error: option \`-s --save <label>' argument missing"

# specify read-only wallet
touch myWallet
chmod u-w myWallet
runTest node $baseDir/src/index.js create -s "My Name" -w myWallet 
assertError "saving to a read-only wallet file raises an error" "permission denied myWallet"
rm -f myWallet

# append new WIF to wallet
echo "L1Kp6HuHVTS4piDsPnQ5mdNdVFtUscQY4S55m51LiUqZDsywg8Qt	a wif" > test_wallet
runTest node $baseDir/src/index.js -w test_wallet create -s "My Name"
assertNoError "WIF created successfully"
cat test_wallet >> stdout.log
assertRE "-s option appends new WIF to the wallet" "^L1Kp6HuHVTS4piDsPnQ5mdNdVFtUscQY4S55m51LiUqZDsywg8Qt	a wif.[5KL][A-Za-z0-9]{51}	My Name$"
rm -f test_wallet

# import without -s 
runTest node $baseDir/src/index.js create -k "L1cqLgySp5ez3CmKinSpW64iZwQKxSP1JXuCks8j2GZSzV4u2UEv"
assertError "calling create -k with no -s option raises an error" "Cannot import key without a label - use -s to specify"

# import with missing key
runTest node $baseDir/src/index.js create -s "My Name" -k
assertError "calling create -k with no -s option raises an error" $'\n'"  error: option \`-k --key <key>' argument missing"

# import WIF to wallet
echo "L1Kp6HuHVTS4piDsPnQ5mdNdVFtUscQY4S55m51LiUqZDsywg8Qt	a wif" > test_wallet
runTest node $baseDir/src/index.js -w test_wallet create -s "My Name" -k "L1cqLgySp5ez3CmKinSpW64iZwQKxSP1JXuCks8j2GZSzV4u2UEv"
assertNoError "WIF created successfully"
cat test_wallet >> stdout.log
assertRE "-s option appends new WIF to the wallet" "^L1Kp6HuHVTS4piDsPnQ5mdNdVFtUscQY4S55m51LiUqZDsywg8Qt	a wif.L1cqLgySp5ez3CmKinSpW64iZwQKxSP1JXuCks8j2GZSzV4u2UEv	My Name$"
rm -f test_wallet

# create key with missing wallet
runTest node $baseDir/src/index.js create -s "My Key" -w missingWallet
assertError "calling create with no wallet raises an error" "no such file or directory missingWallet"


# create new wallet
runTest node $baseDir/src/index.js create wallet -w new_wallet
assertNoError "new wallet is created without error"
ls -l new_wallet > stdout.log
assertRE "new wallet is created successfully with the correct mode" "^-rw-------.*new_wallet$"
runTest node $baseDir/src/index.js -w new_wallet create -s "My Name" -k "L1cqLgySp5ez3CmKinSpW64iZwQKxSP1JXuCks8j2GZSzV4u2UEv"
assertNoError "WIF in new wallet is created successfully"
cat new_wallet >> stdout.log
assert "WIF is written to new wallet" "L1cqLgySp5ez3CmKinSpW64iZwQKxSP1JXuCks8j2GZSzV4u2UEv	My Name"
rm -f new_wallet


# create new wallet in subdirectory
runTest node $baseDir/src/index.js create wallet -w new_wallet_dir/new_wallet_subdir/new_wallet
assertNoError "new wallet is created without error"
ls -ld new_wallet_dir > stdout.log
assertRE "new wallet dir is created successfully with the correct mode" "^drwx------.*new_wallet_dir$"
ls -ld new_wallet_dir/new_wallet_subdir > stdout.log
assertRE "new wallet subdir is created successfully with the correct mode" "^drwx------.*new_wallet_dir/new_wallet_subdir$"
ls -ld new_wallet_dir/new_wallet_subdir/new_wallet > stdout.log
assertRE "new wallet is created successfully with the correct mode" "^-rw-------.*new_wallet_dir/new_wallet_subdir/new_wallet$"
runTest node $baseDir/src/index.js -w new_wallet_dir/new_wallet_subdir/new_wallet create -s "My Name" -k "L1cqLgySp5ez3CmKinSpW64iZwQKxSP1JXuCks8j2GZSzV4u2UEv"
assertNoError "WIF in new wallet is created successfully"
cat new_wallet_dir/new_wallet_subdir/new_wallet >> stdout.log
assert "WIF is written to new wallet" "L1cqLgySp5ez3CmKinSpW64iZwQKxSP1JXuCks8j2GZSzV4u2UEv	My Name"
rm -rf new_wallet_dir


fi;


if [[ $subtest -eq 0 ]] ; then displayOverallResult; fi


