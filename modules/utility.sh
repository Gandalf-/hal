#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux
#   author  : leaf@anardil.net
#   license : See LICENSE file

# utility.sh

# AGGLOMERATIVE FUNCTIONS
show_help(){
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
  ran_command
}

player_joined(){
  : ' string -> int
  greet player, make comment on number of active players,
  and check for messages
  '
  sleep 0.1
  say "Hey there ${USER}! Try saying \"Hal help\""
  NUM_PLAYERS=$(( ${NUM_PLAYERS} + 1 ))
  ran_command

  if (( ${NUM_PLAYERS} == 1 )); then
    say "You're the first one here!"

  elif (( ${NUM_PLAYERS} == 2 )); then
    say "Two makes a party!"

  elif (( ${NUM_PLAYERS} > 2 )); then
    say "Things sure are busy today!"
  fi

  # check for messages
  local mfile="$MEM_DIR""${USER,,}".mail
  if [[ -e "$mfile" ]]; then
    if (( $(wc -l "$mfile" | cut -f 1 -d ' ') > 1 )); then
      say "Looks like you have some messages!"
    else
      say "Looks like you have a message!"
    fi

    while read -r line || [[ -n "$line" ]]; do
      say "$line"
    done < "$mfile"

    rm -f "$mfile"
  fi
}

player_left(){
  : ' none -> none
  Say goodbye, comment on player count
  '
  say "Goodbye ${USER}! See you again soon I hope!"
  NUM_PLAYERS=$(( ${NUM_PLAYERS} - 1 ))

  if (( ${NUM_PLAYERS} < 0 )); then
    say "I seem to have gotten confused..."
    NUM_PLAYERS=0

  elif (( ${NUM_PLAYERS} == 0 )); then
    say "All alone..."
    QUIET=0

  elif (( ${NUM_PLAYERS} == 1 )); then
    say "I guess it's just you and me now!"
  fi

  ran_command
}

check_gamemode_actions(){
  : ' none -> none
  gamemode modifing actions
  '
  hcsr 'put me in survival mode' \
    "$(random_okay 'Remember to eat!')" \
    "/gamemode surival ${USER}"

  hcsr 'put me in creative mode' \
    "$(random_okay)" \
    "/gamemode creative ${USER}"

  hcsr 'put me in spectator mode' \
    "$(random_okay)" \
    "/gamemode spectator ${USER}"
}

check_weather_actions(){
  : ' none -> none
  weather modifing actions
  '
  hcsr 'make it clear' \
    "$(random_okay 'Rain clouds begone!')" \
    "/weather clear 600"

  hcsr 'make it sunny' \
    "$(random_okay 'Rain clouds begone!')" \
    "/weather clear 600"

  hcsr 'make it rainy' \
    "$(random_okay 'Rain clouds inbound!')" \
    "/weather rain 600"

  hcsr 'make it day' \
    "$(random_okay 'Sunshine on the way!')" \
    "/time set day"

  hcsr 'make it night' \
    "$(random_okay 'Be careful!')" \
    "/time set night"
}

check_effect_actions(){
  : ' none -> none
  player effect modifing actions
  '
  hcsr 'make me healthy' \
    "$(random_okay 'This should help you feel better')" \
    "/effect ${USER} minecraft:instant_health 1 10"

  hcsr 'make me invisible' \
    "$(random_okay 'Not even I know where you are now!')" \
    "/effect ${USER} minecraft:invisibility 60 5"

  hcsr 'make me fast' \
    "$(random_okay 'Gotta go fast!')" \
    "/effect ${USER} minecraft:speed 60 5"
}

# UTILITY FUNCTIONS
hc(){
  : ' string -> int
  check if the current line contains the required text and the "hal" keyword
  '
  grep -qi "${1}.*Hal\|Hal.*${1}" <<< ${CLINE}
}

contains(){
  : ' string -> int
  check if the current line contains the required text
  '
  grep -qi "${1}" <<< "${CLINE}"
}

debug_output(){
  : ' string -> none
  sends output to correct location
  '
  if [[ -e "${OUT_FILE}" ]]; then
    echo "${@}" >> "${OUT_FILE}"
  else
    echo "${@}"
  fi
}

say(){
  : ' string -> none
  say a phrase in the server
  '
  if ! (( $QUIET )); then
    if ! (( $DEBUG )); then
      tmux send-keys -t minecraft "/say [Hal] ${1}" Enter
    else
      debug_output "/say [Hal] ${1}"
    fi
  fi
}

tell(){
  : ' string -> none
  say a phrase in the server
  '
  if ! (( $QUIET )); then
    if ! (( $DEBUG )); then
      tmux send-keys -t minecraft "/tell ${USER} ${1}" Enter
    else
      debug_output "/tell ${USER} ${1}"
    fi
  fi
}

run(){
  : ' string -> none
  run a command in the server
  '
  if ! [[ -z "${1}" ]]; then
    if ! (( $DEBUG )); then
      tmux send-keys -t minecraft "$@" Enter
    else
      debug_output "$@"
    fi
  fi
}

not_repeat(){
  : ' none -> int
  checks if the current line contains something from Hal
  makes sure we dont trigger commands off of ourself
  '
  ! grep -qi '\[Hal\]' <<< "${CLINE}"
}

random(){
  : ' any, ... -> any
  returns a randomly chosen element out of the arguments
  '
  if [[ -z "${1}" ]]; then
    echo ''
  else
    local array=("$@")
    echo "${array[$RANDOM % ${#array[@]} ]}"
  fi
}

shut_down(){
  : ' none -> none
  interrupt handler
  '
  debug_output ""
  debug_output 'Hal shutting down'
  say 'I died!'
  if ! (( $DEBUG )); then
    exit
  fi
}

hcsr(){
  : ' string, string, string -> none
  wrapper around check ${1}, say ${2}, run ${3} logic
  '
  if hc "${1}"; then
    say "${2}"
    run "${3}"
    ran_command
  fi
}

ran_command() {
  : ' none -> none
  wrapper to set RCOMMAND
  '
  RCOMMAND=1
}
