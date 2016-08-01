#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux, inotify-tools
#   author  : leaf@anardil.net
#   license : See LICENSE file

# hal.sh

set -u
set -o pipefail

USER=''
DEBUG=0
QUIET=0
CLINE=''
MEM_DIR=''
RCOMMAND=0

prevline=''
num_players=0
starttime=$(date +%s)
ins_dir=''
log_file=''

if [[ -e ~/.halrc ]]; then
  log_file=$(grep "LOGFILE "    ~/.halrc | cut -f 2- -d ' ')
  ins_dir=$( grep "INSTALLDIR " ~/.halrc | cut -f 2- -d ' ')
  MEM_DIR=$( grep "MEMDIR "     ~/.halrc | cut -f 2- -d ' ')

  if test "$ins_dir" == ""|| test "$log_file" == ""|| test "$MEM_DIR" == ""; then
    echo "error: Configuration file is incomplete"; exit
  fi

else
  echo "error: Cannot find ~/.halrc"; exit
fi

if test "$(which tmux)" == '' || test "$(which inotifywait)" == ''; then
  echo "error: hal.sh requires tmux and inotify-tools to run"; exit
fi

eval ins_dir="$ins_dir"
# shellcheck source=functions/utility.sh
source "$ins_dir""functions/utility.sh"
# shellcheck source=functions/memories.sh
source "$ins_dir""functions/memories.sh"
# shellcheck source=functions/chatting.sh
source "$ins_dir""functions/chatting.sh"
# shellcheck source=functions/teleport.sh
source "$ins_dir""functions/teleport.sh"

echo 'Hal starting up'
say "I'm alive!"
trap shut_down INT
mkdir -p "$MEM_DIR"
sleep 1

# main
while true; do
while inotifywait -e modify "$log_file"; do

  # preparation
  RCOMMAND=1
  CLINE=$(tail -n 3 "$log_file" | grep -v 'Keeping entity' | tail -n 1)
  lifetime=$(( "$(date +%s)" - starttime ))

  USER=$(echo "$CLINE" | grep -oih '<[^ ]*>' | grep -oih '[^<>]*')
  if test "$USER" == ""; then
    if test "$(echo "$CLINE" | grep -oih 'User Authenticator')" == ''; then
      USER=$(echo "$CLINE" | cut -f 4 -d ' ')
    else
      USER=$(echo "$CLINE" | cut -f 8 -d ' ')
    fi
  fi

  # time based
  if [[ $(( $(date +%s) % 900)) -le 2 ]] && [[ $num_players -ne 0 ]]; then
    say "$(random_musing)"
    sleep 2
  fi

  if [[ $QUIET -ge 300 ]]; then
    QUIET=0
  elif [[ $QUIET -ne 0 ]]; then
    QUIET=$(( QUIET + 1 ))
  fi

  if test "$prevline" != "$CLINE" && not_repeat; then
    echo "prev: $prevline"
    echo "curr: $CLINE"

    # administrative
    if hc 'help'; then show_help; fi

    if hc 'restart'; then
      say 'Okay, restarting!'
      bash "$( cd "$(dirname "$0")"; pwd -P )"/"$(basename "$0")" &
      exit
    fi

    if hc 'be QUIET'; then
      say "Oh... Okay. I'll still do as you say but stay QUIET for a while"
      QUIET=1
      RCOMMAND=0
    fi

    if hc 'you can talk'; then
      say "Hooray!"
      QUIET=0
      RCOMMAND=0
    fi

    if hc 'status update'; then
      say "Active players: $num_players"
      RCOMMAND=0
    fi

    # chatting
    if hc 'how are you'; then
      adverb=$(random "fairly" "quite" "exceptionally" "modestly" "adequately")
      adjective=$(random "swell" "groovy" "superb" "fine" "awesome" "peachy")
      say "I'm feeling $adverb $adjective! I've been alive for $lifetime seconds."
      RCOMMAND=0
    fi

    hcsr 'hello' "Hey there $USER!"
    hcsr 'hey' "Hello there $USER!"
    hcsr 'yes' 'Ah... okay'
    hcsr 'no' 'Oh... okay'
    hcsr 'whatever' 'Well. If you say so'
    hcsr 'thanks' "You're quite welcome $USER!"

    hcsr "what's up" \
      "Not too much $USER! Just $(random 'holding the world together' 'hanging out' 'mind controlling a squid' 'contemplating the universe')"

    if hc 'tell me a joke'; then tell_joke; fi
    if hc 'tell a joke'   ; then tell_joke; fi

    # memory
    if hc 'remember'; then remember_phrase; fi

    if hc 'recall everything'; then
      say "Okay $USER, here's everything I know for you!"
      cat "$MEM_DIR""$USER".memories | while read -r line; do
        say "$line"
      done
      RCOMMAND=0

    elif hc 'recall'; then
      recall_phrase
    fi
    
    if hc 'forget everything'; then
      say "Done $USER, I forgot everything!"
      echo '' > "$MEM_DIR""$USER".memories
      RCOMMAND=0

    elif hc 'forget'; then
      forget_phrase
    fi

    # effects
    hcsr 'make me healthy' \
      "$(random_okay 'This should help you feel better')" \
      "/effect $USER minecraft:instant_health 1 10"

    hcsr 'make me invisible' \
      "$(random_okay 'Not even I know where you are now!')" \
      "/effect $USER minecraft:invisibility 60 5"

    hcsr 'make me fast' \
      "$(random_okay 'Gotta go fast!')" \
      "/effect $USER minecraft:speed 60 5"

    # teleportation
    if hc 'take me home '; then go_home   ; fi
    if hc 'set home as ' ; then set_home  ; fi
    if hc 'take me to '  ; then go_to_dest; fi

    # gamemode
    hcsr 'put me in survival mode' \
      "$(random_okay 'Remember to eat!')" \
      "/gamemode surival $USER"

    hcsr 'put me in creative mode' \
      "$(random_okay)" \
      "/gamemode creative $USER"

    hcsr 'put me in spectator mode' \
      "$(random_okay)" \
      "/gamemode spectator $USER"

    # weather
    hcsr 'make it clear' \
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

    # player joins
    if contains "UUID of player"; then
      sleep 0.1
      say "Hey there $USER! Try saying \"Hal help\""
      num_players=$(( num_players + 1 ))
      RCOMMAND=0

      if [[ $num_players -eq 1 ]]; then
        say "You're the first one here!"

      elif [[ $num_players -eq 2 ]]; then
        say "Three makes a party!"

      elif [[ $num_players -ge 3 ]]; then
        say "Things sure are busy today!"
      fi
    fi

    # player leaves
    if contains "$USER left the game"; then
      say "Goodbye $USER! See you again soon I hope!"
      num_players=$(( num_players - 1 ))
      RCOMMAND=0

      if [[ $num_players -eq 0 ]]; then
        say "All alone..."
        QUIET=0

      elif [[ $num_players -eq 1 ]]; then
        say "I guess it's just you and me now!"
      fi
    fi

    # misc server triggered
    if contains "$USER moved too quickly"; then
      RCOMMAND=0
      say "Woah there $USER! Maybe slow down a little?!"
    fi

    # not sure
    if ! test "$RCOMMAND" == 0 && contains "hal"; then
      say "$(random 'Well...' 'Uhh...' 'Hmm...' 'Ehh...')"
    fi

  fi
  prevline="$CLINE"
done
sleep 1
done
