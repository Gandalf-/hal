#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux
#   author  : leaf@anardil.net
#   license : See LICENSE file

# memories.sh

check_memory_actions(){
  # : ' none -> none
  # check memory actions
  # '
  case "$CLINE" in
    *'remember'*)
      remember_phrase
      ;;
    *'forget everything'*)
      forget_everything
      ;;
    *'forget'*)
      forget_phrase
      ;;
  esac
}

remember_phrase(){
  # : ' none -> none
  # "hal remember that apples are nice"
  # parse out note to remember and write to user file
  # '
  local regex note memory_files dir_size new_size file file_size

  regex='s/\(remember\ \|remember\ that\ \|hal$\)//gI'
  note="$(
    grep -oih 'remember .*$' <<< "${CLINE}" |
    sed -e "$regex")"

  if ! [[ -z "$note" ]]; then
    echo "$note" >> "$MEM_DIR""$USER".memories
    say "Okay $USER, I'll remember!"

    # check total disk usage
    memory_files=( $MEM_DIR*.memories )
    dir_size=$(\
      du -c "${memory_files[@]}" 2>/dev/null | tail -n 1 | cut -f 1)

    if (( dir_size > MAX_MEM_DIR_SIZE )); then
      new_size=$(( MAX_MEM_DIR_SIZE / ${#memory_files[@]} ))

      for file in "${memory_files[@]}"; do
        (( $(wc -c "$file") > new_size )) && truncate -s "$new_size" "$file"
      done

    # otherwise, make sure this user isn't going over the quota
    else
      file="$MEM_DIR""$USER"".memories"
      file_size=$(du -c "$file" | tail -n 1 | cut -f 1)

      (( file_size > MAX_MEM_SIZE )) && truncate -s "$MAX_MEM_SIZE" "$file"
    fi

  else
    say "Remember what?"
  fi
  ran_command
}

recall_phrase(){
  # : ' none -> none
  # "hal tell me about apples"
  # search through user memories for related information
  # '
  local regex phrase mem_file url

  url='https://en.wikipedia.org/wiki'
  regex='s/\(about\ \|\ hal$\)//gI'
  phrase=$(
    grep -oih 'about .*$' <<< "${CLINE}" |
    sed -e "$regex")
  mem_file="$MEM_DIR""$USER".memories

  if ! [[ -z "$phrase" ]]; then
    # read from memory file
    if grep -qi "$phrase" "$mem_file" 2>/dev/null ; then
      say "Okay $USER, here's what I know about \"$phrase\":"

      grep -i "$phrase" "$mem_file" | while read -r line; do
        say "\"$line\""
      done

    # fetch from wikipedia
    else
      phrase=${phrase,,}
      phrase=${phrase^}
      reply=$(
        curl -s "${url}/${phrase/ /_}" |
        grep -i "<b>${phrase}" |
        head -n 1 |
        sed -n '/^$/!{s/\(<[^>]*>\|\[[^\]]*\)//g;p;}' |
        head -c 300)

      if [[ -z "$reply" ]]; then
        say "Sorry $USER, looks like I don't know anything about \"${phrase}\"!"

      else
        say "Okay $USER, here's what the internet says:"

        if (( ${#reply} > 298 )); then
          say "\"${reply}...\""
        else
          say "\"${reply}\""
        fi

      fi
    fi

  else
    say "Recall what?"
  fi
  ran_command
}

recall_everything(){
  # : ' none -> none
  # "hal recall everything"
  # tell user everything in memory file
  # '
  say "Okay $USER, here's everything I know for you!"

  while read -r line; do
    say "$line"
  done < "$MEM_DIR""$USER".memories

  ran_command
}

forget_phrase(){
  # : ' none -> none
  # "hal forget about apples"
  # remove all related phrases from user file
  # '
  local regex phrase mem_file file_contents

  regex='s/\(\ hal\|hal\ \|about\ \|\ about\)//gI'
  phrase=$(
    sed -e "$regex" <<< "${CLINE}" |
    grep -oih 'forget .*$' |
    cut -f 2- -d ' ')
  mem_file="$MEM_DIR""$USER".memories
  file_contents=$(cat "$mem_file")

  if ! [[ -z "$phrase" ]]; then
    grep -iv "$phrase\|^$" <<< "$file_contents" > "$mem_file"
    say "Okay $USER, I've forgetten everything about \"$phrase!\""

  else
    say "Sorry $USER, I'm not sure what to do"
  fi
  ran_command
}

forget_everything(){
  # : ' none -> none
  # "hal forget everything"
  # remove all phrases from user file
  # '
  say "Done $USER, I forgot everything!"
  echo '' > "$MEM_DIR""$USER".memories
  ran_command
}
