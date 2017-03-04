#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux
#   author  : leaf@anardil.net
#   license : See LICENSE file

# test_utility.sh

set -o pipefail
shopt -s nocasematch
umask u=rw,g=,o=

# boilerplate
#==================
test_cleanup(){
  export DEBUG=1
  export QUIET=0
  export USER='<player1>'
  export MEM_DIR='/tmp/haltest/'
  rm -rf "$MEM_DIR"
  mkdir -p "$MEM_DIR"
  chmod u+x "${MEM_DIR}"
  export INTENT_A=''
  export INTENT_B=''
  export INTENT_C=''
  echo
}

pass(){ echo -n " pass"; }

fail(){ echo " fail"; }

scpass(){
  : ' string, string -> string
  direct string comparision, pass if equal
  '
  if [[ "$1" == "$2" ]]; then
    pass

  else
    fail
    echo "Expected: $2"
    echo "Received: $1"
    exit 1
  fi
}

scfail(){
  : ' string, string -> string
  direct string comparision, pass if different
  '
  if [[ "$1" == "$2" ]]; then
    fail
    echo "Expected: $1"
    echo "Received: $2"
    exit 1

  else
    pass
  fi
}

rcpass(){
  : ' string, string -> string
  loose string comparison which ignores newlines, pass if equal
  '
  if grep -qF "$2" <<< "$1"; then
    pass

  else
    fail
    echo "Expected: $2"
    echo "Received: $1"
    exit 1
  fi
}

rcfail(){
  : ' string, string -> string
  loose string comparison which ignores newlines, pass if different
  '
  if grep -qF "$2" <<< "$1"; then
    fail
    echo "Expected: $2"
    echo "Received: $1"
    exit 1

  else
    pass
  fi
}

ocpass(){
  # : ' none -> string
  # return code comparison, pass if command succeded
  # '
  if (( $? )); then
    fail
    echo "Return value was non-zero"
    exit 1
  else
    pass
  fi
}

ocfail(){
  # : ' none -> string
  # return code comparison, pass if command failed
  # '
  if (( $? )); then
    pass
  else
    fail
    echo "Return value was zero"
    exit 1
  fi
}

test_test(){
  echo -n 'test            '
  scpass 'a' 'a'
  rcpass 'apple blueberry watermelon' 'blue'
  true ; ocpass
  scfail 'a' 'b'
  rcfail 'apple blueberry watermelon' 'green'
  false ; ocfail
  test_cleanup
}
