#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux
#   author  : leaf@anardil.net
#   license : See LICENSE file

# weather.sh

hal_check_weather_actions(){
  # : ' none -> none
  # weather modifing actions
  # '
  hcsr 'make it clear' \
    "$(random_okay 'Rain clouds begone!')" \
    "/weather clear 600"

  hcsr 'make it sunny' \
    "$(random_okay 'Rain clouds begone!')" \
    "/weather clear 600"

  hcsr 'make it rainy' \
    "$(random_okay 'Rain clouds inbound!')" \
    "/weather rain 600"

  hcsr 'make it day' \
    "$(random_okay 'Sunshine on the way!')" \
    "/time set day"

  hcsr 'make it night' \
    "$(random_okay 'Be careful!')" \
    "/time set night"
}
