#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux, inotify-tools
#   author  : leaf@anardil.net
#   license : See LICENSE file

# utility.sh

function show_help(){
  : ' none -> none
  print in game usage information
  '
  say "I'm Hal, a teenie tiny AI that will try to help you!"
  say "Here are some of the things I understand:"
  say "- thanks, yes, no, whatever, tell a joke"
  say "- help, restart, be quiet, you can talk"
  say "- make it (day, night, clear, rainy)"
  say "- make me (healthy, invisible, fast)"
  say "- tell <player> <message>"
  say "- take me to (the telehub, <player>)"
  say "- take me home, set home as <x> <y> <z>"
  say "- (remember, recall, forget) <phrase>"
  say "- put me in (creative, survival, spectator) mode"
  RCOMMAND=0
}

function hc(){
  : ' string -> int
  check if the current line contains the required text and the "hal" keyword
  '
  if test "$(echo "$CLINE" | grep -ioh "$1")" == ""; then
    return 1
  else
    if test "$(echo "$CLINE" | grep -ioh "Hal")" == ""; then
      return 1
    else
      return 0
    fi
  fi
}

function contains(){
  : ' string -> int
  check if the current line contains the required text
  '
  if test "$(echo "$CLINE" | grep -ioh "$1")" == ""; then
    return 1
  else
    return 0
  fi
}

function say(){
  : ' string -> none
  say a phrase in the server
  '
  if test "$QUIET" == "0" ; then
    if test "$DEBUG" == "0"; then
      tmux send-keys -t minecraft "/say [Hal] $1" Enter
    else
      echo "/say [Hal] $1"
    fi
  fi
}

function tell(){
  : ' string -> none
  say a phrase in the server
  '
  if test "$QUIET" == "0" ; then
    if test "$DEBUG" == "0"; then
      tmux send-keys -t minecraft "/tell $USER $1" Enter
    else
      echo "/tell $USER $1"
    fi
  fi
}

function run(){
  : ' string -> none
  run a command in the server
  '
  if test "$1" != ""; then
    if test "$DEBUG" == "0"; then
      tmux send-keys -t minecraft "$@" Enter
    else
      echo "$@"
    fi
  fi
}

function not_repeat(){
  : ' none -> int
  checks if the current line contains something from Hal
  makes sure we dont trigger commands off of ourself
  '
  if test "$(echo "$CLINE" | grep -oih '\[Hal\]' )" == ''; then
    return 0
  else
    return 1
  fi
}

function random(){
  : ' any, ... -> any
  returns a randomly chosen element out of the arguments
  '
  if test "$1" == ""; then
    echo ''
  else
    local array=("$@")
    echo "${array[$RANDOM % ${#array[@]} ]}"
  fi
}

function shut_down(){
  : ' none -> none
  interrupt handler
  '
  echo
  echo 'Hal shutting down'
  say 'I died!'
  if test "$DEBUG" == "0"; then
    exit
  fi
}

function hcsr(){
  : ' string, string, string -> none
  wrapper around check $1, say $2, run $3 logic
  '
  if hc "$1"; then
    say "$2"
    run "$3"
    RCOMMAND=0
  fi
}

