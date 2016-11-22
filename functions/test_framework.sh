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
  : ' string, string -> string
  direct string comparision, pass if equal
  '
  if test "$1" == "$2"; then 
    pass
  else 
    fail; echo "Expected: $2"; echo "Received: $1"; exit 1
  fi
}

function scfail(){
  : ' string, string -> string
  direct string comparision, pass if different
  '
  if test "$1" == "$2"; then 
    fail; echo "Expected: $1"; echo "Received: $2"; exit 1
  else 
    pass
  fi
}

function rcpass(){
  : ' string, string -> string
  loose string comparison which ignores newlines, pass if equal
  '
  if test "$(echo "$1" | grep -F "$2")" != ""; then 
    pass
  else 
    fail; echo "Expected: $2"; echo "Received: $1"; exit 1
  fi
}

function rcfail(){
  : ' string, string -> string
  loose string comparison which ignores newlines, pass if different
  '
  if test "$(echo "$1" | grep "$2")" != ""; then 
    fail; echo "Expected: $2"; echo "Received: $1"; exit 1
  else pass; fi
}

function ocpass(){
  #: ' none -> string
  #return code comparison, pass if command succeded
  #'
  if [[ $? -eq 0 ]]; then 
    pass
  else 
    fail; echo "Return value was non-zero"; exit 1
  fi
}

function ocfail(){
  #': ' none -> string
  #return code comparison, pass if command failed
  #'
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
