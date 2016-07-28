#!/bin/bash

function tell_joke(){
  : ' none -> none
  tell a random joke
  '
  say "$(random \
  'How does Steve get his exercise?  He runs around the block. ' \
  'Have you heard of the creeper that went to a party?  He had a BLAST!' \
  'Whats a ghasts favorite country?  The Nether-Lands!' \
  'Why did the Creeper cross the road?  To get to the other Sssssssside!' \
  'Why did the sailor bring iron and gold into his boat?  He needed oars.' \
  'If there will ever be a Minecraft movie, then it would be a blockbuster.' \
  'Why cant the Ender Dragon read a book?  Because he always starts at the End.' \
  'Why dont blazes ever make businesses?  They keep firing people! ' \
  'What is the national sport of Minecraft?  Boxing.' \
  'What did Steve say to his girlfriend?  I dig you.' \
  'What kind of parties do Minecraft players have?  Block parties. ' \
  'A creeper walks into a bar. Everyone dies.' \
  'When I saw the guy with a potion I knew there was trouble brewing.' \
  'Id tell you a joke about the end, but it will just dragon.' \
  'How do you make people change direction in Minecraft?  You Block their path.' \
  'Why would a mushroom make a good roommate?  Its a real fungi.' \
  'Whats Cobblestones favorite music?  Rock music.' \
  'What did the chicken say to the cow? Pleased to meat you.' \
  'What did the chicken say to the sheep? Pleased to meet ewe.' \
  'What did the chicken say to the ocean? Nothing, it just waved.' \
  'Did you hear about the murder of the snow golem?  It became a cold case.' \
  'What do you get if you push a music box down a mineshaft?  A flat minor.' \
  'How does Herobrine spy on people?  He uses spy-ders.' \
  'Endermen scare people out if their mines.' \
  'After I took the wool off a sheep, it told me, Sheariously?' \
  'Why did the creeper cross the road?  There was an ocelot chasing him.' \
  'What did the minecraft turkey say?  cobble, cobble, cobble! ' \
  'Whats so good about cobblestone?  Its Hand-PICKED.' \
  'What is a creepers favorite subject?  HisssSSSSStory' \
  'I heard Minecraft Steve isnt very good at thinking outside of the box.' \
  'Why couldnt the minecraft player go to the bar?  Because he was a miner.' \
  'An Insult:  Your IQ is lower than bedrock.' \
  'How good is Minecraft?  Top-Notch!' \
  'Why did the enderman cross the road?  He didn’t, he Teleported.' \
  'Whats an endermans favourite band?  Imagine Dragons!' \
  'How does Steve chop down trees with his fists?  How wood I know?' \
  'What is a pigmans favorite cereal?  Golden nuggets.')"
  ran_command=0
}

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
    if test "$debug" == "0"; then
      tmux send-keys -t minecraft "/say [Hal] $1" Enter
    else
      echo "/say [Hal] $1"
    fi
  fi
}

function tell(){
  : ' string -> none
  say a phrase in the server
  '
  if test "$quiet" == "0" ; then
    if test "$debug" == "0"; then
      tmux send-keys -t minecraft "/tell $user $1" Enter
    else
      echo "/tell $user $1"
    fi
  fi
}

function run(){
  : ' string -> none
  run a command in the server
  '
  if test "$1" != ""; then
    if [[ $debug -ne 0 ]]; then
      tmux send-keys -t minecraft "$@" Enter
    else
      echo "$@"
    fi
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
  echo $(random \
    "$1" 'Okay!' 'Sure!' 'You got it!' 'Why not!' 'As you wish!' 'Done!')
}

function random_musing(){
  : ' none -> string
  returns a random musing
  '
  echo $(random \
    'Hmm... I wonder...' 'All systems normal...' 'Counting sheep...' 
    'Just growing some trees...' 'Reorganizing clouds...' \ 
    'Turning dirt to grass...' 'Mind controlling a squid...' \ 
    'Hiding diamonds...' 'Looking for lost cows...' \ 
    'Did you know about overviewer.anardil.net?' )
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

function remember_phrase(){
  : ' none -> none
  parse out note to remember and write to user file
  '
  local regex='s/\(remember\ \|remember\ that\ \|hal$\)//gI'
  local note=$(echo "$currline" | grep -oih 'remember .*$' | sed -e "$regex")

  if test "$note" != ""; then
    echo "$note" >> "$memory_dir""$user".memories
    say "Okay $user, I'll remember!"
  else
    say "Remember what?"
  fi
  ran_command=0
}

function recall_phrase(){
  : ' none -> none
  search through user memories for related information
  '
  local regex='s/\(recall\ \|hal$\)//gI'
  local phrase=$(echo $currline | grep -oih 'recall .*$' | sed -e "$regex")
  local mem_file="$memory_dir""$user".memories

  if test "$phrase" != ""; then
    if test "$(cat $mem_file | grep "$phrase")" != ""; then
      say "Okay $user, here's what I know about \"$phrase\":"
      cat $mem_file | grep "$phrase" | while read line; do
        say "\"$line\""
      done
    else
      say "Sorry $user, looks like I don't know anything about $phrase"
    fi
  else
    say "Recall what?"
  fi
  ran_command=0
}

function forget_phrase(){
  : ' none -> none
  remove all related phrases from user file
  '
  local regex='s/\(\ hal\|hal\ \|about\ \|\ about\)//gI'
  local phrase=$(echo $currline | sed -e "$regex" | grep -oih 'forget .*$' | cut -f 2- -d ' ')
  local mem_file="$memory_dir""$user".memories
  local file_contents=$(cat "$mem_file")

  if test "$phrase" != ""; then
    echo "$file_contents" | grep -v "$phrase" > "$mem_file"
    say "Okay $user, I've forgetten everything about \"$phrase!\""
  else
    say "Sorry $user, I'm not sure what to do"
  fi
  ran_command=0
}
