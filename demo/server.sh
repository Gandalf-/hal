#!/bin/bash

port="48000"
root_dir='/tmp/hal/demo/'
hal_output_file="${root_dir}hal_output.log"
hal_input_file="${root_dir}hal_input.log"

do_get() {
  : ' none -> none
  '
  echo "GET REQUEST START"

  ( echo -e "HTTP/1.1 200 OK\n"
    cat index.html
  ) > outgoing

  echo "GET REQUEST DONE"
}

do_post() {
  : ' none -> none
  '
  echo "POST REQUEST START"

  message=""
  content="$(head -c $content_length incoming)"
  echo "Recieved \"$content\""

  # log in
  if test "UUID" == ${content::4}; then
    echo "Player log in"
    message="[$(date +"%H:%M:S")] [User Authenticator #8/INFO]: $content"

  # log out
  elif test "game" == $(tail -c 5 <<< ${content} ); then
    echo "Player log out"
    message="[$(date +"%H:%M:S")] [User Authenticator #8/INFO]: $content"

  # chatting
  else
    local name=""
    local message=""
    message="[$(date +"%H:%M:%S")] [Server thread/INFO]: <${name}> $message"
  fi

  # provide hal user input, timeout after 1 second
  echo $message >> $hal_input_file

  # wait for hal to work, timeout after 1 second
  timeout=$(( $(date +'%s') + 1))
  before_time=$(stat -c '%Z' $hal_output_file)
  current_time=$before_time

  while test $before_time -eq $current_time; do
    sleep 0.1
    current_time=$(stat -c '%Z' $hal_output_file)

    if test $(date +'%s') -gt $timeout; then
      break
    fi
  done
  sleep 0.1

  # return hal's response to user, clear output file
  reply="$(cat $hal_output_file)"
  echo "Sending: $reply"

  ( 
    echo -e "HTTP/1.1 200 OK\n"
    echo "${reply}"
    echo ""
  ) > outgoing
  echo "POST REQUEST DONE"
}

cleanup() {
  : ' none -> none
  '
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
bash ../hal.sh $hal_input_file ../ $root_dir $hal_output_file &
hal_pid=$!

# start http server
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
