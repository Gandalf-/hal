#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux, inotify-tools
#   author  : leaf@anardil.net
#   license : See LICENSE file

# memories.sh

function check_memory_actions(){
  : ' none -> none
  check memory actions
  '
  if hc 'remember'; then 
    remember_phrase; 
  fi

  if hc 'recall everything'; then 
    recall_everything
  elif hc 'recall'; then 
    recall_phrase
  fi
  
  if hc 'forget everything'; then 
    forget_everything
  elif hc 'forget'; then 
    forget_phrase
  fi
}

function remember_phrase(){
  : ' none -> none
  "hal remember that apples are nice"
  parse out note to remember and write to user file
  '
  local regex='s/\(remember\ \|remember\ that\ \|hal$\)//gI'
  local note=$(echo "$CLINE" | grep -oih 'remember .*$' | sed -e "$regex")

  if test "$note" != ""; then
    echo "$note" >> "$MEM_DIR""$USER".memories
    say "Okay $USER, I'll remember!"
  else
    say "Remember what?"
  fi
  RCOMMAND=0
}

function recall_phrase(){
  : ' none -> none
  "hal recall apples"
  search through user memories for related information
  '
  local regex='s/\(recall\ \|hal$\)//gI'
  local phrase=$(echo "$CLINE" | grep -oih 'recall .*$' | sed -e "$regex")
  local mem_file="$MEM_DIR""$USER".memories

  if test "$phrase" != ""; then
    if test "$(grep "$phrase" "$mem_file")" != ""; then
      say "Okay $USER, here's what I know about \"$phrase\":"
      grep "$phrase" "$mem_file" | while read -r line; do
        say "\"$line\""
      done
    else
      say "Sorry $USER, looks like I don't know anything about $phrase"
    fi
  else
    say "Recall what?"
  fi
  RCOMMAND=0
}

function recall_everything(){
  : ' none -> none
  "hal recall everything"
  tell user everything in memory file
  '
  say "Okay $USER, here's everything I know for you!"
  cat "$MEM_DIR""$USER".memories | while read -r line; do
    say "$line"
  done
  RCOMMAND=0
}

function forget_phrase(){
  : ' none -> none
  "hal forget about apples" 
  remove all related phrases from user file
  '
  local regex='s/\(\ hal\|hal\ \|about\ \|\ about\)//gI'
  local phrase=$(echo "$CLINE" | sed -e "$regex" | grep -oih 'forget .*$' | 
                 cut -f 2- -d ' ')
  local mem_file="$MEM_DIR""$USER".memories
  local file_contents=$(cat "$mem_file")

  if test "$phrase" != ""; then
    echo "$file_contents" | grep -v "$phrase" > "$mem_file"
    say "Okay $USER, I've forgetten everything about \"$phrase!\""
  else
    say "Sorry $USER, I'm not sure what to do"
  fi
  RCOMMAND=0
}

function forget_everything(){
  : ' none -> none
  "hal forget everything" 
  remove all phrases from user file
  '
  say "Done $USER, I forgot everything!"
  echo '' > "$MEM_DIR""$USER".memories
  RCOMMAND=0
}
