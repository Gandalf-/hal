#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux
#   author  : leaf@anardil.net
#   license : See LICENSE file

port="48000"
root_dir='/tmp/hal/demo/'
hal_output_file="${root_dir}hal_output.log"
hal_input_file="${root_dir}hal_input.log"

hal_pretty_print() {
  : ' string -> string
  Converts from hals Minecraft chat format to html format
  '
  if test "$@" != ""; then
    local message="$@"
    message="$(sed 's/</\&lt/g' <<< "${message}")"
    message="$(sed 's/>/\&gt/g' <<< "${message}")"
    message="$(sed 's/\/say//g' <<< "${message}")"
    message="$(sed ':a;N;$!ba;s/\n/<br>/g' <<< "${message}")"
    echo "$message<br>"
  else
    echo ""
  fi
}

do_get() {
  : ' none -> none
  Handles GET requests, only the specified resources are returned
  '
  echo -n "GET: $resource"
  case $resource in
    /)
      ( echo -e "HTTP/1.1 200 OK\n"
      cat index.html
      ) > outgoing
      echo " OK"
      ;;
    /index.html)
      ( echo -e "HTTP/1.1 200 OK\n"
      cat index.html
      ) > outgoing
      echo " OK"
      ;;
    /favicon.ico)
      ( echo -e "HTTP/1.1 200 OK\n"
      cat favicon.ico
      ) > outgoing
      echo " OK"
      ;;
    /robots.txt)
      ( echo -e "HTTP/1.1 200 OK\n"
      cat robots.txt
      ) > outgoing
      echo " OK"
      ;;
    *)
      ( echo -e "HTTP/1.1 404 OK\n"
      ) > outgoing
      echo " FAIL"
      ;;
  esac
}

do_post() {
  : ' none -> none
  Handles POST requests and User -> Server -> Hal -> Server -> User formatting 
  conversions
  '
  echo "POST"
  message=""
  content="$(head -c $content_length incoming)"
  echo "U -> S: \"$content\""

  # log in
  if test "UUID" == ${content::4}; then
    name="$(cut -f 4 -d ' ' <<< "${content}")"
    message="[$(date +"%H:%M:%S")] [Server thread/INFO]: $name joined the game"

  # log out
  elif test "game" == $(tail -c 5 <<< ${content} ); then
    message="[$(date +"%H:%M:%S")] [Server thread/INFO]: $content"

  # chatting
  else
    local name="$(grep -o '[^%%%]*' <<< "${content}" | head -n 1)"
    local message="$(grep -o '[^%%%]*' <<< "${content}" | tail -n +2)"
    message="[$(date +"%H:%M:%S")] [Server thread/INFO]: <${name}> ${message}"
  fi

  # provide hal user input, timeout after 1 second
  echo "S -> H: ${message}"
  echo "${message}" >> $hal_input_file

  # wait for hal to work, timeout after 1 second
  timeout=$(( $(date +'%s') + 1))
  before_time=$(stat -c '%Z' $hal_output_file)
  current_time=$before_time

  while test $before_time -eq $current_time; do
    current_time=$(stat -c '%Z' $hal_output_file)

    if test $(date +'%s') -gt $timeout; then
      break
    fi
    sleep 0.1
  done

  # return hal's response to user, clear output file
  reply="$(cat ${hal_output_file})"
  echo "H -> S: ${reply}"
  reply="$(hal_pretty_print "${reply}")"
  echo -n "" > ${hal_output_file}
  echo "S -> U: ${reply}"

  ( echo -e "HTTP/1.1 200 OK\n"
    echo "${reply}"
    echo ""
  ) > outgoing
}

cleanup() {
  : ' none -> none
  kill the web server, hal instance and remove FIFOs and log files
  '
  echo ""
  echo "Stopping server"
  kill $server_pid
  echo "Stopping hal"
  kill $hal_pid
  echo "Exiting"
  rm -f outgoing incoming $hal_input_file $hal_output_file
  exit
}

# setup
trap cleanup INT

mkdir -p $root_dir
touch $hal_output_file $hal_input_file

rm -f outgoing incoming
mkfifo outgoing incoming

# start hal
echo "Starting hal..."
bash ../hal.sh $hal_input_file ../ $root_dir $hal_output_file &
hal_pid=$!

# start http server
echo "Starting server..."
while true; do
  cat outgoing | nc -l ${port} > incoming &
  server_pid=$!
  method=""
  content_length=""

  # get headers
  while true; do
    read -r line < incoming

    case "$line" in
      GET*)
        method="GET"
        resource="$(cut -f 2 -d ' ' <<< ${line})"
        ;;
      POST*)
        method="POST"
        ;;
      Content-Length*)
        content_length=$(grep -o "[0-9]*" <<< ${line})
        ;;
    esac
    #echo -e "$line"

    if grep -P '^\s$' <<< ${line}; then
      break
    fi
  done

  # determine response
  case $method in 
    GET)
      do_get
      ;;
    POST)
      do_post
      ;;
    *)
      echo "Unhandled method"
      ;;
  esac
done
