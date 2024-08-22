#!/bin/bash

MIDDLE_X=$(( ((CURR_SCREEN_GEOM_W - CUR_WINDOW_GEOM_W)/2) ))
MIDDLE_Y=$(( ((CURR_SCREEN_GEOM_H - CUR_WINDOW_GEOM_H)/2) ))

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