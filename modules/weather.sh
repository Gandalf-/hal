#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux
#   author  : leaf@anardil.net
#   license : See LICENSE file

# weather.sh

hal_check_weather_actions(){
  # none -> none
  #
  # weather modifing actions

  case "$CLINE" in
    *'make it clear'*|*'clear weather'*)
      say "$(random_okay 'Rain clouds begone!')"
      run "/weather clear 600"
      ran_command
      ;;

    *'make it sunny'*)
      say "$(random_okay 'Sunshine on the way!')"
      run "/time set day"
      run "/weather clear 600"
      ran_command
      ;;

    *'make it rainy'*|*'rainy weather'*)
      say "$(random_okay 'Rain clouds inbound!')"
      run "/weather rain 600"
      ran_command
      ;;

    *'make it day'*|*'let there be light'*)
      say "$(random_okay 'Sunshine on the way!')"
      run "/time set day"
      ran_command
      ;;

    *'make it night'*|*'let there be dark'*)
      say "$(random_okay 'Be careful!')"
      run "/time set night"
      ran_command
      ;;
  esac
}

