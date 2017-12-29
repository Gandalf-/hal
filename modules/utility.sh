#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux
#   author  : leaf@anardil.net
#   license : See LICENSE file

# utility.sh

# AGGLOMERATIVE FUNCTIONS
show_help(){
  # none -> none
  #
  # print in game usage information

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
  ran_command
}

player_joined(){
  # string -> int
  #
  # greet player, make comment on number of active players,
  # and check for messages

  local mfile

  sleep 0.1
  say "Hey there $USER! Try saying \"Hal help\""
  (( NUM_PLAYERS++ ))

  if (( NUM_PLAYERS == 1 )); then
    say "You're the first one here!"

  elif (( NUM_PLAYERS == 2 )); then
    say "Two makes a party!"

  elif (( NUM_PLAYERS > 2 )); then
    say "Things sure are busy today!"
  fi

  # check for messages
  mfile="$MEM_DIR""${USER,,}".mail

  if file_exists "$mfile"; then

    if (( $( wc -l "$mfile" | cut -f 1 -d ' ' ) > 1 )); then
      say "Looks like you have some messages!"

    else
      say "Looks like you have a message!"
    fi

    while read -r line || [[ "$line" ]]; do
      say "$line"
    done < "$mfile"

    rm -f "$mfile"
  fi

  ran_command
}

player_left(){
  # none -> none
  #
  # Say goodbye, comment on player count

  say "Goodbye ${USER}! See you again soon I hope!"
  (( NUM_PLAYERS-- ))

  if (( NUM_PLAYERS < 0 )); then
    say "I seem to have gotten confused..."
    NUM_PLAYERS=0

  elif (( NUM_PLAYERS == 0 )); then
    say "All alone..."
    QUIET=0

  elif (( NUM_PLAYERS == 1 )); then
    say "I guess it's just you and me now!"
  fi

  ran_command
}

# UTILITY FUNCTIONS
hc(){
  # string -> int
  #
  # check if the current line contains the required text and the "hal" keyword

  [[ "${CLINE}" =~ hal(.*)${1}|${1}(.*)hal ]]
}

file_exists() {

  [[ -e "$1" ]]
}

contains(){
  # string -> int
  #
  # check if the current line contains the required text

  [[ "$CLINE" =~ $1 ]]
}

debug_output(){
  # string -> none
  #
  # sends output to correct location

  if file_exists "$OUT_FILE"; then
    echo "$@" >> "${OUT_FILE}"

  else
    echo "$@"
  fi
}

say(){
  # string -> none
  #
  # say a phrase in the server

  (( QUIET )) || {
    if ! (( DEBUG )); then
      tmux send-keys -t minecraft "/say [Hal] ${1}" Enter

    else
      debug_output "/say [Hal] ${1}"
    fi
  }
}

tell(){
  # string -> none
  #
  # say a phrase in the server

  (( QUIET )) || {
    if ! (( DEBUG )); then
      tmux send-keys -t minecraft "/tell ${USER} ${1}" Enter

    else
      debug_output "/tell ${USER} ${1}"
    fi
  }
}

run(){
  # string -> none
  #
  # run a command in the server

  [[ $1 ]] && {
    if ! (( DEBUG )); then
      tmux send-keys -t minecraft "$@" Enter

    else
      debug_output "$@"
    fi
  }
}

not_repeat(){
  # none -> int
  #
  # checks if the current line contains something from Hal
  # makes sure we dont trigger commands off of ourself

  ! [[ "${CLINE}" =~ \[Hal\] ]]
}

random(){
  # any, ... -> any
  #
  # returns a randomly chosen element out of the arguments

  local array

  if [[ $1 ]]; then
    array=("$@")
    echo "${array[$RANDOM % ${#array[@]} ]}"
  fi
}

shut_down(){
  # none -> none
  #
  # interrupt handler

  debug_output ""
  debug_output 'Hal shutting down'
  say 'I died!'
  (( DEBUG )) || exit
}

hcsr(){
  # string, string, string -> none
  #
  # wrapper around check 1, say 2, run 3 logic

  if hc "${1}"; then
    say "${2}"
    run "${3}"
    ran_command
  fi
}

ran_command() {
  # none -> none
  #
  # wrapper to set RCOMMAND

  # shellcheck disable=SC2034
  RCOMMAND=1
}
