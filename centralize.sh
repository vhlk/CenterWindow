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

# get list of monitors
bash aux/check_monitors.sh

# get window infos
. ./aux/get_window_stats.sh # CUR_WINDOW_PID, CUR_WINDOW_GEOM_H, CUR_WINDOW_GEOM_W, CUR_WINDOW_POS_X, CUR_WINDOW_POS_Y

# get current working screen info
. ./aux/get_working_area.sh # DESTOP_WA_W, DESTOP_WA_H, DESKTOP_WA_TOP_LEFT_X, DESKTOP_WA_TOP_LEFT_Y
. ./aux/get_curr_screen_size.sh # CUR_WINDOW_PID, CURR_SCREEN_GEOM_W, CURR_SCREEN_GEOM_H

# get middle of the screen
. ./aux/set_middle_screen_coords.sh