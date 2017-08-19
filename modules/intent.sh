#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux
#   author  : leaf@anardil.net
#   license : See LICENSE file

# intent.sh

check_intent(){
  # none -> none
  #
  # checks if the current line satisfies each of the intents. If a match is
  # found, evaluate it and move the subsequent intents up the list

  local pattern function

  if [[ $INTENT_A ]]; then
    pattern=$( cut -f 1 -d '%' <<< "${INTENT_A}" )
    function=$(cut -f 2 -d '%' <<< "${INTENT_A}" )

    if [[ "$CLINE" =~ $pattern ]]; then
      INTENT_A="$INTENT_B"
      INTENT_B="$INTENT_C"
      INTENT_C=''
      eval "$function"

    elif [[ $INTENT_B ]]; then
      pattern=$( cut -f 1 -d '%' <<< "$INTENT_B" )
      function=$(cut -f 2 -d '%' <<< "$INTENT_B" )

      if [[ "$CLINE" =~ $pattern ]]; then
        INTENT_B="$INTENT_C"
        INTENT_C=''
        eval "$function"

      elif [[ $INTENT_C ]]; then
        pattern=$( cut -f 1 -d '%' <<< "$INTENT_C" )
        function=$(cut -f 2 -d '%' <<< "$INTENT_C" )

        if [[ "$CLINE" =~ $pattern ]]; then
          eval "$function"

        else
          INTENT_C=''
        fi
      fi
    fi
  fi
}

set_intent(){
  # string, function -> none
  #
  # assigns a function callback to be called when the pattern occurs in CLINE
  # only three callbacks are kept at a time in a stack

  pattern="$1"
  callback="${*:2}"

  if [[ -z "${INTENT_A}" ]]; then
    INTENT_A="${pattern}%${callback}"

  elif [[ -z "${INTENT_B}" ]]; then
    INTENT_B="${INTENT_A}"
    INTENT_A="${pattern}%${callback}"

  else
    INTENT_C="${INTENT_B}"
    INTENT_B="${INTENT_A}"
    INTENT_A="${pattern}%${callback}"
  fi
}

# intentions
#==================
intent_if_yes_do(){
  # function -> none
  #
  # evaluate a function given as an agrument if the current line contains yes,
  # sure, or okay

  local regex='yes|sure|okay'
  [[ "${CLINE}" =~ $regex ]] && eval "$@"
}

intent_be_quiet(){
  # none -> none
  #
  # call back function, suppress hal comments

  say "Oh... Okay. I'll still do as you say but stay quiet for a while"
  #shellcheck disable=SC2034
  QUIET=1
}

intent_tell_player(){
 # string -> none
 #
 # call back function, stores a message for a player

 local sender target message

 say "I'll tell them when they show up again!"
 sender="$( cut -f 1  -d ' ' <<< "$@" )"
 target="$( cut -f 2  -d ' ' <<< "$@" )"
 message="$(cut -f 3- -d ' ' <<< "$@" )"
 echo "${sender}: ${message}" >> "${MEM_DIR}""${target,,}".mail
}

