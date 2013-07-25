#!/bin/sh -e

# for a random tune, list multiple space-separated files
MUSIC='/home/kali/music/despertador/rockandroll.mp3'

# some days I like different music
DOW="$(date +%u)"
if [ $DOW -eq 6 -o $DOW -eq 7 ]; then
  MUSIC='/home/kali/music/despertador/rockandroll.mp3'
fi

# choose your favourite music player
#player() { mpg123 --random --quiet --control --title "$@" || true; }
player() { mplayer -loop 0 "$*"; }

# play the music at this volume
VOLUME='100%'
# ALSA mixer control used to set and restore the master volume
#VOLUMECTL='iface=MIXER,name="Master Playback Volume"'

##############################################################################
# this is more elegant, but it needs rtcwake from util-linux-ng >= 2.14.2
rtcwake_set_alarm() {
  local when="$1"
  local rtc="$2"
  if [ "$rtc" ]; then rtc="--device $rtc"; fi

  local epochtime=$(date --date "$when" +%s)
  echo $epochtime
  [ "$epochtime" ] || return 1

  #sudo rtcwake $rtc --mode no --time $epochtime
  sudo rtcwake $rtc -m mem --time $epochtime
}

# you can use this function instead if your system lacks a working rtcwake
set_alarm() {
  local when="$1"
  local rtc="$2"
  [ "$rtc" ] || rtc='rtc0'

  local epochtime=$(date --date "$when" +%s)
  [ "$epochtime" ] || return 1

  local alarmfile="/sys/class/rtc/$rtc/wakealarm"
  sudo sh -c "echo 0 > $alarmfile && echo $epochtime > $alarmfile"
}

##############################################################################
if [ "$1" ]; then
  WHEN="$1"
else
  echo "Usage: $0 WHEN"
  exit 1
fi

#set_alarm "$WHEN"
rtcwake_set_alarm "$WHEN"

# save the volume
oldvolume="$(amixer cget "$VOLUMECTL" | sed -nre '/ : /s/.*=//p')"
#amixer -q cset "$VOLUMECTL" $VOLUME
amixer set Master $VOLUME

# actually here I run a script which also deals with network interfaces,
# IM and IRC clients and so on
#sudo pm-suspend

player $MUSIC

# restore the volume
amixer set Master "$oldvolume"

exit 0
