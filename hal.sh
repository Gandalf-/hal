#!/bin/bash

# Modify this line to reflect your configuration
log_file='/home/minecraft/logs/latest.log'
memory_dir='/tmp/hal/'

function hc(){
  : ' string -> int
  check if the current line contains the required text and the "hal" keyword
  '
  if test "$(echo "$currline" | grep -ioh "$1")" == ""; then
    return 1
  else
    if test "$(echo "$currline" | grep -ioh "Hal")" == ""; then
      return 1
    else
      return 0
    fi
  fi
}

function contains(){
  : ' string -> int
  check if the current line contains the required text
  '
  if test "$(echo "$currline" | grep -ioh "$1")" == ""; then
    return 1
  else
    return 0
  fi
}

function say(){
  : ' string -> none
  say a phrase in the server
  '
  if test "$quiet" == "0" ; then
    tmux send-keys -t minecraft "/say [Hal] $1" Enter
  fi
}

function run(){
  : ' string -> none
  run a command in the server
  '
  if test "$1" != ""; then
    tmux send-keys -t minecraft "$@" Enter
  fi
}

function not_repeat(){
  : ' none -> int
  checks if the current line contains something from Hal
  makes sure we dont trigger commands off of ourself
  '
  if test "$(echo "$currline" | grep "\[Hal\]")" == ""; then
    return 0
  else
    return 1
  fi
}

