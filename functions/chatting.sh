#!/bin/bash

# Hal: Minecraft AI in Shell
#   requires: bash, tmux, inotify-tools
#   author  : leaf@anardil.net
#   license : See LICENSE file

# chatting.sh

check_chatting_actions(){
  : ' none -> none
  chatting actions
  '
  if hc 'how are you'; then
    local adverb=$(random "fairly" "quite" "extremely" "modestly" "adequately")
    local adjective=$(random "swell" "groovy" "superb" "fine" "awesome" "peachy")
    local label=$(random "millennium" "years" "days" "hours" "seconds" "milliseconds" "nanoseconds")
    local time="scale=6; $LIFETIME"

    case "$label" in
      "millennium")
        time=$(bc -l <<< "$time / 60 / 24 / 365 / 1000")
        ;;
      "years")
        time=$(bc -l <<< "$time / 60 / 24 / 365")
        ;;
      "days")
        time=$(bc -l <<< "$time / 60 / 24")
        ;;
      "hours")
        time=$(bc -l <<< "$time / 60")
        ;;
      "seconds")
        time=$(bc -l <<< "$time * 1")
        ;;
      "milliseconds")
        time=$(bc -l <<< "$time * 100")
        ;;
      "nanoseconds")
        time=$(bc -l <<< "$time * 1000000000")
        ;;
    esac

    say "I'm feeling $adverb $adjective! I've been alive for $time $label"
    RCOMMAND=0
  fi

  if hc 'tell .* joke'; then 
    tell_joke

  elif hc 'tell .* about everything'; then
    recall_everything

  elif hc 'tell .* about .*'; then
    recall_phrase

  elif hc 'tell '; then 
    tell_player
  fi

  hcsr 'hello hal'    "Hey there $USER!"
  hcsr 'hey hal'      "Hello there $USER!"
  hcsr 'hi hal'       "Howdy $USER!"
  hcsr 'sup hal'      "Yo, what's good $USER?"
  hcsr 'yes hal'      'Ah... okay'
  hcsr 'no hal'       'Oh... okay'
  hcsr 'whatever hal' 'Well. If you say so'
  hcsr 'thanks hal'   "You're quite welcome $USER!"

  hcsr 'turn down for what' "Nothing! Order another round of shots!"

  local comment="$(random 'holding the world together' 'hanging out' 'mind controlling a squid' 'contemplating the universe')"
  hcsr "what's up" "Not too much $USER! Just $comment"
  hcsr "whats up" "Not too much $USER! Just $comment"

  if hc 'what do you know about'; then
    # search the internet?
    if contains 'zombie'; then
      say "They're wannabe Frankensteins as far as I can tell!"

    elif contains 'skeleton'; then
      say "They're spooky! Watch out for arrows!"

    elif contains 'spider'; then
      say "Too many legs for my sensibilities"

    else 
      recall_phrase
    fi
    RCOMMAND=0
  fi

  if test "$RCOMMAND" != 0; then
    check_simple_math
  fi
}

check_simple_math(){
  : ' none -> none
  simple math solutions of the form
  hal what is (expr)
  '
  local base_regex="[\(\)0-9\+\/\*\.\^\%]*"
  local regex="$base_regex\|-$base_regex"

  if hc "what's\|whats\|what is"; then
    if contains "$regex"; then

      local exp="$(cut -d' ' -f5- <<< "$CLINE" | grep -io "$regex" | xargs)"
      local value="$(timeout 1 bc -l 2>/dev/null <<< "$exp")"

      if test "$value" != ""; then
        say "I think that's $value"
      else
        say "I'm not sure..."
      fi
    else
      say "I'm not sure..."
    fi

    RCOMMAND=0
  fi
}

random_chat(){
  : 'string -> string
  requires a file with word : word %, word %, ...
  '
}

random_okay(){
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

tell_player(){
  : ' none -> none
  attempts to tell a player a message, if the player isnt in the game,
  store it until the log in again
  '
  local player="$(echo "$CLINE" | cut -f 7 -d' ')"
  local regex='s/[;\|{}'"'"'"&$()]/\\&/g'
  local msg="$(echo "$CLINE" | cut -f 8- -d' ' | sed -e "$regex" )"

  if test "$player" != "" || test "$msg" != ""; then
    set_intent 'cannot' "intent_tell_player $USER $player $msg"
    say "Sure thing $USER!"
    run "/tell $player $msg"
    RCOMMAND=0
  fi
}

random_musing(){
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

tell_joke(){
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
  'Why cant the Ender Dragon read a book? Because he always starts at the End.' \
  'Why dont blazes ever make businesses?  They keep firing people! ' \
  'What is the national sport of Minecraft?  Boxing.' \
  'What did Steve say to his girlfriend?  I dig you.' \
  'What kind of parties do Minecraft players have?  Block parties. ' \
  'A creeper walks into a bar. Everyone dies.' \
  'When I saw the guy with a potion I knew there was trouble brewing.' \
  'Id tell you a joke about the end, but it will just dragon.' \
  'How do you make people change direction in Minecraft? You Block their path.' \
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
