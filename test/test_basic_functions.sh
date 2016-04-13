#!/bin/sh
#
# test_misc_functions.sh
#
# $Rev: 203 $
# $Date: 2015-12-03 18:27:10 +0000 (Thu, 03 Dec 2015) $
# $Author: davidpotter-linnaeus $
#
# Tests the minor utility functions 
#
# Usage: 
#   . test_misc_functions.sh
#
# -w  run in-development (working) tests only
# -s  run as a subtest.  Don't create own instance of test harness.
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

# -h option
runTest node $baseDir/src/index.js -h
assertFile "With -h option check that the help text is returned" test_files/help.txt

# --help option
runTest node $baseDir/src/index.js -h
assertFile "With --help option check that the help text is returned" test_files/help.txt

# no arguments
runTest node $baseDir/src/index.js
assertFile "With no options check that the help text is returned" test_files/help.txt

fi;


if [[ $subtest -eq 0 ]] ; then displayOverallResult; fi


