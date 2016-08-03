#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux, inotify-tools
#   author  : leaf@anardil.net
#   license : See LICENSE file

# test_utility.sh

# boilerplate
#==================
function test_cleanup(){
  DEBUG=1 ; QUIET=0 ; USER='<player1>'
  MEM_DIR='/tmp/haltest/'; rm -rf "$MEM_DIR"; mkdir -p "$MEM_DIR"
  INTENT_A=''; INTENT_B=''; INTENT_C=''
  echo
}

function pass(){ echo -n " pass"; }

function fail(){ echo " fail"; }

function scpass(){
  if test "$1" == "$2"; then 
    pass
  else 
    fail; echo "Expected: $2"; echo "Received: $1"; exit 1
  fi
}
function scfail(){
  if test "$1" == "$2"; then 
    fail; echo "Expected: $1"; echo "Received: $2"; exit 1
  else 
    pass
  fi
}
function rcpass(){
  if test "$(echo "$1" | grep -F "$2")" != ""; then 
    pass
  else 
    fail; echo "Expected: $2"; echo "Received: $1"; exit 1
  fi
}
function rcfail(){
  if test "$(echo "$1" | grep "$2")" != ""; then 
    fail; echo "Expected: $2"; echo "Received: $1"; exit 1
  else pass; fi
}
function ocpass(){
  if [[ $? -eq 0 ]]; then 
    pass
  else 
    fail; echo "Return value was non-zero"; exit 1
  fi
}
function ocfail(){
  if [[ $? -eq 0 ]]; then 
    fail; echo "Return value was zero"; exit 1
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
