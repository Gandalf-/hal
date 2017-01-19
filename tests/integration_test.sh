#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux
#   author  : leaf@anardil.net
#   license : See LICENSE file

# integration_test.sh

source "./test_framework.sh"

source "../modules/utility.sh"
source "../modules/memories.sh"
source "../modules/chatting.sh"
source "../modules/teleport.sh"
source "../modules/intent.sh"

# tests
#==================

# run
#==================
test_test
