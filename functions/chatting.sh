#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux, inotify-tools
#   author  : leaf@anardil.net
#   license : See LICENSE file

# chatting.sh

function random_chat(){
  : 'string -> string
  requires a file with word : word %, word %, ...
  '

  : '
  attempts to match the current line to an output
  recursively calls itself on all subsets of the input until a match is found

  hey there hal whats up
    there hal whats up
      hal whats up
        whats up
          whats
          up
        hal whats
          hal
          whats
      there hal whats
        hal whats
          hal
          whats
        there hal
          there
          hal
    hey there hal whats
      there hal whats
      hey there hal

  if RC_FOUND=0 && no_match
    random_chat currline - first_word
    random_chat currline - last_word
  else
    RC_FOUND=1
    say match
  '
}

function random_okay(){
  : ' string -> string
  returns a random affirmative
  '
  if test "$1" == ''; then
    random \
      'Okay!' 'Sure!' 'You got it!' 'Why not!' 'As you wish!' 'Done!'
  else
    random \
      "$1" 'Okay!' 'Sure!' 'You got it!' 'Why not!' 'As you wish!' 'Done!'
  fi
}

function tell_player(){
  : ' none -> none
  attempts to tell a player a message, if the player isnt in the game,
  store it until the log in again
  '
  player="$(echo "$CLINE" | cut -f 7 -d ' ')"
  message="$(echo "$CLINE" | cut -f 8- -d ' ' | sed -e 's/[;\|{}'"'"'"&$()]/\\&/g')"
  if test "$player" != "" || test "$message" != ""; then
    set_intent 'cannot' "intent_tell_player $USER $player $message"
    say "Sure thing $USER!"
    run "/tell $player $message"
    RCOMMAND=0
  fi
}

function random_musing(){
  : ' none -> string
  returns a random musing
  '
  random \
    'Hmm... I wonder...' 'All systems normal...' 'Counting sheep...' \
    'Just growing some trees...' 'Reorganizing clouds...' \
    'Turning dirt to grass...' 'Mind controlling a squid...' \
    'Hiding diamonds...' 'Looking for lost cows...' \
    'Did you know about overviewer.anardil.net?'
}

function tell_joke(){
  : ' none -> none
  tell a random joke
  '
  say "$(random \
  'How does Steve get his exercise?  He runs around the block. ' \
  'Have you heard of the creeper that went to a party?  He had a BLAST!' \
  'Whats a ghasts favorite country?  The Nether-Lands!' \
  'Why did the Creeper cross the road?  To get to the other Sssssssside!' \
  'Why did the sailor bring iron and gold into his boat?  He needed oars.' \
  'If there will ever be a Minecraft movie, then it would be a blockbuster.' \
  'Why cant the Ender Dragon read a book?  Because he always starts at the End.' \
  'Why dont blazes ever make businesses?  They keep firing people! ' \
  'What is the national sport of Minecraft?  Boxing.' \
  'What did Steve say to his girlfriend?  I dig you.' \
  'What kind of parties do Minecraft players have?  Block parties. ' \
  'A creeper walks into a bar. Everyone dies.' \
  'When I saw the guy with a potion I knew there was trouble brewing.' \
  'Id tell you a joke about the end, but it will just dragon.' \
  'How do you make people change direction in Minecraft?  You Block their path.' \
  'Why would a mushroom make a good roommate?  Its a real fungi.' \
  'Whats Cobblestones favorite music?  Rock music.' \
  'What did the chicken say to the cow? Pleased to meat you.' \
  'What did the chicken say to the sheep? Pleased to meet ewe.' \
  'What did the chicken say to the ocean? Nothing, it just waved.' \
  'Did you hear about the murder of the snow golem?  It became a cold case.' \
  'What do you get if you push a music box down a mineshaft?  A flat minor.' \
  'How does Herobrine spy on people?  He uses spy-ders.' \
  'Endermen scare people out if their mines.' \
  'After I took the wool off a sheep, it told me, Sheariously?' \
  'Why did the creeper cross the road?  There was an ocelot chasing him.' \
  'What did the minecraft turkey say?  cobble, cobble, cobble! ' \
  'Whats so good about cobblestone?  Its Hand-PICKED.' \
  'What is a creepers favorite subject?  HisssSSSSStory' \
  'I heard Minecraft Steve isnt very good at thinking outside of the box.' \
  'Why couldnt the minecraft player go to the bar?  Because he was a miner.' \
  'An Insult:  Your IQ is lower than bedrock.' \
  'How good is Minecraft?  Top-Notch!' \
  'Why did the enderman cross the road?  He didnt, he Teleported.' \
  'Whats an endermans favourite band?  Imagine Dragons!' \
  'How does Steve chop down trees with his fists?  How wood I know?' \
  'What is a pigmans favorite cereal?  Golden nuggets.')"
  RCOMMAND=0
}
