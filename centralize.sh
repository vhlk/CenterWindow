#!/bin/bash

command_available () {
   if ! command -V $1 &> /dev/null
   then
   	echo "Command $1 not found!"
   	echo "Quitting..."
   	exit -1
   fi
}

# check dependencies

command_available xdotool
command_available xdpyinfo

# get window infos

CUR_WINDOW_PID=$(xdotool getactivewindow)

CUR_WINDOW_GEOM=$(xdotool getwindowgeometry $CUR_WINDOW_PID | grep -o '[0-9]*x[0-9]*')
CUR_WINDOW_GEOM_H=$(cut -d "x" -f2 <<< $CUR_WINDOW_GEOM)
CUR_WINDOW_GEOM_W=$(cut -d "x" -f1 <<< $CUR_WINDOW_GEOM)

echo "Window size: " $CUR_WINDOW_GEOM_W "x" $CUR_WINDOW_GEOM_H

# get current screen info
WIN_DESKTOP_DIMS=$(xdpyinfo | grep dimensions | grep -o '[0-9x]*' | head -n1)
WIN_DESTOP_H=$(cut -d "x" -f2 <<< $WIN_DESKTOP_DIMS)
WIN_DESTOP_W=$(cut -d "x" -f1 <<< $WIN_DESKTOP_DIMS)

echo "Screen size: " $WIN_DESTOP_W "x" $WIN_DESTOP_H

# get middle of the screen
MIDDLE_X=$((WIN_DESTOP_W/2 - CUR_WINDOW_GEOM_W/2))
MIDDLE_Y=$((WIN_DESTOP_H/2 - CUR_WINDOW_GEOM_H/2))

xdotool getactivewindow windowmove "$MIDDLE_X" "$MIDDLE_Y"
