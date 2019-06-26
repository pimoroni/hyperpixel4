#!/bin/bash

ORIENTATION=$1
DEVICE="pointer:Goodix Capacitive TouchScreen"

function set_matrix {
    printf "Setting matrix: $1 $2 $3 $4 $5 $6\n";
    xinput set-prop "$DEVICE" "Coordinate Transformation Matrix" $1 $2 $3 $4 $5 $6 0 0 1
}

function set_display {
    printf "Rotating display\n";
    xrandr --output DSI-1 --rotate $1
}

if [ "$ORIENTATION" == "right" ]; then
    set_display $ORIENTATION
    set_matrix -1 0 1 0 -1 1
    exit 0
fi

if [ "$ORIENTATION" == "left" ]; then
    set_display $ORIENTATION
    set_matrix 1 0 0 0 1 0
    exit 0
fi

if [ "$ORIENTATION" == "inverted" ]; then
    set_display $ORIENTATION
    set_matrix 0 -1 1 1 0 0
    exit 0
fi

if [ "$ORIENTATION" == "normal" ]; then
    set_display $ORIENTATION
    set_matrix 0 1 0 -1 0 1 0 0 1
    exit 0
fi

printf "Unsupported orientation: $ORIENTATION\n";
