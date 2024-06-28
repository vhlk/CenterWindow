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

# command line options
print_help() {
  echo "CenterWindow! Just a small bash script for centering window in X11."
  echo "Usage: ./centralize.sh [-h] [-v]"
}

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

# get window infos

CUR_WINDOW_PID=$(xdotool getactivewindow)

CUR_WINDOW_GEOM=$(xdotool getwindowgeometry $CUR_WINDOW_PID | grep -o '[0-9]*x[0-9]*')
CUR_WINDOW_GEOM_H=$(cut -d "x" -f2 <<< $CUR_WINDOW_GEOM)
CUR_WINDOW_GEOM_W=$(cut -d "x" -f1 <<< $CUR_WINDOW_GEOM)

echo "Window size: " $CUR_WINDOW_GEOM_W "x" $CUR_WINDOW_GEOM_H

CUR_WINDOW_POS=$(xdotool getwindowgeometry $(xdotool getactivewindow) | grep Position | grep -Eo "[0-9]+,[0-9]+")
CUR_WINDOW_POS_X=$(echo $CUR_WINDOW_POS | cut -d "," -f1)
CUR_WINDOW_POS_Y=$(echo $CUR_WINDOW_POS | cut -d "," -f2)

echo "Window pos: ($CUR_WINDOW_POS_X, $CUR_WINDOW_GEOM_H)"

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

COORDS=($CUR_WINDOW_POS_X $CUR_WINDOW_POS_Y)

if [ "$CENTER_H" = true ]
then
  COORDS[0]=$MIDDLE_X
fi

if [ "$CENTER_V" = true ]
then
  COORDS[1]=$MIDDLE_Y
fi

echo "Setting coords: (${COORDS[@]})"

xdotool getactivewindow windowmove "${COORDS[0]}" "${COORDS[1]}"
