#!/bin/bash

source functions.sh

# boilerplate
#==================
function pass(){ echo "$1: pass"; }
function fail(){ echo "$1: fail"; }
function scpass(){
  if test "$2" == "$3"; then pass $1; else fail $1; fi
}
function scfail(){
  if test "$2" == "$3"; then fail $1; else pass $1; fi
}
function rcpass(){
  if test "$(echo "$2" | grep "$3")" != ""; then pass $1;
  else fail $1; fi
}
function rcfail(){
  if test "$(echo "$2" | grep "$3")" != ""; then fail $1;
  else pass $1; fi
}
function ocpass(){
  if [[ $? -eq 0 ]]; then pass $1; else fail $1; fi
}
function ocfail(){
  if [[ $? -eq 0 ]]; then fail $1; else pass $1; fi
}
function test_test(){
  scpass 'test' 'a' 'a'
  rcpass 'test' 'apple blueberry watermelon' 'blue'
  ocpass 'test' 0
  scfail 'test' 'a' 'b'
  rcfail 'test' 'apple blueberry watermelon' 'green'
  ocfail 'test' 1
  echo
}

# tests
#==================
function test_tell_joke() {
  pass 'tell_joke'
  echo
}

function test_hc(){
  declare -a arry=('hal blah' 'hal blah blah' 'blah HAL' 'blah hAl blah')
  for currline in "${arry[@]}"; do
    ocpass 'hc' $(hc 'blah')
  done

  declare -a arry=('blah' 'hal herp' 'HAL' 'herp')
  for currline in "${arry[@]}"; do
    ocfail 'hc' $(hc 'blah')
  done
  echo
}

# run
#==================
test_test
test_tell_joke
test_hc
