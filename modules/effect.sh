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
  hcsr 'make me healthy' \
    "$(random_okay 'This should help you feel better')" \
    "/effect ${USER} minecraft:instant_health 1 10"

  hcsr 'make me invisible' \
    "$(random_okay 'Not even I know where you are now!')" \
    "/effect ${USER} minecraft:invisibility 60 5"

  hcsr 'make me fast' \
    "$(random_okay 'Gotta go fast!')" \
    "/effect ${USER} minecraft:speed 60 5"
}
