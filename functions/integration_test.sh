#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux, inotify-tools
#   author  : leaf@anardil.net
#   license : See LICENSE file

# integration_test.sh

source "./test_framework.sh"

source "./utility.sh"
source "./memories.sh"
source "./chatting.sh"
source "./teleport.sh"

# tests
#==================

# run
#==================
test_test
