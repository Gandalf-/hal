# Hal
Minecraft AI in Shell

## Description
- Hal is a lightweight AI for Minecraft servers. He is intended to make running a server more fun and allow easier access to the functionality of the command line 

### Example
- \<player\> hey Hal! Can you make it day?
- [Server] [Hal] Hello there player!
- [Server] [Hal] Sure thing!
- Hal runs */time set day*
- \<player\> show help Hal
- [Server] [Hal] I'm Hal, a teenie tiny AI that will try to help you!
- [Server] [Hal] Here are somethings I understand:
- [Server] [Hal] - hello, hey, how are you, what's up
- [Server] [Hal] - thanks, yes, no, whatever
- [Server] [Hal] - help, restart, be quiet, you can talk, status update
- [Server] [Hal] - make it (day, night, clear, rainy)
- [Server] [Hal] - make me (healthy, invisible, fast)
- [Server] [Hal] - take me (to the telehub, home)
- [Server] [Hal] - set home as <x> <y> <z>
- [Server] [Hal] - put me in (creative, survival, spectator) mode

## Setup
- **Requirements**: tmux, bash, inotify-tools, Minecraft server
- Run minecraft server in a tmux pane named 'minecraft' (case sensitive)
- Modify line 4 of hal.sh to contain the full path of your minecraft latest.log file
- Run hal.sh from a different pane in tmux
- Done!

- Tmux Quick Reference: https://gist.github.com/afair/3489752
