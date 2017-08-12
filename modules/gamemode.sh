#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux
#   author  : leaf@anardil.net
#   license : See LICENSE file

# gamemode.sh

hal_check_gamemode_actions(){
  # : ' none -> none
  # gamemode modifing actions
  # '
  hcsr 'put me in survival mode' \
    "$(random_okay 'Remember to eat!')" \
    "/gamemode surival ${USER}"

  hcsr 'put me in creative mode' \
    "$(random_okay)" \
    "/gamemode creative ${USER}"

  hcsr 'put me in spectator mode' \
    "$(random_okay)" \
    "/gamemode spectator ${USER}"
}

