#!/bin/bash

function go_home(){
  : ' none -> none
  attempts to teleport the current user to their home destination
  '
  local homeline=$(cat "$memory_dir""$user".home)
  local xcoord=$(echo "$homeline" | cut -f 1 -d ' ')
  local ycoord=$(echo "$homeline" | cut -f 2 -d ' ')
  local zcoord=$(echo "$homeline" | cut -f 3 -d ' ')

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
  local homeline=$(echo "$currline" | grep -ioh 'set home as .*$')
  local xcoord=$(echo "$homeline" | cut -f 4 -d ' ')
  local ycoord=$(echo "$homeline" | cut -f 5 -d ' ')
  local zcoord=$(echo "$homeline" | cut -f 6 -d ' ')

  if test "$xcoord" == '' || test "$ycoord" == '' || test "$zcoord" == ''; then
    say "Sorry $user, something doesn't look right with those coordinates"
  else
    echo "$xcoord $ycoord $zcoord" > "$memory_dir""$user".home
    say "Okay $user, I've set your home to be $xcoord $ycoord $zcoord!"
  fi
  ran_command=0
}

