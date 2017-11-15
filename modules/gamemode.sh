#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux
#   author  : leaf@anardil.net
#   license : See LICENSE file

# gamemode.sh

hal_check_gamemode_actions(){
  # none -> none
  #
  # gamemode modifing actions

  case "$CLINE" in
    *'put me in survival mode')
      say "$( random_okay 'Remember to eat!' )"
      run "/gamemode surival $USER"
      ran_command
      ;;

    *'put me in creative mode'*)
      say "$(random_okay)"
      run "/gamemode creative $USER"
      ran_command
      ;;

    *'put me in spectator mode'*)
      say "$(random_okay)"
      run "/gamemode spectator $USER"
      ran_command
      ;;
  esac
}