function random(){
  : ' any, ... -> any
  returns a randomly chosen element out of the arguments
  '
  local array=("$@")
  echo ${array[$RANDOM % ${#array[@]} ]}
}

function random_okay(){
  : ' string -> string
  returns a random affirmative
  '
  echo "$(random "$1" 'Okay!' 'Sure!' 'You got it!' 'Why not!' 'As you wish!' 'Done!')"
}

function random_musing(){
  : ' none -> string
  returns a random musing
  '
  echo "$(random 'Hmm... I wonder...' 'All systems normal...' 'Counting sheep...' 'Just growing some trees...' 'Reorganizing clouds...' 'Turning dirt to grass...' 'Mind controlling a squid...' 'Hiding diamonds...' 'Looking for lost cows...' 'Did you know about overviewer.anardil.net?')"
}

function shut_down(){
  : ' none -> none
  interrupt handler
  '
  echo 'Hal shutting down'
  say 'I died!'
  exit
}

function hcsr(){
  : ' string, string, string -> none
  wrapper around check $1, say $2, run $3 logic
  '
  if $(hc "$1"); then
    say "$2"
    run "$3"
    ran_command=0
  fi
}

function go_home(){
  : ' none -> none
  attempts to teleport the current user to their home destination
  '
  homeline=$(cat "$memory_dir""$user".home)
  xcoord=$(echo "$homeline" | cut -f 1 -d ' ')
  ycoord=$(echo "$homeline" | cut -f 2 -d ' ')
  zcoord=$(echo "$homeline" | cut -f 3 -d ' ')

  if test "$xcoord" == '' || test "$ycoord" == '' || test "$zcoord" == ''; then
    say "Sorry $user, either you never told me where home was or I forgot!"

  else
    say "Off you go $user!"
    run "/tp $user $xcoord $ycoord $zcoord"
  fi
  ran_command=0
}

function set_home(){
  : ' none -> none
  attempts to set the current users home destination
  '
  homeline=$(echo "$currline" | grep -oh 'set home as .*$')
  xcoord=$(echo "$homeline" | cut -f 4 -d ' ')
  ycoord=$(echo "$homeline" | cut -f 5 -d ' ')
  zcoord=$(echo "$homeline" | cut -f 6 -d ' ')

  if test "$xcoord" == '' || test "$ycoord" == '' || test "$zcoord" == ''; then
    say "Sorry $user, something doesn't look right with those coordinates"

  else
    echo "$xcoord $ycoord $zcoord" > "$memory_dir""$user".home
    say "Okay $user, I've set your home to be $xcoord $ycoord $zcoord!"
  fi
  ran_command=0
}

currline=""
prevline=""
user=""
ran_command=0
num_players=0
quiet=0

echo 'Hal starting up'
say "I'm alive!"
trap shut_down INT
starttime=$(date +%s)
mkdir -p "$memory_dir"
sleep 1

while inotifywait -e modify $log_file; do

  # preparation
  ran_command=1
  currline=$(tail -n 3 $log_file | grep -v 'Keeping entity' | tail -n 1)
  lifetime=$(expr $(date +%s) - $starttime)

  user=$(echo "$currline" | grep -oh '<[^ ]*>' | grep -oh '[^<>]*')
  if test "$user" == ""; then
    if test "$(echo "$currline" | grep "User Authenticator")" == ''; then
      user=$(echo "$currline" | cut -f 4 -d ' ')
    else
      user=$(echo "$currline" | cut -f 8 -d ' ')
    fi
  fi

  # time based
  if [[ $(expr $(date +%s) % 900) -le 2 ]] && [[ $num_players -ne 0 ]] ; then
    say "$(random_musing)"
    sleep 2
  fi

  if [[ $quiet -ge 300 ]] ; then
    quiet=0
  elif [[ $quiet -ne 0 ]] ; then
    quiet=$(expr $quiet + 1)
  fi

  if test "$prevline" != "$currline" && not_repeat ; then

    # administrative
    if $(hc "help"); then
      say "I'm Hal, a teenie tiny AI that will try to help you!"
      say "Here are somethings I understand:"
      say "- hello, hey, how are you, what's up"
      say "- thanks, yes, no, whatever"
      say "- help, restart, be quiet, you can talk, status update"
      say "- make it (day, night, clear, rainy)"
      say "- make me (healthy, invisible, fast)"
      say "- take me (to the telehub, home)"
      say "- set home as <x> <y> <z>"
      say "- put me in (creative, survival, spectator) mode"
      ran_command=0
    fi

    if $(hc 'restart'); then
      say 'Okay, restarting!'
      bash "$( cd $(dirname $0) ; pwd -P )"/"$(basename $0)" &
      exit
    fi

    if $(hc 'be quiet'); then
      say "Oh... Okay. I'll still do as you say but stay quiet for a while"
      quiet=1
      ran_command=0
    fi

    if $(hc 'you can talk'); then
      say "Hooray!"
      quiet=0
      ran_command=0
    fi

    if $(hc 'status update'); then
      say "Active players: $num_players"
      ran_command=0
    fi

    # chatting
    if $(hc 'how are you'); then
      adverb=$(random "fairly" "quite" "exceptionally" "modestly" "adequately")
      adjective=$(random "swell" "groovy" "superb" "fine" "awesome" "peachy")
      say "I'm feeling $adverb $adjective! I've been alive for $lifetime seconds."
      ran_command=0
    fi

    hcsr 'hello' "Hey there $user!"
    hcsr 'hey' "Hello there $user!"
    hcsr 'yes' 'Ah... okay'
    hcsr 'no' 'Oh... okay'
    hcsr 'whatever' 'Well. If you say so'
    hcsr 'thanks' "You're quite welcome $user!"

    hcsr "what's up" \
      "Not too much $user! Just $(random 'holding the world together' 'hanging out' 'mind controlling a squid' 'contemplating the universe')"

    # effects
    hcsr 'make me healthy' \
      "$(random_okay 'This should help you feel better')" \
      "/effect $user minecraft:instant_health 1 10"

    hcsr 'make me invisible' \
      "$(random_okay 'Not even I know where you are now!')" \
      "/effect $user minecraft:invisibility 60 5"

    hcsr 'make me fast' \
      "$(random_okay 'Gotta go fast!')" \
      "/effect $user minecraft:speed 60 5"

    # teleportation
    hcsr 'take me to the telehub' \
      "$(random_okay 'Off you go!')" \
      "/tp $user -108 3 98"

    if $(hc 'take me home'); then
      go_home
    fi

    if $(hc 'set home as'); then
      set_home
    fi

    # gamemode
    hcsr 'put me in survival mode' \
      "$(random_okay 'Remember to eat!')" \
      "/gamemode surival $user"

    hcsr 'put me in creative mode' \
      "$(random_okay)" \
      "/gamemode creative $user"

    hcsr 'put me in spectator mode' \
      "$(random_okay)" \
      "/gamemode spectator $user"

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
    if $(contains "UUID of player"); then
      sleep 0.1
      say "Hey there $user! Try saying \"Hal help\""
      num_players=$(expr $num_players + 1)
      ran_command=0

      if [[ $num_players -eq 1 ]] ; then
        say "You're the first one here!"

      elif [[ $num_players -eq 2 ]] ; then
        say "Three makes a party!"

      elif [[ $num_players -ge 3 ]] ; then
        say "Things sure are busy today!"
      fi
    fi

    # player leaves
    if $(contains "$user left the game"); then
      say "Goodbye $user! See you again soon I hope!"
      num_players=$(expr $num_players - 1)
      ran_command=0

      if [[ $num_players -eq 0 ]] ; then
        say "All alone..."
        quiet=0

      elif [[ $num_players -eq 1 ]] ; then
        say "I guess it's just you and me now!"
      fi
    fi

    # misc server triggered
    if $(contains "$user moved too quickly"); then
      say "Woah there $user! Maybe slow down a little?!"
      ran_command=0
    fi

    # not sure
    if ! test "$ran_command" == 0 && $(contains "hal"); then
      say $(random 'Well...' 'Uhh...' 'Hmm...' 'Ehh...')
    fi

  fi

  prevline="$currline"
done
