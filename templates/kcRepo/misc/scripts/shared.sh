#!/usr/bin/env sh

# @file kcShell
# @brief Shell helper scripts, to be imported into a parent script.

# --- Setup

# Import service-specific env vars:
if [ -f ./config/service.env ]; then
  set -a
  . ./config/service.env
  set +a
fi

# --- Functions

# @description `log` events to output. Example: `log info "Uploading data..."`
log() {
  local timestamp=$(date +"%Y-%m-%d %I:%M:%S %p %Z" )
  local eventType="$1"
  local eventMessage="$2"

  local logPrefix="$timestamp | $HOSTNAME | $kcServiceName | [$eventType]"

  case "$eventType" in
    debug | Debug | DEBUG)      
      if [ -z "$DEBUG" ]; then return # Only log if $DEBUG env var is set
      else echo "$logPrefix $eventMessage"
      fi 
      ;;
    error | Error | ERROR)
      # Send output to stderr (&2):
      echo "$logPrefix $eventMessage" >&2 ; return 
      ;;
    *)
      echo "$logPrefix $eventMessage" ; return 
      ;;
  esac
}

scriptStartTime=$(date +%s)
# @description `finishScript` executes when the script exits.
finishScript() {
  scriptFinishTime=$(date +%s)
  log info "Script finished in $((scriptFinishTime - scriptStartTime)) seconds."
}