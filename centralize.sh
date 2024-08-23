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
command_available xprop
command_available xwininfo
command_available wmctrl

# command line options
print_help() {
  echo "CenterWindow! Just a small bash script for centering window in X11."
  echo "Usage: ./centralize.sh [-h] [-v]"
}

# tools that can help: xdotool, wmctrl, xwininfo, xprop

ONLY_HORIZONTAL=false
ONLY_VERTICAL=false

while getopts ":hv" opt
do
  case $opt in
   h)
    echo "Horizontal enabled"
    ONLY_HORIZONTAL=true
    ;;
   v)
    echo "Vertical enabled"
    ONLY_VERTICAL=true
    ;;
   ?)
    print_help
    echo
    echo "Wrong option: ${OPTARG}"
    echo "Quitting..."
   	exit -1
    ;;
  esac
done


CENTER_H=true
CENTER_V=true

if [ "$ONLY_HORIZONTAL" != "$ONLY_VERTICAL" ]
then
 if [ "$ONLY_HORIZONTAL" = true ]
 then
  CENTER_V=false
 fi
 
 if [ "$ONLY_VERTICAL" = true ]
 then
  CENTER_H=false
 fi
fi

echo "Center vertically = $CENTER_V. Center horizontally: $CENTER_H."

CURR_FILE_LOCATION=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# so that we can run the other scripts
(cd "$CURR_FILE_LOCATION/aux"; chmod +x *)

# get window infos
. "$CURR_FILE_LOCATION/aux/get_window_stats.sh" # CUR_WINDOW_PID, CUR_WINDOW_GEOM_H, CUR_WINDOW_GEOM_W, CUR_WINDOW_POS_X, CUR_WINDOW_POS_Y, 
#                                                   FRAME_EXTENTS_LEFT, FRAME_EXTENTS_RIGHT, FRAME_EXTENTS_TOP, FRAME_EXTENTS_BOTTOM

# get current working screen info
. "$CURR_FILE_LOCATION/aux/get_curr_screen_stats.sh" # CUR_WINDOW_PID, CURR_SCREEN_GEOM_W, CURR_SCREEN_GEOM_H, CURR_SCREEN_POS_X, CURR_SCREEN_POS_Y

# get middle of the screen
. "$CURR_FILE_LOCATION/aux/set_middle_screen_coords.sh"