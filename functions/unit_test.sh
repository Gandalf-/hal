#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux, inotify-tools
#   author  : leaf@anardil.net
#   license : See LICENSE file

# unit_test.sh

source "./utility.sh"
source "./memories.sh"
source "./chatting.sh"
source "./teleport.sh"

debug=1
quiet=0
user='<player1>'

# boilerplate
#==================
function test_cleanup(){
  debug=1 ; quiet=0 ; user='<player1>'; echo
}
function pass(){ echo -n " pass"; }
function fail(){ echo " fail"; }
function scpass(){
  if test "$1" == "$2"; then 
    pass
  else 
    fail; echo "Expected: $1"; echo "Received: $2"
  fi
}
function scfail(){
  if test "$1" == "$2"; then 
    fail; echo "Expected: $1"; echo "Received: $2"
  else 
    pass
  fi
}
function rcpass(){
  if test "$(echo "$1" | grep -F "$2")" != ""; then 
    pass
  else 
    fail; echo "Expected: $2"; echo "Received: $1"
  fi
}
function rcfail(){
  if test "$(echo "$1" | grep "$2")" != ""; then 
    fail; echo "Expected: $2"; echo "Received: $1"
  else pass; fi
}
function ocpass(){
  if [[ $? -eq 0 ]]; then 
    pass
  else 
    fail; echo "Return value was non-zero"
  fi
}
function ocfail(){
  if [[ $? -eq 0 ]]; then 
    fail; echo "Return value was zero"
  else 
    pass
  fi
}
function test_test(){
  echo -n 'test            '
  scpass 'a' 'a'
  rcpass 'apple blueberry watermelon' 'blue'
  true ; ocpass 
  scfail 'a' 'b'
  rcfail 'apple blueberry watermelon' 'green'
  false ; ocfail 
  test_cleanup
}

# tests
#==================
function test_requirements(){
  : ' none -> none
  make sure all the required external programs are present
  '
  echo -n 'requirements    '
  rcpass "$(which tmux)" "tmux"
  rcpass "$(bash --version)" "version 4"
  rcpass "$(which inotifywait)" "inotifywait"
  rcpass "$(which sed)" "sed"
  test_cleanup
}

function test_tell_joke(){
  : ' none -> none
  make sure tell_joke() returns a string
  '
  echo -n 'tell_joke       '
  scfail tell_joke ""
  test_cleanup
}

function test_hc(){
  : ' none -> none
  make sure hc() only accepts inputs that match "hal" and $1
  '
  echo -n 'hc              '
  declare -a arry=('hal blah' 'HAL blah blah' 'BLAH HAL' 'blah hAl blah')
  for currline in "${arry[@]}"; do
    $(hc 'blah')
    ocpass 
  done

  declare -a arry=('blah' 'hal herp' 'HAL' 'herp')
  for currline in "${arry[@]}"; do
    $(hc 'blah')
    ocfail 
  done
  test_cleanup
}

function test_contains(){
  : ' none -> none
  make sure that contains() succeeds when $1 is present in $currline
  '
  echo -n 'contains        '
  declare -a arry=('hal blah' 'hal blah blah' 'blah HAL' 'blah hAl blah' 'BLAH')
  for currline in "${arry[@]}"; do
    $(contains 'blah')
    ocpass
  done

  declare -a arry=('goof' 'hal herp' 'HAL' 'herp derp')
  for currline in "${arry[@]}"; do
    $(contains 'blah')
    ocfail
  done
  test_cleanup
}

function test_say(){
  : ' none -> none
  make sure say() builds "/say [Hal] <phrase>" commands correctly
  '
  echo -n 'say             '
  scpass "$(say "hello there")" '/say [Hal] hello there'
  scpass "$(say "hello there $user")" '/say [Hal] hello there <player1>'
  scpass "$(say "")" '/say [Hal] '
  test_cleanup
}

function test_tell(){
  : ' none -> none
  make sure tell() builds "/tell $user <phrase>" commands correctly
  '
  echo -n 'tell            '
  scpass "$(tell "hello there")" "/tell $user hello there"
  scpass "$(tell "hello $user there wow")" "/tell $user hello $user there wow"
  scpass "$(tell "")" "/tell $user "
  scpass "$(tell )" "/tell $user "
  quiet=1
  scpass "$(tell "hello there")" ""
  scpass "$(tell "hello $user there wow")" ""
  test_cleanup
}

function test_run(){
  : ' none -> none
  make sure run() builds "/<command>" commands correctly
  '
  echo -n 'run             '
  scpass "$(run "/hello there")" "/hello there"
  scpass "$(run "/hello $user there wow")" "/hello $user there wow"
  scpass "$(run "")" ""
  scpass "$(run   )" ""
  test_cleanup
}

function test_not_repeat(){
  : ' none -> none
  make sure that not_repeat() returns 0 if $currline contains output from hal.sh
  '
  echo -n 'not_repeat      '
  declare -a arry=('[hal] blah' '[hal] BLAH ' 'blah [HAL]' 'blah [hAl] blah')
  for currline in "${arry[@]}"; do
    not_repeat
    ocfail 
  done

  declare -a arry=('goof' 'hal herp' 'HAL' 'herp derp')
  for currline in "${arry[@]}"; do
    not_repeat
    ocpass 
  done
  test_cleanup
}

