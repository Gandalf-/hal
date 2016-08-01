# Hal
Minecraft AI in Shell

[![Build
Status](https://travis-ci.org/Gandalf-/hal.svg?branch=master)](https://travis-ci.org/Gandalf-/hal)

## Description
- Hal is a lightweight AI for Minecraft servers. He is intended to make running a server more fun!

### Example
```
  <player> Hey Hal! Can you make it day and make it clear?
  [Server] [Hal] Hello there player!
  [Server] [Hal] Sure thing!
  Hal runs /time set day
  [Server] [Hal] As you wish!
  Hal runs /weather set clear
  <player> show help Hal
  [Server] [Hal] I'm Hal, a teenie tiny AI that will try to help you!
  [Server] [Hal] Here are somethings I understand:
  [Server] [Hal] - hello, hey, how are you, what's up, tell a joke
  [Server] [Hal] - thanks, yes, no, whatever
  [Server] [Hal] - help, restart, be quiet, you can talk, status update
  [Server] [Hal] - make it (day, night, clear, rainy)
  [Server] [Hal] - make me (healthy, invisible, fast)
  [Server] [Hal] - take me to (the telehub, <player>)
  [Server] [Hal] - take me home, set home as <x> <y> <z>
  [Server] [Hal] - (remember, recall, forget) <phrase>
  [Server] [Hal] - put me in (creative, survival, spectator) mode
```

## Setup
- **Requirements**: `tmux`, `bash`, `inotify-tools`, `git`, Linux Minecraft server
- Clone this repository: `git clone https://github.com/Gandalf-/hal.git`
- Run `make install` in the new hal directory
- Check out `~/.halrc` to make sure it reflects your system configuration
- Run minecraft server in a `tmux` pane named 'minecraft' (case sensitive)
- Run `~/hal.sh` from a different pane in tmux
- Done!

Tmux Quick Reference: https://gist.github.com/afair/3489752
