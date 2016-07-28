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
quiet=0
user='<player1>'

# boilerplate
#==================
function test_cleanup(){
  debug=1 ; quiet=0 ; user='<player1>'; echo
}
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
  test_cleanup
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
  test_cleanup
}

function test_contains(){
  echo -n 'contains        '
  declare -a arry=('hal blah' 'hal blah blah' 'blah HAL' 'blah hAl blah')
  for currline in "${arry[@]}"; do
    ocpass $(contains 'blah')
  done

  declare -a arry=('goof' 'hal herp' 'HAL' 'herp derp')
  for currline in "${arry[@]}"; do
    ocfail $(contains 'blah')
  done
  test_cleanup
}

function test_say(){
  echo -n 'say             '
  scpass "$(say "hello there")" '/say [Hal] hello there'
  scpass "$(say "hello there $user")" '/say [Hal] hello there <player1>'
  scpass "$(say "")" '/say [Hal] '
  test_cleanup
}

function test_tell(){
  echo -n 'tell            '
  scpass "$(tell "hello there")" "/tell $user hello there"
  scpass "$(tell "hello $user there wow")" "/tell $user hello $user there wow"
  scpass "$(tell "")" "/tell $user "
  scpass "$(tell )" "/tell $user "
  quiet=1
  scpass "$(tell "hello there")" ""
  scpass "$(tell "hello $user there wow")" ""
  test_cleanup
}

function test_run(){
  echo -n 'run             '
  scpass "$(run "/hello there")" "/hello there"
  scpass "$(run "/hello $user there wow")" "/hello $user there wow"
  scpass "$(run "")" ""
  scpass "$(run   )" ""
  test_cleanup
}

function test_not_repeat(){
  echo -n 'not_repeat      '
  test_cleanup
}

function test_random(){
  echo -n 'random          '
  test_cleanup
}

function test_random_okay(){
  echo -n 'random_okay     '
  test_cleanup
}

function test_random_musing(){
  echo -n 'random_musing   '
  test_cleanup
}

function test_shut_down(){
  echo -n 'shut_down       '
  test_cleanup
}

function test_hcsr(){
  echo -n 'hcsr            '
  test_cleanup
}

function test_go_home(){
  echo -n 'go_home         '
  test_cleanup
}

function test_set_home(){
  echo -n 'set_home        '
  test_cleanup
}

function test_remember_phrase(){
  echo -n 'remember_phrase '
  test_cleanup
}

function test_recall_phrase(){
  echo -n 'recall_phrase   '
  test_cleanup
}

function test_forget_phrase(){
  echo -n 'forget_phrase   '
  test_cleanup
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