function test_random(){
  : ' none -> none
  make sure random() returns a selection out of the arguments
  '
  echo -n 'random          '
  scpass "$(random 'hello')" 'hello'
  scpass "$(random 'string with spaces')" 'string with spaces'
  scpass "$(random)" ''
  scfail "$(random 'hello')" 'goodbye'
  scfail "$(random 'hello there' 'goodbye')" ''
  test_cleanup
}

function test_random_okay(){
  : ' none -> none
  make sure random_okay() always returns a string
  '
  echo -n 'random_okay     '
  scfail "$(random_okay 'hello')" ''
  scfail "$(random_okay '')" ''
  test_cleanup
}

function test_random_musing(){
  : ' none -> none
  make sure random_musing() always returns a string
  '
  echo -n 'random_musing   '
  scfail "$(random_okay)" ''
  test_cleanup
}

function test_shut_down(){
  : ' none -> none
  make sure shut_down() reports to the users that hal.sh is shutting down
  '
  echo -n 'shut_down       '
  rcpass "$(shut_down)" "Hal shutting down"
  test_cleanup
}

function test_hcsr(){
  : ' none -> none
  make sure hcsr() says $2 and runs $3 if "hal" is present in $currline
  '
  echo -n 'hcsr            '
  currline='hal whats up?'
  rcpass "$(hcsr 'whats up' 'okie doke' '/my command')" '/say [Hal] okie doke'
  rcpass "$(hcsr 'whats up' 'okie doke' '/my command')" '/my command'

  currline='hal WHATS UP?'
  rcpass "$(hcsr 'whats up' 'okie doke' '/my command')" '/say [Hal] okie doke'
  rcpass "$(hcsr 'whats up' 'okie doke' '/my command')" '/my command'

  currline='whats up hal?'
  rcpass "$(hcsr 'whats up' 'okie doke' '/my command')" '/say [Hal] okie doke'
  rcpass "$(hcsr 'whats up' 'okie doke' '/my command')" '/my command'

  currline='WHATS UP hal?'
  rcpass "$(hcsr 'whats up' 'okie doke' '/my command')" '/say [Hal] okie doke'
  rcpass "$(hcsr 'whats up' 'okie doke' '/my command')" '/my command'

  currline='herbert be quiet'
  rcfail "$(hcsr 'be quiet' 'okie doke' '/my command')" '/say [Hal] okie doke'
  rcfail "$(hcsr 'be quiet' 'okie doke' '/my command')" '/my command'
  test_cleanup
}

function test_go_to_dest(){
  : ' none -> none
  make sure that go_to_dest() can handle the following cases:
    - hal take me to <dest in config>
    - take me to <dest in config> hal
    - hal take me to <player>
    - take me to <player> hal
  '
  echo -n 'go_to_dest      '
  user='player'
  currline='hal take me to the telehub'
  rcpass "$(go_to_dest)" "Okay $user, I think I know where that is."
  rcpass "$(go_to_dest)" '/tp player -108 3 98'

  currline='take me to the telehub hal'
  rcpass "$(go_to_dest)" "Okay $user, I think I know where that is."
  rcpass "$(go_to_dest)" '/tp player -108 3 98'

  currline='HAL TAKE ME TO THE TELEHUB'
  rcpass "$(go_to_dest)" "Okay $user, I think I know where that is."
  rcpass "$(go_to_dest)" '/tp player -108 3 98'

  currline='TAKE ME TO THE TELEHUB HAL'
  rcpass "$(go_to_dest)" "Okay $user, I think I know where that is."
  rcpass "$(go_to_dest)" '/tp player -108 3 98'

  currline='hal go to the telehub'
  rcpass "$(go_to_dest)" "Sorry player, I don't know where that is"

  currline='go to the telehub hal'
  rcpass "$(go_to_dest)" "Sorry player, I don't know where that is"
  echo
  echo -n '                '

  currline='hal go to blerug'
  rcpass "$(go_to_dest)" "Sorry player, I don't know where that is"

  currline='hal take me to Jimmy'
  rcpass "$(go_to_dest)" "Okay player, I'll try!"
  rcpass "$(go_to_dest)" "/tp player Jimmy"

  currline='take me to Jimmy hal'
  rcpass "$(go_to_dest)" "Okay player, I'll try!"
  rcpass "$(go_to_dest)" "/tp player Jimmy"

  currline='hal take me to Herp Derp'
  rcpass "$(go_to_dest)" "Okay player, I'll try!"
  rcpass "$(go_to_dest)" "/tp player Herp Derp"
  test_cleanup
}

function test_go_home(){
  : ' none -> none
  '
  echo -n 'go_home         '
  test_cleanup
}

function test_set_home(){
  : ' none -> none
  '
  echo -n 'set_home        '
  test_cleanup
}

function test_remember_phrase(){
  : ' none -> none
  '
  echo -n 'remember_phrase '
  test_cleanup
}

function test_recall_phrase(){
  : ' none -> none
  '
  echo -n 'recall_phrase   '
  test_cleanup
}

function test_forget_phrase(){
  : ' none -> none
  '
  echo -n 'forget_phrase   '
  test_cleanup
}

# run
#==================
test_test
test_requirements
test_tell_joke
test_hc
test_contains
test_say
test_tell
test_run
test_not_repeat
test_random
test_random_okay
test_random_musing
test_shut_down
test_hcsr
test_go_to_dest
test_go_home
test_set_home
test_remember_phrase
test_recall_phrase
test_forget_phrase
