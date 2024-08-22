#!/bin/bash

# creates variables DESTOP_WA_W, DESTOP_WA_H, DESKTOP_WA_TOP_LEFT_X, DESKTOP_WA_TOP_LEFT_Y

DESKTOP_WA_DIMS=$(xprop -root _NET_WORKAREA | grep -Eo '[0-9]+')

DESKTOP_WA_TOP_LEFT_X=$(echo $DESKTOP_WA_DIMS | cut -d " " -f1)
DESKTOP_WA_TOP_LEFT_Y=$(echo $DESKTOP_WA_DIMS | cut -d " " -f2)

DESTOP_WA_W=$(echo $DESKTOP_WA_DIMS | cut -d " " -f3)
DESTOP_WA_H=$(echo $DESKTOP_WA_DIMS | cut -d " " -f4)

echo "Working screen size: " $DESTOP_WA_W "x" $DESTOP_WA_H "[Top left:" "("$DESKTOP_WA_TOP_LEFT_X"," $DESKTOP_WA_TOP_LEFT_Y")]"