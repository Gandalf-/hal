#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux
#   author  : leaf@anardil.net
#   license : See LICENSE file

# effect.sh

hal_check_effect_actions(){
  # : ' none -> none
  # player effect modifing actions
  # '
  case "$CLINE" in
    *'make me healthy'*|*'heal me'*|*'save me'*)
      say "$(random_okay 'This should help you feel better')"
      run "/effect ${USER} minecraft:instant_health 1 10"
      ran_command
      ;;

    *'make me invisible'*|*'hide me'*)
      say "$(random_okay 'Not even I know where you are now!')"
      run "/effect ${USER} minecraft:invisibility 60 5"
      ran_command
      ;;

    *'make me fast'*)
      say "$(random_okay 'Gotta go fast!')"
      run "/effect ${USER} minecraft:speed 60 5"
      ran_command
      ;;
  esac
}

