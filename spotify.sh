#!/bin/bash

SP_DEST="org.mpris.MediaPlayer2.spotify"
SP_PATH="/org/mpris/MediaPlayer2"
SP_MEMB="org.mpris.MediaPlayer2.Player"

function spotifyInfo() {
  dbus-send                                       \
  --print-reply                                   \
  --dest=$SP_DEST                                 \
  $SP_PATH                                        \
  org.freedesktop.DBus.Properties.Get             \
  string:"$SP_MEMB" string:'Metadata'             \
  | grep -Ev "^method"                            \
  | grep -Eo '("(.*)")|(\b[0-9][a-zA-Z0-9.]*\b)'  \
  | sed -E '2~2 a|'                               \
  | tr -d '\n'                                    \
  | sed -E 's/\|/\n/g'                            \
  | sed -E 's/(xesam:)|(mpris:)//'                \
  | sed -E 's/^"//'                               \
  | sed -E 's/"$//'                               \
  | sed -E 's/"+/|/'                              \
  | sed -E 's/ +/ /g'                             \
  | sed -E 's/\|/\:\t/g'                          \
  | sed -E 's/trackNumber\:/track\:/g'            \
  | sed -E 's/autoRating\:/rating\:/g'            \
  | sed -E 's/discNumber\:/disc\:/g'              \
  | grep -Ev "^albumArtist\:"                     \
  | grep -Ev "^length\:"                          \
  | grep -Ev "^trackid\:"
}

function spotifyAction() {
dbus-send \
  --print-reply \
  --dest=$SP_DEST \
  $SP_PATH \
  "$SP_MEMB.$1" > /dev/null 2>&1
}

function printHelp() {
  echo "Usage: $0 [command]"
  echo "Available commands:"
  echo -e "\tWho"
  echo -e "\tPlay"
  echo -e "\tPause"
  echo -e "\tPlayPause"
  echo -e "\tPrevious"
  echo -e "\tNext"
}

[ -z "$1" ] && printHelp && exit 1

spotifyCommand="$1"
spotifyCommand="$(tr '[:lower:]' '[:upper:]' <<< ${spotifyCommand:0:1})${spotifyCommand:1}"

if [ "Who" != "$spotifyCommand" ]; then
  spotifyAction "$spotifyCommand"
fi

spotifyInfo