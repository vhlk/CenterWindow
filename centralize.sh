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

WINDOW_FRAME_EXTENTS=$(xprop _NET_FRAME_EXTENTS -id $CUR_WINDOW_PID)
if [[ $WINDOW_FRAME_EXTENTS =~ "not found" ]]
then
  echo "_NET_FRAME_EXTENTS not found (this is ok)."
else
  FRAME_EXTENTS=($(echo $WINDOW_FRAME_EXTENTS | cut -d '=' -f2 | tr ',' ' '))

  LEFT=${FRAME_EXTENTS[0]}
  RIGHT=${FRAME_EXTENTS[1]}
  TOP=${FRAME_EXTENTS[2]}
  BOTTOM=${FRAME_EXTENTS[3]}


  CUR_WINDOW_GEOM_H=$(( CUR_WINDOW_GEOM_H + TOP + BOTTOM ))
  CUR_WINDOW_GEOM_W=$(( CUR_WINDOW_GEOM_W + LEFT + RIGHT ))
  
  echo "_NET_FRAME_EXTENTS found (Left: $LEFT, Top: $TOP, Right: $RIGHT, Bottom: $BOTTOM)." "Actual window size: $CUR_WINDOW_GEOM_W x $CUR_WINDOW_GEOM_H"
fi

# get current working screen info
WIN_DESKTOP_W_DIMS=$(xprop -root _NET_WORKAREA | grep -Eo '[0-9]+')

WIN_DESKTOP_W_TOP_LEFT_X=$(echo $WIN_DESKTOP_W_DIMS | cut -d " " -f1)
WIN_DESKTOP_W_TOP_LEFT_Y=$(echo $WIN_DESKTOP_W_DIMS | cut -d " " -f2)

WIN_DESTOP_W_W=$(echo $WIN_DESKTOP_W_DIMS | cut -d " " -f3)
WIN_DESTOP_W_H=$(echo $WIN_DESKTOP_W_DIMS | cut -d " " -f4)

echo "Working screen size: " $WIN_DESTOP_W_W "x" $WIN_DESTOP_W_H "[Top left:" "("$WIN_DESKTOP_W_TOP_LEFT_X"," $WIN_DESKTOP_W_TOP_LEFT_Y")]"

# get middle of the screen
MIDDLE_X=$(( ((WIN_DESTOP_W_W - CUR_WINDOW_GEOM_W)/2) + WIN_DESKTOP_W_TOP_LEFT_X ))
MIDDLE_Y=$(( ((WIN_DESTOP_W_H - CUR_WINDOW_GEOM_H)/2) + WIN_DESKTOP_W_TOP_LEFT_Y ))

echo "Middle coords:" "("$MIDDLE_X"," $MIDDLE_Y")"

xdotool getactivewindow windowmove "$MIDDLE_X" "$MIDDLE_Y"
