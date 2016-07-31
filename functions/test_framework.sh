#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux, inotify-tools
#   author  : leaf@anardil.net
#   license : See LICENSE file

# test_utility.sh

# boilerplate
#==================
function test_cleanup(){
  debug=1 ; quiet=0 ; user='<player1>'; echo
}

function pass(){ echo -n " pass"; }

function fail(){ echo " fail"; }

function scpass(){
  if test "$1" == "$2"; then 
    pass
  else 
    fail; echo "Expected: $1"; echo "Received: $2"
  fi
}
function scfail(){
  if test "$1" == "$2"; then 
    fail; echo "Expected: $1"; echo "Received: $2"
  else 
    pass
  fi
}
function rcpass(){
  if test "$(echo "$1" | grep -F "$2")" != ""; then 
    pass
  else 
    fail; echo "Expected: $2"; echo "Received: $1"
  fi
}
function rcfail(){
  if test "$(echo "$1" | grep "$2")" != ""; then 
    fail; echo "Expected: $2"; echo "Received: $1"
  else pass; fi
}
function ocpass(){
  if [[ $? -eq 0 ]]; then 
    pass
  else 
    fail; echo "Return value was non-zero"
  fi
}
function ocfail(){
  if [[ $? -eq 0 ]]; then 
    fail; echo "Return value was zero"
  else 
    pass
  fi
}
function test_test(){
  echo -n 'test            '
  scpass 'a' 'a'
  rcpass 'apple blueberry watermelon' 'blue'
  true ; ocpass 
  scfail 'a' 'b'
  rcfail 'apple blueberry watermelon' 'green'
  false ; ocfail 
  test_cleanup
}
