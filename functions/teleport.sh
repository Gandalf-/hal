#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux, inotify-tools
#   author  : leaf@anardil.net
#   license : See LICENSE file

# teleport.sh

go_to_dest(){
  : ' none -> none
  "hal take me to notch"
  attempts to teleport the current user to the destination user
  '
  local where=$(\
    grep -oih 'take me to .*$' <<< "${CLINE}" |
    sed -e 's/\(hal\)//gI' -e 's/^[[:space:]]*$//' -e 's/[[:space:]]*$//' |
    cut -f 4- -d ' ') || ''

  if test "$where" == ''; then
    say "Sorry $USER, I don't know where that is!"

  else
    local dest=$(\
      grep '\->' ~/.halrc | grep -i "$where" | grep -oih '\->.*$' |
      cut -f 2- -d ' ')

    if test "$dest" == '' ; then
      say "Okay $USER, I'll try!"
      run "/tp $USER $where"

    else
      say "Okay $USER, I think I know where that is. Off you go!"
      run "/tp $USER $dest"
    fi
  fi
  RCOMMAND=0
}

go_home(){
  : ' none -> none
  "hal take me home"
  attempts to teleport the current user to their home destination
  '
  local homeline=$(cat "$MEM_DIR""$USER".home 2>/dev/null) || ''
  local xcoord=$(cut -f 1 -d ' ' <<< "${homeline}" ) || ''
  local ycoord=$(cut -f 2 -d ' ' <<< "${homeline}" ) || ''
  local zcoord=$(cut -f 3 -d ' ' <<< "${homeline}" ) || ''

  if test "$xcoord" == '' || test "$ycoord" == '' || test "$zcoord" == ''; then
    say "Sorry $USER, either you never told me where home was or I forgot!"
  else
    say "Off you go $USER!"
    run "/tp $USER $xcoord $ycoord $zcoord"
  fi
  RCOMMAND=0
}

set_home(){
  : ' none -> none
  "hal set home as <x> <y> <z>"
  attempts to set the current users home destination
  '
  local homeline=$(echo "$CLINE" | grep -io 'set home as .*$') || ''
  local xcoord=$(cut -f 4 -d ' ' <<< "${homeline}" ) || ''
  local ycoord=$(cut -f 5 -d ' ' <<< "${homeline}" ) || ''
  local zcoord=$(cut -f 6 -d ' ' <<< "${homeline}" ) || ''

  if test "$xcoord" == '' || test "$ycoord" == '' || test "$zcoord" == ''; then
    say "Sorry $USER, something doesn't look right with those coordinates"
  else
    echo "$xcoord $ycoord $zcoord" > "$MEM_DIR""$USER".home
    say "Okay $USER, I've set your home to be $xcoord $ycoord $zcoord!"
  fi
  RCOMMAND=0
}
