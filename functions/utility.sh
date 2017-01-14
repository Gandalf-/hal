#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux, inotify-tools
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
  RCOMMAND=0
}

player_joined(){
  : ' string -> int
  greet player, make comment on number of active players,
  and check for messages
  '
  sleep 0.1
  say "Hey there ${USER}! Try saying \"Hal help\""
  local num_players=$(( ${num_players} + 1 ))
  RCOMMAND=0

  if [[ ${num_players} -eq 1 ]]; then
    say "You're the first one here!"

  elif [[ ${num_players} -eq 2 ]]; then
    say "Two makes a party!"

  elif [[ ${num_players} -ge 3 ]]; then
    say "Things sure are busy today!"
  fi

  # check for messages
  local mfile="$MEM_DIR""${USER,,}".mail
  if [[ -e "$mfile" ]]; then
    if [[ $(wc -l "$mfile" | cut -f 1 -d ' ') -ge 2 ]] ; then
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
  local num_players=$(( ${num_players} - 1 ))
  RCOMMAND=0

  if [[ ${num_players} -le 0 ]]; then
    say "I seem to have gotten confused..."
    num_players=0
  fi

  if [[ ${num_players} -eq 0 ]]; then
    say "All alone..."
    QUIET=0

  elif [[ ${num_players} -eq 1 ]]; then
    say "I guess it's just you and me now!"
  fi
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
  if test "$(grep -io "${1}.*Hal\|Hal.*${1}" <<< "${CLINE}" )" == ""; then
    return 1
  else
    return 0
  fi
}

contains(){
  : ' string -> int
  check if the current line contains the required text
  '
  if test "$(grep -io "${1}" <<< "${CLINE}" )" == ""; then
    return 1
  else
    return 0
  fi
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
  if test "${QUIET}" == "0" ; then
    if test "${DEBUG}" == "0"; then
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
  if test "${QUIET}" == "0" ; then
    if test "${DEBUG}" == "0"; then
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
  if test "${1}" != ""; then
    if test "${DEBUG}" == "0"; then
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
  if test "$(grep -oih '\[Hal\]' <<< "${CLINE}" )" == ''; then
    return 0
  else
    return 1
  fi
}

random(){
  : ' any, ... -> any
  returns a randomly chosen element out of the arguments
  '
  if test "${1}" == ""; then
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
  if test "${DEBUG}" == "0"; then
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
    RCOMMAND=0
  fi
}
