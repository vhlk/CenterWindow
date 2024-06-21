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

# get current working screen info
WIN_DESKTOP_W_DIMS=$(xprop -root _NET_WORKAREA | grep -Eo '[0-9]+')

WIN_DESKTOP_W_TOP_LEFT_X=$(echo $WIN_DESKTOP_W_DIMS | cut -d " " -f1)
WIN_DESKTOP_W_TOP_LEFT_Y=$(echo $WIN_DESKTOP_W_DIMS | cut -d " " -f2)

WIN_DESTOP_W_W=$(echo $WIN_DESKTOP_W_DIMS | cut -d " " -f3)
WIN_DESTOP_W_H=$(echo $WIN_DESKTOP_W_DIMS | cut -d " " -f4)

echo "Working screen size: " $WIN_DESTOP_W_W "x" $WIN_DESTOP_W_H "[Top left:" "("$WIN_DESKTOP_W_TOP_LEFT_X"," $WIN_DESKTOP_W_TOP_LEFT_Y")]"

# corrections
HORIZONTAL_CORRECTION=0
if (( WIN_DESTOP_W != WIN_DESTOP_W_W ))
then
   # if there is a bar at the left
   HORIZONTAL_CORRECTION=$(( HORIZONTAL_CORRECTION + (WIN_DESKTOP_W_TOP_LEFT_X / 2) ))

   # if there is a bar at the right
   HORIZONTAL_CORRECTION=$(( HORIZONTAL_CORRECTION - (WIN_DESTOP_W - WIN_DESTOP_W_W - WIN_DESKTOP_W_TOP_LEFT_X)/2 ))
fi

VERTICAL_CORRECTION=0
if (( WIN_DESTOP_H != WIN_DESTOP_W_H ))
then
   # if there is a bar at the top
   VERTICAL_CORRECTION=$(( VERTICAL_CORRECTION + (WIN_DESKTOP_W_TOP_LEFT_Y / 2) ))

   # if there is a bar at the bottom
   VERTICAL_CORRECTION=$(( VERTICAL_CORRECTION - (WIN_DESTOP_H - WIN_DESTOP_W_H - WIN_DESKTOP_W_TOP_LEFT_Y)/2 ))
fi

echo "Horizontal correction:" $HORIZONTAL_CORRECTION
echo "Vertical correction:" $VERTICAL_CORRECTION

# get middle of the screen
MIDDLE_X=$(( ((WIN_DESTOP_W - CUR_WINDOW_GEOM_W)/2) + HORIZONTAL_CORRECTION ))
MIDDLE_Y=$(( ((WIN_DESTOP_H - CUR_WINDOW_GEOM_H)/2) + VERTICAL_CORRECTION ))

echo "Middle coords:" "("$MIDDLE_X"," $MIDDLE_Y")"

xdotool getactivewindow windowmove "$MIDDLE_X" "$MIDDLE_Y"
