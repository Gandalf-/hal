#!/bin/bash

function remember_phrase(){
  : ' none -> none
  parse out note to remember and write to user file
  '
  local regex='s/\(remember\ \|remember\ that\ \|hal$\)//gI'
  local note=$(echo "$currline" | grep -oih 'remember .*$' | sed -e "$regex")

  if test "$note" != ""; then
    echo "$note" >> "$mem_dir""$user".memories
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
  local mem_file="$mem_dir""$user".memories

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
  local mem_file="$mem_dir""$user".memories
  local file_contents=$(cat "$mem_file")

  if test "$phrase" != ""; then
    echo "$file_contents" | grep -v "$phrase" > "$mem_file"
    say "Okay $user, I've forgetten everything about \"$phrase!\""
  else
    say "Sorry $user, I'm not sure what to do"
  fi
  ran_command=0
}
