#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux
#   author  : leaf@anardil.net
#   license : See LICENSE file

# hal.sh [log_file install_dir memory_dir output_file]
#
# log_file    : path to the minecraft server's latest.log
# install_dir : folder where hal is installed
# memory_dir  : folder where user memories and other data is kept
# output_file : file where debugging information is written

set -o pipefail

# globals
USER=''
DEBUG=0
QUIET=0
CLINE=''
MEM_DIR=''
OUT_FILE=''
RCOMMAND=1
NUM_PLAYERS=0
MAX_MEM_SIZE=1024
MAX_MEM_DIR_SIZE=$(($MAX_MEM_SIZE * 10))
INTENT_A=''
INTENT_B=''
INTENT_C=''

# locals
prevline=''
inst_dir=''
log_file=''
new_hash=''
old_hash=''
starttime=$(date +%s)
readonly MAX_MEM_SIZE MAX_MEM_DIR_SIZE starttime

# check for required programs
progs=('tmux' 'sha1sum' 'truncate' 'tr' 'sed' 'bc' 'cut' 'grep' 'du' 'wc' 'tail')
for req_prog in ${progs[@]}; do
  if [[ -z "$(which ${req_prog})" ]]; then
    echo "error: hal.sh requires ${req_prog} to run"
    exit
  fi
done

# command line arguments
if ! [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" ]]; then
  log_file="$1"
  inst_dir="$2"
  MEM_DIR="$3"
  OUT_FILE="$4"
  DEBUG=1
  eval inst_dir="${inst_dir}"
  readonly log_file inst_dir MEM_DIR OUT_FILE DEBUG

# no arguments, parse halrc
elif [[ -e ~/.halrc ]]; then
  log_file=$(grep "LOGFILE "    ~/.halrc | cut -f 2- -d ' ')
  inst_dir=$(grep "INSTALLDIR " ~/.halrc | cut -f 2- -d ' ')
  MEM_DIR=$( grep "MEMDIR "     ~/.halrc | cut -f 2- -d ' ')
  eval inst_dir="${inst_dir}"
  readonly log_file inst_dir MEM_DIR OUT_FILE DEBUG

# no arguments, no halrc
else
  echo "error: Cannot find ~/.halrc. Did you run make install?"
  exit
fi

# verify configuration
for configuration in "${inst_dir}" "${log_file}" "${MEM_DIR}"; do
  if [[ -z "${configuration}" ]]; then
    echo "error: Configuration file is incomplete!"
    echo "       Please check ~/.halrc and make sure it reflects your system"
    exit
  fi

  if ! [[ -e "${configuration}" ]]; then
    echo "error: Configuration directory or file ${configuration} not found!"
    echo "       Please check ~/.halrc and make sure it reflects your system"
    exit
  fi
done

# load hal modules
srcs=("utility.sh" "memories.sh" "chatting.sh" "teleport.sh" "intent.sh")
for file in ${srcs[@]}; do
  source "${inst_dir}modules/${file}" 2>/dev/null

  if (( $? )); then
    echo "error: Cannot find module ${file}. Did you run make install?"
    exit
  fi
done

# startup messages and set up
if ! (( $DEBUG )); then
  echo 'Hal starting up'
fi

trap shut_down INT
mkdir -p "${MEM_DIR}"
say "I'm alive!"

# main
while true; do
  new_hash="$(sha1sum $log_file)"

  # only run when log file changes
  if [[ "$new_hash" != "$old_hash" ]]; then

    # preparation
    RCOMMAND=0
    CLINE="$(tail -n 1 "${log_file}" )"
    LIFETIME=$(( $(date +%s) - starttime ))

    # parse user name
    USER="$(grep -oi '<[^ ]*>' <<< "${CLINE}" | grep -oi '[^<>]*')"

    if [[ -z ${USER} ]]; then
      if contains 'User Authenticator'; then
        USER=$(cut -f 8 -d ' ' <<< "${CLINE}" )
      else
        USER=$(cut -f 4 -d ' ' <<< "${CLINE}" )
      fi
    fi

    # check for quiet timeout
    if (( ${QUIET} > 300 )); then
      QUIET=0
    elif (( ${QUIET} > 0 )); then
      QUIET=$(( QUIET + 1 ))
    fi

    # do all intention checks
    check_intent

    # user initiated actions
    if [[ "${prevline}" != "${CLINE}" ]] && not_repeat; then

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

      # check actions
      check_chatting_actions
      check_memory_actions
      check_teleport_actions
      check_gamemode_actions
      check_weather_actions
      check_effect_actions

      # player joins or leaves
      if contains "joined the game";       then player_joined; fi
      if contains "${USER} left the game"; then player_left  ; fi

      # misc server triggered
      if contains "${USER} moved too quickly"; then
        say "Woah there ${USER}! Maybe slow down a little?!"
        ran_command
      fi

      # not sure what to do
      if ! (( $RCOMMAND )); then
        hcsr 'hal?' "$USER?"

        if contains "hal"; then
          say "$(random 'Well...' 'Uhh...' 'Hmm...' 'Ehh...')"
        fi
      fi

    fi # user initiated actions

    prevline="${CLINE}"

  # hashes are the same, sleep
  else
    sleep 0.1
  fi

  old_hash="$new_hash"
done
