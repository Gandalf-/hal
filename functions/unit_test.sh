#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux, inotify-tools
#   author  : leaf@anardil.net
#   license : See LICENSE file

# unit_test.sh

source "./utility.sh"
source "./memories.sh"
source "./chatting.sh"
source "./teleport.sh"
debug=1

# boilerplate
#==================
function pass(){ echo -n " pass"; }
function fail(){ echo -n " fail"; }
function scpass(){
  if test "$1" == "$2"; then pass; else fail; fi
}
function scfail(){
  if test "$1" == "$2"; then fail; else pass; fi
}
function rcpass(){
  if test "$(echo "$1" | grep "$2")" != ""; then pass;
  else fail; fi
}
function rcfail(){
  if test "$(echo "$1" | grep "$2")" != ""; then fail;
  else pass; fi
}
function ocpass(){
  if [[ $? -eq 0 ]]; then pass; else fail; fi
}
function ocfail(){
  if [[ $? -eq 0 ]]; then fail; else pass; fi
}
function test_test(){
  echo -n 'test            '
  scpass 'a' 'a'
  rcpass 'apple blueberry watermelon' 'blue'
  true
  ocpass 
  scfail 'a' 'b'
  rcfail 'apple blueberry watermelon' 'green'
  false
  ocfail 
  echo
}

# tests
#==================
function test_tell_joke() {
  : ' none -> none
  make sure tell_joke returns a string
  '
  echo -n 'tell_joke       '
  scfail tell_joke ""
  echo
}

function test_hc(){
  : ' none -> none
  make sure hc only accepts inputs that match "hal" and $1
  '
  echo -n 'hc              '
  declare -a arry=('hal blah' 'hal blah blah' 'blah HAL' 'blah hAl blah')
  for currline in "${arry[@]}"; do
    ocpass $(hc 'blah')
  done

  declare -a arry=('blah' 'hal herp' 'HAL' 'herp')
  for currline in "${arry[@]}"; do
    ocfail $(hc 'blah')
  done
  echo
}

function test_contains(){
  echo -n 'contains        '
  echo
}

function test_say(){
  echo -n 'say             '
  echo
}

function test_tell(){
  echo -n 'tell            '
  echo
}

function test_run(){
  echo -n 'run             '
  echo
}

function test_not_repeat(){
  echo -n 'not_repeat      '
  echo
}

function test_random(){
  echo -n 'random          '
  echo
}

function test_random_okay(){
  echo -n 'random_okay     '
  echo
}

function test_random_musing(){
  echo -n 'random_musing   '
  echo
}

function test_shut_down(){
  echo -n 'shut_down       '
  echo
}

function test_hcsr(){
  echo -n 'hcsr            '
  echo
}

function test_go_home(){
  echo -n 'go_home         '
  echo
}

function test_set_home(){
  echo -n 'set_home        '
  echo
}

function test_remember_phrase(){
  echo -n 'remember_phrase '
  echo
}

function test_recall_phrase(){
  echo -n 'recall_phrase   '
  echo
}

function test_forget_phrase(){
  echo -n 'forget_phrase   '
  echo
}

# run
#==================
test_test
test_tell_joke
test_hc
test_contains
test_say
test_tell
test_run
test_not_repeat
test_random
test_random_okay
test_random_musing
test_shut_down
test_hcsr
test_go_home
test_set_home
test_remember_phrase
test_recall_phrase
test_forget_phrase
