#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux
#   author  : leaf@anardil.net
#   license : See LICENSE file

# memories.sh

check_memory_actions(){
  : ' none -> none
  check memory actions
  '
  if hc 'remember'; then 
    remember_phrase; 
  fi
  
  if hc 'forget everything'; then 
    forget_everything

  elif hc 'forget'; then 
    forget_phrase
  fi
}

remember_phrase(){
  : ' none -> none
  "hal remember that apples are nice"
  parse out note to remember and write to user file
  '
  local regex='s/\(remember\ \|remember\ that\ \|hal$\)//gI'
  local note=$(grep -oih 'remember .*$' <<< "${CLINE}" | sed -e "$regex")

  if ! [[ -z "$note" ]]; then
    echo "$note" >> "$MEM_DIR""$USER".memories
    say "Okay $USER, I'll remember!"

    # check total disk usage
    local memory_files=( $MEM_DIR*.memories )
    local dir_size=$(\
      du -c "${memory_files}" 2>/dev/null | tail -n 1 | cut -f 1)

    if (( ${dir_size} > ${MAX_MEM_DIR_SIZE} )); then
      local new_size=$(( $MAX_MEM_DIR_SIZE / ${#memory_files[@]} ))

      for file in ${memory_files[@]}; do
        if (( $(wc -c $file) > ${new_size} )); then
          truncate -s $new_size $file
        fi
      done

    # otherwise, max sure this user isn't going over the quota
    else
      local file="$MEM_DIR""$USER"".memories"
      local file_size=$(du -c "$file" | tail -n 1 | cut -f 1)
      if (( $file_size > $MAX_MEM_SIZE )); then
        truncate -s "$MAX_MEM_SIZE" "$file"
      fi
    fi

  else
    say "Remember what?"
  fi
  ran_command
}

recall_phrase(){
  : ' none -> none
  "hal tell me about apples"
  search through user memories for related information
  '
  local regex='s/\(about\ \|hal$\)//gI'
  local phrase=$(echo "$CLINE" | grep -oih 'about .*$' | sed -e "$regex")
  local mem_file="$MEM_DIR""$USER".memories

  if ! [[ -z "$phrase" ]]; then
    if grep -qi "$phrase" "$mem_file"; then
      say "Okay $USER, here's what I know about \"$phrase\":"

      grep -i "$phrase" "$mem_file" | while read -r line; do
        say "\"$line\""
      done
    else
      say "Sorry $USER, looks like I don't know anything about $phrase"
    fi
  else
    say "Recall what?"
  fi
  ran_command
}

recall_everything(){
  : ' none -> none
  "hal recall everything"
  tell user everything in memory file
  '
  say "Okay $USER, here's everything I know for you!"
  cat "$MEM_DIR""$USER".memories | while read -r line; do
    say "$line"
  done
  ran_command
}

forget_phrase(){
  : ' none -> none
  "hal forget about apples" 
  remove all related phrases from user file
  '
  local regex='s/\(\ hal\|hal\ \|about\ \|\ about\)//gI'
  local phrase=$(\
    sed -e "$regex" <<< "${CLINE}" | grep -oih 'forget .*$' | cut -f 2- -d ' ')
  local mem_file="$MEM_DIR""$USER".memories
  local file_contents=$(cat "$mem_file")

  if ! [[ -z "$phrase" ]]; then
    echo "$file_contents" | grep -iv "$phrase\|^$" > "$mem_file"
    say "Okay $USER, I've forgetten everything about \"$phrase!\""

  else
    say "Sorry $USER, I'm not sure what to do"
  fi
  ran_command
}

forget_everything(){
  : ' none -> none
  "hal forget everything" 
  remove all phrases from user file
  '
  say "Done $USER, I forgot everything!"
  echo '' > "$MEM_DIR""$USER".memories
  ran_command
}
