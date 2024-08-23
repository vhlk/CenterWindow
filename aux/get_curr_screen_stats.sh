#!/bin/bash

# creates variables CUR_WINDOW_PID, CURR_SCREEN_GEOM_W, CURR_SCREEN_GEOM_H, CURR_SCREEN_POS_X, CURR_SCREEN_POS_Y

CUR_WINDOW_PID=$(xdotool getactivewindow)

get_screen_geom () {
    CURR_SCREEN_STATS=$(xdotool getwindowgeometry "$CUR_WINDOW_PID")
    CURR_SCREEN_GEOM=$(grep -o '[0-9]*x[0-9]*' <<< "$CURR_SCREEN_STATS")
    # CURR_SCREEN_POS=$((grep -o 'Position: .*' <<< "$CURR_SCREEN_STATS") | grep -Eo '[-]*[0-9]+,[-]*[0-9]+')

    CURR_SCREEN_GEOM_H=$(cut -d "x" -f2 <<< $CURR_SCREEN_GEOM)
    CURR_SCREEN_GEOM_W=$(cut -d "x" -f1 <<< $CURR_SCREEN_GEOM)

    # CURR_SCREEN_POS_X=$(cut -d ',' -f1 <<< "$CURR_SCREEN_POS")
    # CURR_SCREEN_POS_Y=$(cut -d ',' -f2 <<< "$CURR_SCREEN_POS")

    CURR_SCREEN_POS_X=$(xwininfo -id "$CUR_WINDOW_PID" | grep 'Absolute upper-left X:' | grep -Eo '[-]*[0-9]+')
    CURR_SCREEN_POS_X=$(( CURR_SCREEN_POS_X - FRAME_EXTENTS_LEFT ))
    CURR_SCREEN_POS_Y=$(xwininfo -id "$CUR_WINDOW_PID" | grep 'Absolute upper-left Y:' | grep -Eo '[-]*[0-9]+')
    CURR_SCREEN_POS_Y=$(( CURR_SCREEN_POS_Y - FRAME_EXTENTS_TOP ))

    echo "Current screen available size: $CURR_SCREEN_GEOM_W x $CURR_SCREEN_GEOM_H"
    echo "Current screen upper-left pos: ($CURR_SCREEN_POS_X, $CURR_SCREEN_POS_Y)"
}

INITIAL_NET_WM_STATE=$(xprop _NET_WM_STATE -id $CUR_WINDOW_PID)
# make current window fullscreen so we can check its size
wmctrl -ir "$CUR_WINDOW_PID" -b add,maximized_vert
wmctrl -ir "$CUR_WINDOW_PID" -b add,maximized_horz

sleep 0.1

get_screen_geom

# make it back to window mode
if [[ "$INITIAL_NET_WM_STATE" != *"_NET_WM_STATE_MAXIMIZED_VERT"* ]]
then
    wmctrl -ir "$CUR_WINDOW_PID" -b remove,maximized_vert
fi
if [[ "$INITIAL_NET_WM_STATE" != *"_NET_WM_STATE_MAXIMIZED_HORZ"* ]]
then
    wmctrl -ir "$CUR_WINDOW_PID" -b remove,maximized_horz
fi

sleep 0.1

# weirdly the window can change its size, so we do this
wmctrl -ir "$CUR_WINDOW_PID" -e "0, $CUR_WINDOW_POS_X, $CUR_WINDOW_POS_Y, $CUR_WINDOW_GEOM_W, $CUR_WINDOW_GEOM_H"