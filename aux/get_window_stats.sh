#!/bin/bash

# creates variables CUR_WINDOW_PID, CUR_WINDOW_GEOM_H, CUR_WINDOW_GEOM_W, CUR_WINDOW_POS_X, CUR_WINDOW_POS_Y, 
# FRAME_EXTENTS_LEFT, FRAME_EXTENTS_RIGHT, FRAME_EXTENTS_TOP, FRAME_EXTENTS_BOTTOM

CUR_WINDOW_PID=$(xdotool getactivewindow)

CUR_WINDOW_GEOM=$(xdotool getwindowgeometry "$CUR_WINDOW_PID" | grep -o '[0-9]*x[0-9]*')
CUR_WINDOW_GEOM_H=$(cut -d "x" -f2 <<< $CUR_WINDOW_GEOM)
CUR_WINDOW_GEOM_W=$(cut -d "x" -f1 <<< $CUR_WINDOW_GEOM)

echo "Window size: $CUR_WINDOW_GEOM_W x $CUR_WINDOW_GEOM_H"

CUR_WINDOW_POS_X=$(xwininfo -id "$CUR_WINDOW_PID" | grep 'Absolute upper-left X:' | grep -Eo '[-]*[0-9]+')
CUR_WINDOW_POS_Y=$(xwininfo -id "$CUR_WINDOW_PID" | grep 'Absolute upper-left Y:' | grep -Eo '[-]*[0-9]+')

echo "Window pos: ($CUR_WINDOW_POS_X, $CUR_WINDOW_POS_Y)"

WINDOW_FRAME_EXTENTS=$(xprop _NET_FRAME_EXTENTS -id $CUR_WINDOW_PID)
if [[ $WINDOW_FRAME_EXTENTS =~ "not found" ]]
then
  echo "_NET_FRAME_EXTENTS not found (this is ok)."
else
  FRAME_EXTENTS=($(echo $WINDOW_FRAME_EXTENTS | cut -d '=' -f2 | tr ',' ' '))

  FRAME_EXTENTS_LEFT=${FRAME_EXTENTS[0]}
  FRAME_EXTENTS_RIGHT=${FRAME_EXTENTS[1]}
  FRAME_EXTENTS_TOP=${FRAME_EXTENTS[2]}
  FRAME_EXTENTS_BOTTOM=${FRAME_EXTENTS[3]}

  CUR_WINDOW_POS_X=$(( CUR_WINDOW_POS_X - FRAME_EXTENTS_LEFT ))
  CUR_WINDOW_POS_Y=$(( CUR_WINDOW_POS_Y - FRAME_EXTENTS_TOP ))
  
  echo -e "_NET_FRAME_EXTENTS found" \
      "(Left: $FRAME_EXTENTS_LEFT, Top: $FRAME_EXTENTS_TOP, Right: $FRAME_EXTENTS_RIGHT, Bottom: $FRAME_EXTENTS_BOTTOM)\n" \
      "   -> Actual window pos: ($CUR_WINDOW_POS_X, $CUR_WINDOW_POS_Y)"
fi