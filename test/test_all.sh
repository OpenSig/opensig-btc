#!/bin/sh
#
# opensig bash test file
#
# Top level test script to run all opensig tests
#

source test_harness.sh


echo Basic Features...
. test_basic_functions.sh -s

echo INFO Functions...
. test_info.sh -s

echo CREATE Functions...
. test_create.sh -s

echo BALANCE Functions...
. test_balance.sh -s

echo VERIFY Functions...
. test_verify.sh -s

echo SIGN Functions...
. test_sign.sh -s

echo SEND Functions...
. test_send.sh -s


displayOverallResult

cleanup
