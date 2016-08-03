#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux, inotify-tools
#   author  : leaf@anardil.net
#   license : See LICENSE file

# intent.sh

function check_intent(){
  : ' none -> none
  checks if the current line satisfies each of the intents. If a match is
  found, evaluate it and move the subsequent intents up the list
  '
  if test "$INTENT_A" != ''; then
    pattern=$(echo "$INTENT_A" | cut -f 1 -d '%')
    function=$(echo "$INTENT_A" | cut -f 2 -d '%')

    if test "$(echo "$CLINE" | grep -i "$pattern")" != ""; then
      INTENT_A="$INTENT_B"
      INTENT_B="$INTENT_C"
      INTENT_C=''
      eval "$function"

    elif test "$INTENT_B" != ''; then
      pattern=$(echo "$INTENT_B" | cut -f 1 -d '%')
      function=$(echo "$INTENT_B" | cut -f 2 -d '%')

      if test "$(echo "$CLINE" | grep -i "$pattern")" != ""; then
        INTENT_B="$INTENT_C"
        INTENT_C=''
        eval "$function"

      elif test "$INTENT_C" != ''; then
        pattern=$(echo "$INTENT_C" | cut -f 1 -d '%')
        function=$(echo "$INTENT_C" | cut -f 2 -d '%')

        if test "$(echo "$CLINE" | grep -i "$pattern")" != ""; then
          eval "$function"
        else
          INTENT_C=''
        fi
      fi
    fi
  fi
}

function set_intent(){
  : ' string, function -> none
  '
  if test "$INTENT_A" == ''; then
    INTENT_A="$1%$2"

  elif test "$INTENT_B" == ''; then
    INTENT_B="$INTENT_A"
    INTENT_A="$1%$2"

  else
    INTENT_C="$INTENT_B"
    INTENT_B="$INTENT_A"
    INTENT_A="$1%$2"
  fi
}

# intentions
#==================
function intent_if_yes_do(){
  : '
  '
  local regex='yes\|sure\|okay'
  if test "$(echo "$CLINE" | grep -ioh "$regex")" != ''; then
    eval "$@"
  fi
}

function intent_be_quiet(){
  : ' none -> none
  '
  say "Oh... Okay. I'll still do as you say but stay quiet for a while"
  QUIET=1
}
