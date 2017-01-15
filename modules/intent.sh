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
  if test "$INTENT_A" != ''; then
    local pattern=$( cut -f 1 -d '%' <<< "${INTENT_A}" )
    local function=$(cut -f 2 -d '%' <<< "${INTENT_A}" )

    if test "$(grep -i "$pattern" <<< "${CLINE}" )" != ""; then
      INTENT_A="$INTENT_B"
      INTENT_B="$INTENT_C"
      INTENT_C=''
      eval "${function}"

    elif test "$INTENT_B" != ''; then
      local pattern=$( cut -f 1 -d '%' <<< "${INTENT_B}" )
      local function=$(cut -f 2 -d '%' <<< "${INTENT_B}" )

      if test "$(grep -i "$pattern" <<< "${CLINE}" )" != ""; then
        INTENT_B="$INTENT_C"
        INTENT_C=''
        eval "$function"

      elif test "$INTENT_C" != ''; then
        local pattern=$( cut -f 1 -d '%' <<< "${INTENT_C}" )
        local function=$(cut -f 2 -d '%' <<< "${INTENT_C}" )

        if test "$(grep -i "$pattern" <<< "${CLINE}" )" != ""; then
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
  if test "$INTENT_A" == ''; then
    INTENT_A="$1%${@:2}"

  elif test "$INTENT_B" == ''; then
    INTENT_B="$INTENT_A"
    INTENT_A="$1%${@:2}"

  else
    INTENT_C="$INTENT_B"
    INTENT_B="$INTENT_A"
    INTENT_A="$1%${@:2}"
  fi
}

# intentions
#==================
intent_if_yes_do(){
  : '
  '
  local regex='yes\|sure\|okay'
  if test "$(grep -io "$regex" <<< "${CLINE}" )" != ''; then
    eval "$@"
  fi
}

intent_be_quiet(){
  : ' none -> none
  '
  say "Oh... Okay. I'll still do as you say but stay quiet for a while"
  QUIET=1
}

intent_tell_player(){
 : ' string -> none
 stores a message for a player
 '
 say "I'll tell them when they show up again!"
 local sender="$( cut -f 1  -d ' ' <<< "${@}" )"
 local target="$( cut -f 2  -d ' ' <<< "${@}" )"
 local message="$(cut -f 3- -d ' ' <<< "${@}" )"
 echo "$sender: $message" >> "$MEM_DIR""${target,,}".mail
}
