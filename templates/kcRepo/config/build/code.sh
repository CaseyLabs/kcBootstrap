#!/usr/bin/env sh

# @file kcBuildCode
# @brief A shell script to build the repo's source code.

# --- Setup

set -e                              # exit script if error encountered
. ${kcDir}/misc/scripts/shared.sh   # import shared shell functions + env vars
trap finishScript EXIT              # run finishScript function on exit

# --- Script

# Write your service's install steps. Example:
docker build \
--progress plain \
--file ${kcDir}/config/dockerfile.example \
--tag $kcImageName \
${kcDir}