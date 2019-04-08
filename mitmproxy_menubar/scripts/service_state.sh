#!/bin/sh
if pgrep -xq -- "mitmweb"; then
    echo ON
else
    echo OFF
fi
