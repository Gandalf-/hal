#!/bin/bash -p

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

# shellcheck source=modules/utility.sh
# shellcheck source=modules/memories.sh
# shellcheck source=modules/chatting.sh
# shellcheck source=modules/teleport.sh
# shellcheck source=modules/intent.sh

set -o pipefail
shopt -s nocasematch
umask u=rw,g=,o=

# globals
export USER=''
export DEBUG=0
export QUIET=0
export CLINE=''
export MEM_DIR=''
export OUT_FILE=''
export RCOMMAND=1
export LIFETIME=0
export NUM_PLAYERS=0
export MAX_MEM_SIZE=1024
export MAX_MEM_DIR_SIZE=$(( MAX_MEM_SIZE * 10 ))
export INTENT_A=''
export INTENT_B=''
export INTENT_C=''

# locals
prevline=''
inst_dir=''
log_file=''
new_hash=''
old_hash=''
starttime=$(date +%s)
readonly MAX_MEM_SIZE MAX_MEM_DIR_SIZE starttime

# check for required programs
progs=('tmux' 'sha1sum' 'truncate' 'tr' 'sed' 'bc' 'cut' 'grep' 'du' 'wc'
       'tail' 'curl')
for req_prog in "${progs[@]}"; do
  if [[ -z "$(which "${req_prog}")" ]]; then
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
for file in "${srcs[@]}"; do
  # shellcheck disable=SC1091
  source "${inst_dir}modules/${file}" 2>/dev/null ||
  {
    echo "error: Cannot find module ${file}. Did you run make install?"
    exit
  }
done

# startup messages and set up
(( DEBUG )) || echo 'Hal starting up'

trap shut_down INT
mkdir -p "${MEM_DIR}"
chmod u+x "${MEM_DIR}"
say "I'm alive!"

# main
while true; do
  new_hash="$(sha1sum "$log_file")"

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
    (( QUIET > 300 )) && QUIET=0
    (( QUIET >   0 )) && let QUIET++

    # do all intention checks
    check_intent

    # user initiated actions
    if [[ "${prevline}" != "${CLINE}" ]] && not_repeat; then

      (( DEBUG )) || echo "CLINE: $CLINE"

      # administrative
      hc 'help' && show_help

      if hc 'restart'; then
        say 'Okay, restarting!'
        if ! (( DEBUG )); then
          $(basename "$0") "$@" &
          exit
        fi
      fi

      # check actions
      if contains 'hal'; then
        check_chatting_actions
        check_memory_actions
        check_teleport_actions
        check_gamemode_actions
        check_weather_actions
        check_effect_actions
      fi

      # player joins or leaves
      contains 'joined the game'       && player_joined
      contains "${USER} left the game" && player_left

      # misc server triggered
      if contains "${USER} moved too quickly"; then
        say "Woah there ${USER}! Maybe slow down a little?!"
        ran_command
      fi

      # not sure what to do
      if ! (( RCOMMAND )) && contains "hal"; then
        say "$(random 'Well..?' 'Uhh..?' 'Hmm..?' 'Ehh..?' 'Oh..?')"
      fi

    fi # user initiated actions

    prevline="${CLINE}"

  # hashes are the same, sleep
  else
    sleep 0.075
  fi

  old_hash="$new_hash"
done
