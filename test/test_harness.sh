#!/bin/sh
#
# test_harness.sh
#
# $Rev: 203 $
# $Date: 2015-12-03 18:27:10 +0000 (Thu, 03 Dec 2015) $
# $Author: davidpotter-linnaeus $
#
# Provides a set of operations to aid testing of transpose_site_data.pl.
#
# Usage example: 
#   runTest ""
#   assertError "ensure that an error is generated for an empty file" \
#               "transform of test.csv failed: file is empty"
#

testsRun=0;
testsPassed=0;
testsFailed=0;
testFailed=0;


function startTest(){
  closeRunningTest
  testsRun=$((testsRun+1));
}

function runTest(){
  startTest
  "$@" > stdout.log 2> stderr.log;
  test_result=$?;
}

function closeRunningTest(){
  if [ $testsRun -ne 0 ]
  then
    if [ $testFailed -ne 0 ]
    then
      testsFailed=$((testsFailed+1));
    else
      testsPassed=$((testsPassed+1));
    fi
    testFailed=0;
  fi
}

function assert(){
  if [ $test_result -eq 0 ]; then localAssert "$1" "$2" stdout.log;
  else
    test_output=$(<stderr.log);
    echo "FAIL: " $1;
    echo "  unexpected error";
    echo "  message: $test_output";
    testFailed=1;
  fi
}

function assertRE(){
  if [ $test_result -eq 0 ]; then localAssertRE "$1" "$2" stdout.log;
  else
    test_output=$(<stderr.log);
    echo "FAIL: " $1;
    echo "  unexpected error";
    echo "  message: $test_output";
    testFailed=1;
  fi
}

function assertErrorRE(){
  if [ $test_result -eq 0 ]; then localAssertRE "$1" "$2" stdout.log;
  else
    test_output=$(<stderr.log);
    echo "FAIL: " $1;
    echo "  unexpected error";
    echo "  message: $test_output";
    testFailed=1;
  fi
}

function assertNoError(){
  if [ $test_result -eq 0 ]; then echo "Pass:" $1;
  else
    test_output=$(<stderr.log);
    echo "FAIL: " $1;
    echo "  unexpected error";
    echo "  message: $test_output";
    testFailed=1;
  fi
}

function assertError(){
  if [ $test_result -ne 0 ]; then localAssert "$1" "$2" stderr.log;
  else
    test_output=$(<stdout.log);
    echo "FAIL: " $1;
    echo "  error was expected";
    echo "  stdout: $test_output";
    testFailed=1;
  fi
}

function localAssert(){
  test_output=$(<$3);
  if [ "$test_output" == "$2" ]
  then
    echo "Pass:" $1;
    test_result=0; # reset test result to allow additional assertions to be made.
  else
    echo "FAIL:" $1;
    echo "  expecting: \"$2\"";
    echo "  actual   : \"$test_output\"";
    testFailed=1;
  fi;
}

function localAssertRE(){
  test_output=$(<$3);
  if [[ "$test_output" =~ $2 ]]
  then
    echo "Pass:" $1;
    test_result=0; # reset test result to allow additional assertions to be made.
  else
    echo "FAIL:" $1;
    echo "  expecting regex: \"$2\"";
    echo "  actual         : \"$test_output\"";
    testFailed=1;
  fi;
}

function assertFile(){
  if [ $test_result -eq 0 ]; then localAssertFile "$1" "$2" stdout.log;
  else
    test_output=$(<stderr.log);
    echo "FAIL: " $1;
    echo "  unexpected error";
    echo "  message: $test_output";
    testFailed=1;
  fi
}

function assertErrorFile(){
  if [ $test_result -ne 0 ]; then localAssertFile "$1" "$2" stderr.log;
  else
    test_output=$(<stdout.log);
    echo "FAIL: " $1;
    echo "  error was expected";
    echo "  stdout: $test_output";
    testFailed=1;
  fi
}

function localAssertFile(){
  diff $2 $3 > diff.log 2>&1;
  if [ $? -eq 0 ]
  then
    echo "Pass:" $1;
  else
    echo "FAIL:" $1;
    cat diff.log;
    testFailed=1;
  fi;
}

function displayOverallResult(){
  closeRunningTest
  echo "----------------------";
  echo "tests run:   " $testsRun;
  echo "tests passed:" $testsPassed;
  echo "tests failed:" $testsFailed;
  echo "----------------------";
  if [[ $testsFailed -eq 0 && $testsRun -eq $testsPassed ]]; 
  then 
    echo "Overall test PASSED";
    return $testsPassed; 
  else 
    echo "Overall test FAILED";
    return -$testsFailed;
  fi;
  echo "----------------------";
}

function cleanup(){
	rm -f stdout.log stderr.log diff.log 2>/dev/null
}