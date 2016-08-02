#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux, inotify-tools
#   author  : leaf@anardil.net
#   license : See LICENSE file

# intent.sh

function check_intent(){
  : ' none -> none
  '
  local intent_file="$MEM_DIR"intent.list
  tac "$intent_file" | while read -r line; do
    pattern=$(echo "$line" | cut -f 1 -d '%')
    function=$(echo "$line" | cut -f 2 -d '%')

    if test "$(echo "$CLINE" | grep -i "$pattern")" != ""; then
      eval "$function"
    fi
  done
}

function set_intent(){
  : ' string, function -> none
  '
  local intent_file="$MEM_DIR"intent.list
  echo "$1%$2" >> "$intent_file"
}

function clear_intent(){
  : ' string -> none
  '

}

# intentions
#==================
function intent_simple_response(){
  : '
  '
  echo 'hello'
}
