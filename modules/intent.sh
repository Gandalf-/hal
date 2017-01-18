#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux
#   author  : leaf@anardil.net
#   license : See LICENSE file

# intent.sh

check_intent(){
  : ' none -> none
  checks if the current line satisfies each of the intents. If a match is
  found, evaluate it and move the subsequent intents up the list
  '
  if ! [[ -z "${INTENT_A}" ]]; then
    local pattern=$( cut -f 1 -d '%' <<< "${INTENT_A}" )
    local function=$(cut -f 2 -d '%' <<< "${INTENT_A}" )

    if grep -qi "$pattern" <<< "${CLINE}"; then
      INTENT_A="${INTENT_B}"
      INTENT_B="${INTENT_C}"
      INTENT_C=''
      eval "${function}"

    elif ! [[ -z "${INTENT_B}" ]]; then
      local pattern=$( cut -f 1 -d '%' <<< "${INTENT_B}" )
      local function=$(cut -f 2 -d '%' <<< "${INTENT_B}" )

      if grep -qi "$pattern" <<< "${CLINE}"; then
        INTENT_B="${INTENT_C}"
        INTENT_C=''
        eval "$function"

      elif ! [[ -z "${INTENT_C}" ]]; then
        local pattern=$( cut -f 1 -d '%' <<< "${INTENT_C}" )
        local function=$(cut -f 2 -d '%' <<< "${INTENT_C}" )

        if grep -qi "$pattern" <<< "${CLINE}"; then
          eval "$function"
        else
          INTENT_C=''
        fi
      fi
    fi
  fi
}

set_intent(){
  : ' string, function -> none
  '
  if [[ -z "${INTENT_A}" ]]; then
    INTENT_A="${1}%${@:2}"

  elif [[ -z "${INTENT_B}" ]]; then
    INTENT_B="${INTENT_A}"
    INTENT_A="${1}%${@:2}"

  else
    INTENT_C="${INTENT_B}"
    INTENT_B="${INTENT_A}"
    INTENT_A="${1}%${@:2}"
  fi
}

# intentions
#==================
intent_if_yes_do(){
  : ' function -> none
  evaluate a function given as an agrument if the current line contains yes,
  sure, or okay
  '
  local regex='yes\|sure\|okay'
  if grep -qi "$regex" <<< "${CLINE}"; then
    eval "$@"
  fi
}

intent_be_quiet(){
  : ' none -> none
  call back function, suppress hal comments
  '
  say "Oh... Okay. I'll still do as you say but stay quiet for a while"
  QUIET=1
}

intent_tell_player(){
 : ' string -> string
 call back function, stores a message for a player
 '
 say "I'll tell them when they show up again!"
 local sender="$( cut -f 1  -d ' ' <<< "${@}" )"
 local target="$( cut -f 2  -d ' ' <<< "${@}" )"
 local message="$(cut -f 3- -d ' ' <<< "${@}" )"
 echo "${sender}: ${message}" >> "${MEM_DIR}""${target,,}".mail
}
