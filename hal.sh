#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux, inotify-tools
#   author  : leaf@anardil.net
#   license : See LICENSE file

# hal.sh

set -o pipefail

USER=''
DEBUG=0
QUIET=0
CLINE=''
MEM_DIR=''
OUT_FILE=''
RCOMMAND=0

INTENT_A=''
INTENT_B=''
INTENT_C=''

prevline=''
num_players=0
starttime=$(date +%s)
inst_dir=''
log_file=''

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

for req_prog in "tmux" "inotifywait"; do
  if test "$(which ${req_prog})" == ''; then
    echo "error: hal.sh requires tmux and inotify-tools to run"
    exit
  fi
done

# load modules
eval inst_dir="${inst_dir}"
# shellcheck source=functions/utility.sh
# shellcheck source=functions/memories.sh
# shellcheck source=functions/chatting.sh
# shellcheck source=functions/teleport.sh
# shellcheck source=functions/intent.sh
for file in "utility.sh" "memories.sh" "chatting.sh" "teleport.sh" "intent.sh"; do
  source "${inst_dir}""functions/""${file}"
done

# startup messages
if ! test $DEBUG ; then
  echo 'Hal starting up'
fi
say "I'm alive!"
trap shut_down INT
mkdir -p "${MEM_DIR}"
sleep 1

# main
while true; do
inotifywait -m -q -e modify "${log_file}" | 
while read -r _; do

  # preparation
  RCOMMAND=1
  CLINE=$(tail -n 3 "${log_file}" | grep -v 'Keeping entity' | tail -n 1)
  USER=$(echo "${CLINE}" | grep -oih '<[^ ]*>' | grep -oih '[^<>]*')
  LIFETIME=$(( $(date +%s) - starttime ))

  if test "${USER}" == ''; then
    if contains 'User Authenticator'; then
      USER=$(echo "${CLINE}" | cut -f 8 -d ' ')
    else
      USER=$(echo "${CLINE}" | cut -f 4 -d ' ')
    fi
  fi

  # time based actions
  if [[ $(( $(date +%s) % 900)) -le 2 ]] && [[ ${num_players} -ne 0 ]]; then
    say "$(random_musing)"
    sleep 2
  fi

  if [[ ${QUIET} -ge 300 ]]; then
    QUIET=0
  elif [[ ${QUIET} -ne 0 ]]; then
    QUIET=$(( QUIET + 1 ))
  fi

  # intention checks
  check_intent

  # user initiated actions
  if test "${prevline}" != "${CLINE}" && not_repeat; then

    # administrative
    if hc 'help'; then show_help; fi

    if hc 'restart'; then
      say 'Okay, restarting!'
      if test ! $DEBUG; then
        bash "$( cd "$(dirname "$0")"; pwd -P )"/"$(basename "$0") $@" &
        exit
      fi
    fi

    if hc 'be quiet'; then
      say 'Oh... Are you sure?'
      set_intent 'yes' 'intent_be_quiet'
      RCOMMAND=0
    fi

    if hc 'you can talk'; then
      QUIET=0
      say "Hooray!"
      RCOMMAND=0
    fi

    if hc 'status update'; then
      say "Active players: ${num_players}"
      RCOMMAND=0
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
    if contains "UUID of player";      then player_joined; fi
    if contains "${USER} left the game"; then player_left  ; fi

    # misc server triggered
    if contains "${USER} moved too quickly"; then
      say "Woah there ${USER}! Maybe slow down a little?!"
      RCOMMAND=0
    fi

    # not sure what to do
    if ! test "${RCOMMAND}" == 0 && contains "hal"; then
      say "$(random 'Well...' 'Uhh...' 'Hmm...' 'Ehh...' '*Blank stare*')"
    fi

  fi
  prevline="${CLINE}"
done
sleep 1
done
