# hal
Minecraft AI in Shell
- Usage: bash hal.sh */full/path/to/logs/latest.log*

## Description
- Hal is a lightweight AI for Minecraft servers intended to make running a server more fun and allow easier access to the functionality of the command line without having to remember the syntax.

### Example
- \<player\> hey Hal! Can you make it day?
- [Server] [Hal] Hello there player!
- [Server] [Hal] Sure thing!
- Hal runs */time set day*

## Setup
- **Requirements**: tmux, bash, inotify-tools, Minecraft server
- Run minecraft server in a tmux pane named 'minecraft' (case sensitive)
- Modify line 4 of hal.sh to contain the full path of your minecraft latest.log file
- Run hal.sh from a different pane in tmux
- Done!

## Functionality
- Chat with players
- Control the weather
- Apply status effects
- Teleport players
