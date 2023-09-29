#!/usr/bin/env sh

# @file kcRunCode
# @brief A bash script to start runing the built source code.

# -- Setup

set -e                        # exit script if error encountered
. ./misc/scripts/shared.sh   # import shared shell functions
trap finishScript EXIT        # run finishScript function on exit

# --- Script

# Write your service's install steps. Example:
docker run -it --rm $kcImageName

