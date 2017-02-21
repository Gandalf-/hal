#!/bin/bash -p

# Hal: Minecraft AI in Shell
#   requires: bash, tmux
#   author  : leaf@anardil.net
#   license : See LICENSE file

set -f -o pipefail
umask u=rw,g=,o=

readonly PORT="48000"
readonly ROOT_DIR='/tmp/hal/demo/'
readonly HAL_OUTPUT_FILE="${ROOT_DIR}hal_output.log"
readonly HAL_INPUT_FILE="${ROOT_DIR}hal_input.log"
readonly server2client="${ROOT_DIR}server2client"
readonly client2server="${ROOT_DIR}client2server"

hal_pretty_print() {
  : ' string -> string
  Converts from hals Minecraft chat format to html format
  '
  if ! [[ -z "${@}" ]]; then
    local message
    message="${*}"
    message="${message//</&lt}"
    message="${message//>/&gt}"
    message="${message//\/say/}"
    message="$(sed ':a;N;$!ba;s/\n/<br>/g' <<< "${message}")"
    echo "${message}<br>"
  fi
}

do_get() {
  : ' none -> none
  Handles GET requests, only the specified resources are returned
  '
  echo -n "GET: ${RESOURCE}"
  case "${RESOURCE}" in
    /)
      ( echo -e "HTTP/1.1 200 OK\n"
      cat index.html
      ) > ${server2client}
      echo " OK"
      ;;
    /index.html)
      ( echo -e "HTTP/1.1 200 OK\n"
      cat index.html
      ) > ${server2client}
      echo " OK"
      ;;
    /favicon.ico)
      ( echo -e "HTTP/1.1 200 OK\n"
      cat favicon.ico
      ) > ${server2client}
      echo " OK"
      ;;
    /robots.txt)
      ( echo -e "HTTP/1.1 200 OK\n"
      cat robots.txt
      ) > ${server2client}
      echo " OK"
      ;;
    *)
      ( echo -e "HTTP/1.1 404 OK\n"
      ) > ${server2client}
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
  local content header user_regex message_regex
  content="$(head -c "${CONTENT_LENGTH}" ${client2server})"
  header="[$(date +"%H:%M:%S")] [Server thread/INFO]:"
  user_regex='[A-Za-z]'
  message_regex='[A-Za-z0-9:\+\/\%\^\*\-\ \(\)\n]'
  echo "U -> S: \"${content}\""

  # log in
  local name message output
  if [[ "${content}" =~ (has joined the game) ]]; then
    name="$(tr -cd "${user_regex}" <<< "${content// has joined the game/}")"
    output="${header} ${name} joined the game"

  # log out
  elif [[ "${content}" =~ (left the game) ]]; then
    name="$(tr -cd "${user_regex}" <<< "${content// left the game/}")"
    output="${header} ${name} left the game"

  # chatting
  else
    name="$(grep -o '[^%%%]*' <<< "${content}" | head -n 1 )"
    message="$(grep -o '[^%%%]*' <<< "${content}" | tail -n +2)"
    name="$(tr -cd "${user_regex}" <<< "${name}" )"
    message="$(tr -cd "${message_regex}" <<< "${message}" )"
    output="${header} <${name}> ${message}"
  fi

  # provide hal user input, timeout after 1 second
  echo "S -> H: ${output}"
  echo "${output}" >> "${HAL_INPUT_FILE}"

  # wait for hal to work, timeout after 1 second
  local timeout before_time current_time
  timeout=$(( $(date +'%s') + 1))
  before_time=$(stat -c '%Z' "${HAL_OUTPUT_FILE}")
  current_time=$before_time

  while [[ "$before_time" == "$current_time" ]]; do
    current_time=$(stat -c '%Z' $HAL_OUTPUT_FILE)
    (( $(date +'%s') > timeout )) && break
    sleep 0.005
    echo -n "."
  done
  echo

  # return hal's response to user, clear output file
  local reply
  reply="$(cat ${HAL_OUTPUT_FILE})"
  echo "H -> S: ${reply}"

  reply="$(hal_pretty_print "${reply}")"
  echo -n "" > ${HAL_OUTPUT_FILE}
  echo "S -> U: ${reply}"

  ( echo "HTTP/1.1 200 OK"
    echo ""
    echo "${reply}"
    echo ""
  ) > ${server2client}
}

cleanup() {
  : ' none -> none
  kill the web server, hal instance and remove FIFOs and log files
  '
  echo ""
  echo "Stopping hal   "; kill "${HAL_PID}"
  echo "Cleaning up filesystem"; rm -rf "${ROOT_DIR}"
  echo "Exiting"
  exit
}

main() {
  : ' none -> none
  '
  # setup
  trap cleanup INT
  rm -rf ${ROOT_DIR}
  mkdir -p ${ROOT_DIR}
  chmod u+x ${ROOT_DIR}
  touch ${HAL_OUTPUT_FILE} ${HAL_INPUT_FILE}
  mkfifo ${server2client} ${client2server}

  # start hal
  echo "Starting hal..."
  bash ../hal.sh ${HAL_INPUT_FILE} ../ ${ROOT_DIR} ${HAL_OUTPUT_FILE} &
  readonly HAL_PID=$!

  while true; do
    nc -l -p ${PORT} < <(cat "${server2client}") > "${client2server}"
  done &

  # start http server
  echo "Starting server..."
  while true; do

    CONTENT_LENGTH=0
    local method=""

    # get headers
    while true; do
      read -r line < ${client2server}

      case "$line" in
        GET*)
          method="GET"
          RESOURCE="$(cut -f 2 -d ' ' <<< "${line}")"
          ;;
        POST*)
          method="POST"
          ;;
        Content-Length*)
          CONTENT_LENGTH=$(grep -o "[0-9]*" <<< "${line}")
          ;;
      esac
      #echo -e "$line"

      grep -P '^\s$' <<< "${line}" && break
    done

    # determine response
    case $method in
      GET)
        do_get
        ;;
      POST)
        do_post
        ;;
    esac
  done
}

main
