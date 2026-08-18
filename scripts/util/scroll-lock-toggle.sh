#!/usr/bin/bash

pidfile=/tmp/scroll-lock/process.pid
#slk=$(printf '%s\n' /sys/class/leds/input*::scrolllock/brightness | head -n 1)

#if [[ $(<"$slk") == 1 ]]; then
if [[ -f "$pidfile" ]]; then
    # OFF
    sudo /usr/local/sbin/scroll-lock off

    #if [[ -f "$pidfile" ]]; then
        pid=$(cat "$pidfile")
        kill "$pid" 2>/dev/null
        rm -f "$pidfile"
    #fi

else

    # ON
    sudo /usr/local/sbin/scroll-lock on

    /home/aragorn/Data/Celephais/rhe-cli/scripts/music/aleatoric.pl &
    echo $! > "$pidfile"

fi
