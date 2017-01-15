#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux
#   author  : leaf@anardil.net
#   license : See LICENSE file

# unit_test.sh

source "./test_framework.sh"

source "./utility.sh"
source "./memories.sh"
source "./chatting.sh"
source "./teleport.sh"
source "./intent.sh"

DEBUG=1
QUIET=0
USER='<player1>'
MEM_DIR='/tmp/haltest/'
MAX_MEM_SIZE=1024
MAX_MEM_DIR_SIZE=$(($MAX_MEM_SIZE * 10))

# tests
#==================
test_requirements(){
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

test_tell_joke(){
  : ' none -> none
  make sure tell_joke() returns a string
  '
  echo -n 'tell_joke       '
  scfail tell_joke ""
  test_cleanup
}

test_check_simple_math(){
  : ' none -> none
  make sure hc() only accepts inputs that match "hal" and $1
  '
  local header="[04:52:07] [Server thread/INFO]: <Steve>"

  echo -n 'simple_math     '
  CLINE="$header hal what is 5 + 5"
  scpass "$(check_simple_math)" "/say [Hal] I think that's 10"
  CLINE="$header hal whats is 5 * 6"
  scpass "$(check_simple_math)" "/say [Hal] I think that's 30"
  CLINE="$header hal what's 5.5 / 6"
  scpass "$(check_simple_math)" "/say [Hal] I think that's .91666666666666666666"
  CLINE="$header hal whats (1 + 2) * 3"
  scpass "$(check_simple_math)" "/say [Hal] I think that's 9"
  CLINE="$header hal what's 5 # 6"
  scpass "$(check_simple_math)" "/say [Hal] I'm not sure..."
  CLINE="$header hal what is garbage"
  scpass "$(check_simple_math)" "/say [Hal] I'm not sure..."
  test_cleanup
}

test_hc(){
  : ' none -> none
  make sure hc() only accepts inputs that match "hal" and $1
  '
  echo -n 'hc              '
  declare -a arry=('hal blah' 'HAL blah blah' 'BLAH HAL' 'blah hAl blah')
  for CLINE in "${arry[@]}"; do
    hc 'blah'
    ocpass 
  done

  declare -a arry=('blah' 'hal herp' 'HAL' 'herp')
  for CLINE in "${arry[@]}"; do
    hc 'blah'
    ocfail 
  done
  test_cleanup
}

test_contains(){
  : ' none -> none
  make sure that contains() succeeds when $1 is present in $CLINE
  '
  echo -n 'contains        '
  declare -a arry=('hal blah' 'hal blah blah' 'blah HAL' 'blah hAl blah' 'BLAH')
  for CLINE in "${arry[@]}"; do
    contains 'blah'
    ocpass
  done

  declare -a arry=('goof' 'hal herp' 'HAL' 'herp derp')
  for CLINE in "${arry[@]}"; do
    contains 'blah'
    ocfail
  done
  test_cleanup
}

test_say(){
  : ' none -> none
  make sure say() builds "/say [Hal] <phrase>" commands correctly
  '
  echo -n 'say             '
  scpass "$(say "hello there")" '/say [Hal] hello there'
  scpass "$(say "hello there $USER")" '/say [Hal] hello there <player1>'
  scpass "$(say "")" '/say [Hal] '
  test_cleanup
}

test_tell(){
  : ' none -> none
  make sure tell() builds "/tell $USER <phrase>" commands correctly
  '
  echo -n 'tell            '
  scpass "$(tell "hello there")" "/tell $USER hello there"
  scpass "$(tell "hello $USER there wow")" "/tell $USER hello $USER there wow"
  scpass "$(tell "")" "/tell $USER "
  scpass "$(tell )" "/tell $USER "
  QUIET=1
  scpass "$(tell "hello there")" ""
  scpass "$(tell "hello $USER there wow")" ""
  test_cleanup
}

test_run(){
  : ' none -> none
  make sure run() builds "/<command>" commands correctly
  '
  echo -n 'run             '
  scpass "$(run "/hello there")" "/hello there"
  scpass "$(run "/hello $USER there wow")" "/hello $USER there wow"
  scpass "$(run "")" ""
  scpass "$(run   )" ""
  test_cleanup
}

test_not_repeat(){
  : ' none -> none
  make sure that not_repeat() returns 0 if $CLINE contains output from hal.sh
  '
  echo -n 'not_repeat      '
  declare -a arry=('[hal] blah' '[hal] BLAH ' 'blah [HAL]' 'blah [hAl] blah')
  for CLINE in "${arry[@]}"; do
    not_repeat
    ocfail 
  done

  declare -a arry=('goof' 'hal herp' 'HAL' 'herp derp')
  for CLINE in "${arry[@]}"; do
    not_repeat
    ocpass 
  done
  test_cleanup
}

test_random(){
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

test_random_okay(){
  : ' none -> none
  make sure random_okay() always returns a string
  '
  echo -n 'random_okay     '
  scfail "$(random_okay 'hello')" ''
  scfail "$(random_okay '')" ''
  test_cleanup
}

test_random_musing(){
  : ' none -> none
  make sure random_musing() always returns a string
  '
  echo -n 'random_musing   '
  scfail "$(random_okay)" ''
  test_cleanup
}

test_tell_player() {
  : ' none -> none
  make sure random_musing() always returns a string
  '
  echo -n 'tell_player     '
  test_cleanup
}

test_shut_down(){
  : ' none -> none
  make sure shut_down() reports to the users that hal.sh is shutting down
  '
  echo -n 'shut_down       '
  rcpass "$(shut_down)" "Hal shutting down"
  test_cleanup
}

test_hcsr(){
  : ' none -> none
  make sure hcsr() says $2 and runs $3 if "hal" is present in $CLINE
  '
  echo -n 'hcsr            '
  CLINE='hal whats up?'
  rcpass "$(hcsr 'whats up' 'okie doke' '/my command')" '/say [Hal] okie doke'
  rcpass "$(hcsr 'whats up' 'okie doke' '/my command')" '/my command'

  CLINE='hal WHATS UP?'
  rcpass "$(hcsr 'whats up' 'okie doke' '/my command')" '/say [Hal] okie doke'
  rcpass "$(hcsr 'whats up' 'okie doke' '/my command')" '/my command'

  CLINE='whats up hal?'
  rcpass "$(hcsr 'whats up' 'okie doke' '/my command')" '/say [Hal] okie doke'
  rcpass "$(hcsr 'whats up' 'okie doke' '/my command')" '/my command'

  CLINE='WHATS UP hal?'
  rcpass "$(hcsr 'whats up' 'okie doke' '/my command')" '/say [Hal] okie doke'
  rcpass "$(hcsr 'whats up' 'okie doke' '/my command')" '/my command'

  CLINE='herbert be quiet'
  rcfail "$(hcsr 'be quiet' 'okie doke' '/my command')" '/say [Hal] okie doke'
  rcfail "$(hcsr 'be quiet' 'okie doke' '/my command')" '/my command'
  test_cleanup
}

test_go_to_dest(){
  : ' none -> none
  make sure that go_to_dest() can handle the following cases:
    - hal take me to <dest in config>
    - take me to <dest in config> hal
    - hal take me to <player>
    - take me to <player> hal
  '
  echo -n 'go_to_dest      '
  USER='player'
  CLINE='hal take me to the telehub'
  rcpass "$(go_to_dest)" "Okay $USER, I think I know where that is."
  rcpass "$(go_to_dest)" '/tp player -108 3 98'

  CLINE='take me to the telehub hal'
  rcpass "$(go_to_dest)" "Okay $USER, I think I know where that is."
  rcpass "$(go_to_dest)" '/tp player -108 3 98'

  CLINE='HAL TAKE ME TO THE TELEHUB'
  rcpass "$(go_to_dest)" "Okay $USER, I think I know where that is."
  rcpass "$(go_to_dest)" '/tp player -108 3 98'

  CLINE='TAKE ME TO THE TELEHUB HAL'
  rcpass "$(go_to_dest)" "Okay $USER, I think I know where that is."
  rcpass "$(go_to_dest)" '/tp player -108 3 98'

  CLINE='hal go to the telehub'
  rcpass "$(go_to_dest)" "Sorry player, I don't know where that is"

  CLINE='go to the telehub hal'
  rcpass "$(go_to_dest)" "Sorry player, I don't know where that is"
  echo
  echo -n '...             '

  CLINE='hal go to blerug'
  rcpass "$(go_to_dest)" "Sorry player, I don't know where that is"

  CLINE='hal take me to Jimmy'
  rcpass "$(go_to_dest)" "Okay player, I'll try!"
  rcpass "$(go_to_dest)" "/tp player Jimmy"

  CLINE='take me to Jimmy hal'
  rcpass "$(go_to_dest)" "Okay player, I'll try!"
  rcpass "$(go_to_dest)" "/tp player Jimmy"

  CLINE='hal take me to Herp Derp'
  rcpass "$(go_to_dest)" "Okay player, I'll try!"
  rcpass "$(go_to_dest)" "/tp player Herp Derp"
  test_cleanup
}

test_go_home(){
  : ' none -> none
  '
  echo -n 'go_home         '
  local failure="Sorry $USER, either you never told me where home was or I forgot!"

  CLINE='take me home hal'
  rcpass "$(go_home)" "$failure"
  CLINE='take me home hal'
  rcpass "$(go_home)" "$failure"

  test_cleanup
}

test_set_home(){
  : ' none -> none
  '
  echo -n 'set_home        '
  local failure="Sorry $USER, something doesn't look right with those coordinates"

  CLINE='hal set home as junk'
  rcpass "$(set_home)" "$failure"
  CLINE='hal set home as junk junk'
  rcpass "$(set_home)" "$failure"
  CLINE='set home as a b c hal'
  rcpass "$(set_home)" "Okay $USER, I've set your home to be a b c!"

  test_cleanup
}

test_remember_phrase(){
  : ' none -> none
  '
  echo -n 'remember_phrase '
  local pass="Okay $USER, I'll remember!"

  CLINE='hal remember a is b'
  rcpass "$(remember_phrase)" "$pass"
  CLINE='hal remember'
  rcpass "$(remember_phrase)" "Remember what?"
  CLINE='hal remember that a is b'
  rcpass "$(remember_phrase)" "$pass"

  test_cleanup
}

test_recall_phrase(){
  : ' none -> none
  '
  echo -n 'recall_phrase   '
  test_cleanup
}

test_forget_phrase(){
  : ' none -> none
  '
  echo -n 'forget_phrase   '
  test_cleanup
}

test_check_intent(){
  : ' none -> none
  ensure that intents are triggered if the condition is met
  '
  echo -n 'check_intent    '
  CLINE='yes hal'
  scpass "$INTENT_A" ''
  set_intent 'yes\|no' 'intent_if_yes_do echo hello'
  check_intent >/dev/null
  scpass "$INTENT_A" ''

  CLINE='whatever hal'
  set_intent 'yes\|no' 'intent_if_yes_do echo hello'
  scpass "$INTENT_A" 'yes\|no%intent_if_yes_do echo hello'
  scpass "$INTENT_B" ''
  check_intent >/dev/null
  scpass "$INTENT_A" 'yes\|no%intent_if_yes_do echo hello'
  scpass "$INTENT_B" ''
  set_intent 'whatever' 'echo sure'
  scpass "$INTENT_A" 'whatever%echo sure'
  scpass "$INTENT_B" 'yes\|no%intent_if_yes_do echo hello'
  scpass "$INTENT_C" ''
  echo
  echo -n '...             '
  check_intent >/dev/null
  scpass "$INTENT_A" 'yes\|no%intent_if_yes_do echo hello'
  scpass "$INTENT_B" ''
  CLINE='yes hal'
  check_intent >/dev/null
  scpass "$INTENT_A" ''

  set_intent 'hiccup' 'echo wow'
  scpass "$INTENT_A" 'hiccup%echo wow'
  scpass "$INTENT_B" ''
  set_intent 'whatever' 'echo sure'
  scpass "$INTENT_A" 'whatever%echo sure'
  scpass "$INTENT_B" 'hiccup%echo wow'
  scpass "$INTENT_C" ''
  CLINE='hiccup hal'
  check_intent >/dev/null
  scpass "$INTENT_A" 'whatever%echo sure'
  echo
  echo -n '...             '
  scpass "$INTENT_B" ''
  CLINE='whatever hal'
  check_intent >/dev/null
  scpass "$INTENT_A" ''

  CLINE='yes hal'
  set_intent 'yes\|no' 'intent_if_yes_do echo hello'
  scpass "$(check_intent)" 'hello'
  test_cleanup
}

test_set_intent(){
  : ' none -> none
  make sure the intents can be set and are cycled correctly
  newer intents push older ones down the list, dropping the last
  if necessary
  '
  echo -n 'set_intent      '
  CLINE='yes hal'
  set_intent 'yes\|no' functionA
  scpass "$INTENT_A" 'yes\|no%functionA'
  scpass "$INTENT_B" ''

  set_intent 'yes\|no' functionB
  scpass "$INTENT_A" 'yes\|no%functionB'
  scpass "$INTENT_B" 'yes\|no%functionA'
  scpass "$INTENT_C" ''

  set_intent 'yes\|no' functionC
  scpass "$INTENT_A" 'yes\|no%functionC'
  scpass "$INTENT_B" 'yes\|no%functionB'
  scpass "$INTENT_C" 'yes\|no%functionA'

  # cycle
  set_intent 'yes\|no' functionD
  scpass "$INTENT_A" 'yes\|no%functionD'
  echo
  echo -n '...             '
  scpass "$INTENT_B" 'yes\|no%functionC'
  scpass "$INTENT_C" 'yes\|no%functionB'

  test_cleanup
}

test_clear_intent(){
  : ' none -> none
  '
  echo -n 'clear_intent      '

  test_cleanup
}

# run
#==================
test_cleanup

test_test
test_requirements

test_tell_joke
test_check_simple_math
test_random_okay
test_random_musing
test_tell_player

test_hc
test_contains
test_say
test_tell
test_run
test_not_repeat
test_random
test_shut_down
test_hcsr

test_go_to_dest
test_go_home
test_set_home

test_remember_phrase
test_recall_phrase
test_forget_phrase

test_check_intent
test_set_intent
