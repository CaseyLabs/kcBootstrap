#!/usr/bin/env sh

# @file kcDeployCode
# @brief A bash script to deploy the built source code.

# -- Setup

set -e                        # exit script if error encountered
. ${kcDir}/misc/scripts/shared.sh   # import shared shell functions
trap finishScript EXIT        # run finishScript function on exit

# --- Script

## Insert your service deploy commands here.