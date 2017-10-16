#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux
#   author  : leaf@anardil.net
#   license : See LICENSE file

# teleport.sh

hal_check_teleport_actions(){
  # none -> none
  #
  # wrapper for teleportation actions

  case "$CLINE" in
    *'take me home'*)
      go_home
      ;;

    *'set home as'*)
      set_home
      ;;

    *'take me to'*)
      go_to_dest
      ;;
  esac
}

go_to_dest(){
  # none -> none
  #
  # "hal take me to notch"
  # attempts to teleport the current user to the destination user

  local where dest

  where=$(
    grep -oih 'take me to .*$' <<< "${CLINE}" \
    | sed -e 's/\(hal\)//gI' -e 's/^[[:space:]]*$//' -e 's/[[:space:]]*$//' \
    | cut -f 4- -d ' ')

  if [[ -z "$where" ]]; then
    say "Sorry $USER, I don't know where that is!"

  else
    dest=$(
      grep '\->' ~/.halrc \
        | grep -i "$where" \
        | grep -oih '\->.*$' \
        | cut -f 2- -d ' ')

    if [[ -z "$dest" ]]; then
      say "Okay $USER, I'll try!"
      run "/tp $USER $where"

    else
      say "Okay $USER, I think I know where that is. Off you go!"
      run "/tp $USER $dest"
    fi
  fi
  ran_command
}

go_home(){
  # none -> none
  #
  # "hal take me home"
  # attempts to teleport the current user to their home destination

  local homeline xcoord ycoord zcoord

  homeline=$(cat "$MEM_DIR""$USER".home 2>/dev/null)
  xcoord=$(cut -f 1 -d ' ' <<< "${homeline}" )
  ycoord=$(cut -f 2 -d ' ' <<< "${homeline}" )
  zcoord=$(cut -f 3 -d ' ' <<< "${homeline}" )

  if [[ "$xcoord" && "$ycoord" && "$zcoord" ]]; then
    say "Off you go $USER!"
    run "/tp $USER $xcoord $ycoord $zcoord"

  else
    say "Sorry $USER, either you never told me where home was or I forgot!"
  fi

  ran_command
}

set_home(){
  # none -> none
  #
  # "hal set home as <x> <y> <z>"
  # attempts to set the current users home destination

  local homeline xcoord ycoord zcoord

  homeline=$(grep -io 'set home as .*$' <<< "${CLINE}" )
  xcoord=$(cut -f 4 -d ' ' <<< "${homeline}" )
  ycoord=$(cut -f 5 -d ' ' <<< "${homeline}" )
  zcoord=$(cut -f 6 -d ' ' <<< "${homeline}" )

  if [[ "$xcoord" && "$ycoord" && "$zcoord" ]]; then
    echo "$xcoord $ycoord $zcoord" > "$MEM_DIR""$USER".home
    say "Okay $USER, I've set your home to be $xcoord $ycoord $zcoord!"

  else
    say "Sorry $USER, something doesn't look right with those coordinates"
  fi
  ran_command
}
