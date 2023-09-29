#!/usr/bin/env sh

# @file kcStopCode
# @brief A bash script to stop the running the built source code.

# -- Setup

set -e                        # exit script if error encountered
. ./misc/scripts/shared.sh   # import shared shell functions
trap finishScript EXIT        # run finishScript function on exit

# --- Script

## Insert `docker stop` or service stop commands here.