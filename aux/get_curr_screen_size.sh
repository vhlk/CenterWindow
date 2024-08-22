#!/bin/bash

# creates variables CUR_WINDOW_PID, CURR_SCREEN_GEOM_W, CURR_SCREEN_GEOM_H

CUR_WINDOW_PID=$(xdotool getactivewindow)

get_screen_geom () {
    CURR_SCREEN_GEOM=$(xdotool getwindowgeometry "$CUR_WINDOW_PID" | grep -o '[0-9]*x[0-9]*')
    CURR_SCREEN_GEOM_H=$(cut -d "x" -f2 <<< $CURR_SCREEN_GEOM)
    CURR_SCREEN_GEOM_W=$(cut -d "x" -f1 <<< $CURR_SCREEN_GEOM)

    echo "Current screen window size: $CURR_SCREEN_GEOM_W x $CURR_SCREEN_GEOM_H"
}

NET_WM_STATE=$(xprop _NET_WM_STATE -id $CUR_WINDOW_PID)
if [[ "$NET_WM_STATE" != *"_NET_WM_STATE_FULLSCREEN"* ]]
then
    # make current window fullscreen so we can check its size
    wmctrl -ir "$CUR_WINDOW_PID" -b add,fullscreen

    sleep 0.1

    get_screen_geom

    # make it back to window mode
    wmctrl -ir "$CUR_WINDOW_PID" -b remove,fullscreen

    sleep 0.1

    # weirdly the window can change its size, so we do this
    wmctrl -ir "$CUR_WINDOW_PID" -e "0, $CUR_WINDOW_POS_X, $CUR_WINDOW_POS_Y, $CUR_WINDOW_GEOM_W, $CUR_WINDOW_GEOM_H"
else
    get_screen_geom
fi