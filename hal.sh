#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux, inotify-tools
#   author  : leaf@anardil.net
#   license : See LICENSE file

# hal.sh [log_file install_dir memory_dir output_file]
#
# log_file    : path to the minecraft server's latest.log
# install_dir : folder where hal is installed
# memory_dir  : folder where user memories and other data is kept
# output_file : file where debugging information is written

set -o pipefail

USER=''
DEBUG=0
QUIET=0
CLINE=''
MEM_DIR=''
MAX_MEM_SIZE=1024
MAX_MEM_DIR_SIZE=$(($MAX_MEM_SIZE * 10))
OUT_FILE=''
RCOMMAND=0

INTENT_A=''
INTENT_B=''
INTENT_C=''

prevline=''
inst_dir=''
log_file=''
new_hash=''
old_hash=''
starttime=$(date +%s)
num_players=0

# verify validity of arguments and/or configuration file
if test "$1" != '' && test "$2" != '' && 
  test "$3" != '' && test "$4" != ''; then
  log_file="$1"; inst_dir="$2"; MEM_DIR="$3"; OUT_FILE="$4"; DEBUG=1

elif [[ -e ~/.halrc ]]; then
  log_file=$(grep "LOGFILE "    ~/.halrc | cut -f 2- -d ' ')
  inst_dir=$(grep "INSTALLDIR " ~/.halrc | cut -f 2- -d ' ')
  MEM_DIR=$( grep "MEMDIR "     ~/.halrc | cut -f 2- -d ' ')

  for conf_file in "${inst_dir}" "${log_file}" "${MEM_DIR}"; do
    if test "${conf_file}" == ''; then
      echo "error: Configuration file is incomplete" 
      exit
    fi
  done

else
  echo "error: Cannot find ~/.halrc"
  exit
fi

# check for required programs
for req_prog in "tmux" "inotifywait"; do
  if test "$(which ${req_prog})" == ''; then
    echo "error: hal.sh requires tmux and inotify-tools to run"
    exit
  fi
done

# load hal modules
eval inst_dir="${inst_dir}"
# shellcheck source=functions/utility.sh
# shellcheck source=functions/memories.sh
# shellcheck source=functions/chatting.sh
# shellcheck source=functions/teleport.sh
# shellcheck source=functions/intent.sh
srcs=("utility.sh" "memories.sh" "chatting.sh" "teleport.sh" "intent.sh")
for file in ${srcs[@]}; do
  source "${inst_dir}""functions/""${file}"
done

# startup messages and preparation
if ! (( $DEBUG )); then
  echo 'Hal starting up'
fi

trap shut_down INT
mkdir -p "${MEM_DIR}"
sleep 0.5
say "I'm alive!"

# main
while true; do
  new_hash="$(sha1sum $log_file)"

  # only run when log file changes
  if test "$new_hash" != "$old_hash"; then

    # preparation
    RCOMMAND=1
    CLINE="$(tail -n 1 "${log_file}" )"
    USER="$(grep -oi '<[^ ]*>' <<< "${CLINE}" | grep -oi '[^<>]*')"
    LIFETIME=$(( $(date +%s) - starttime ))

    # interpret user log in
    if [[ -z ${USER} ]]; then
      if contains 'User Authenticator'; then
        USER=$(cut -f 8 -d ' ' <<< "${CLINE}" )
      else
        USER=$(cut -f 4 -d ' ' <<< "${CLINE}" )
      fi
    fi

    # check for quiet timeout
    if [[ ${QUIET} -ge 300 ]]; then
      QUIET=0
    elif [[ ${QUIET} -ne 0 ]]; then
      QUIET=$(( QUIET + 1 ))
    fi

    # do all intention checks
    check_intent

    # user initiated actions
    if test "${prevline}" != "${CLINE}" && not_repeat; then

      if ! (( $DEBUG )); then
        echo "CLINE: $CLINE"
      fi

      # administrative
      if hc 'help'; then show_help; fi

      if hc 'restart'; then
        say 'Okay, restarting!'
        if ! (( $DEBUG )); then
          bash "$( cd "$(dirname "$0")"; pwd -P )"/"$(basename "$0") $@" &
          exit
        fi
      fi

      # chatting
      check_chatting_actions

      # memory
      check_memory_actions

      # teleportation
      if hc 'take me home'; then go_home   ; fi
      if hc 'set home as '; then set_home  ; fi
      if hc 'take me to ' ; then go_to_dest; fi

      # gamemode
      check_gamemode_actions

      # weather
      check_weather_actions

      # effects
      check_effect_actions

      # teleportation
      # player joins or leaves
      if contains "joined the game";       then player_joined; fi
      if contains "${USER} left the game"; then player_left  ; fi

      # misc server triggered
      if contains "${USER} moved too quickly"; then
        say "Woah there ${USER}! Maybe slow down a little?!"
        RCOMMAND=0
      fi

      # not sure what to do
      if (( $RCOMMAND )); then
        hcsr 'hal?' "$USER?"

        if contains "hal"; then
          say "$(random 'Well...' 'Uhh...' 'Hmm...' 'Ehh...')"
        fi
      fi

    fi
    prevline="${CLINE}"
  else
    old_hash="$new_hash"
    sleep 0.1
  fi
done
