# @name: kcShell
# @description: Shell script helper functions.
#
# @description
#
# Shell script helper functions, to be sourced into a parent script.
#
# ## Usage
#
# Install:
# ```
# helperScript=$(curl -s https://raw.githubusercontent.com/CaseyLabs/kcBootstrap/main/scripts/kcShell/main.sh)
# eval "$helperScript"
# ```

# --- Setup

# Root user check:
# - check if Effective User ID (EUID) is set to 0 (0 = root user)
# - If not, optionally prepend `sudo` to commands:
if [ "$EUID" -ne 0 ]; then
  sudo="sudo"
else
  sudo=''
fi

# --- Functions

# @description `log` events to output. Example: `log info "Uploading data..."`
log() {
  # Example output:
  # $timestamp | $HOSTNAME | [$eventType] $eventMessage
  # 2023-09-28 11:03:57 PM PDT | thinkpad-linux | [info] test

  local timestamp=$(date +"%Y-%m-%d %I:%M:%S %p %Z" )
  local eventType="$1"
  local eventMessage="$2"

  local logPrefix="$timestamp | $HOSTNAME | [$eventType]"

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

# ---

scriptStartTime=$(date +%s)

# @description `finishScript` executes when the script exits.
finishScript() {
  local scriptFinishTime=$(date +%s)
  log info "Script finished in $((scriptFinishTime - scriptStartTime)) seconds."
}

# ---

# @description `check`` if a variable, app, file, or directory exists
# example: `check myVar; check /home/$USER/.bashrc; check git`
check() {
  # Ensure an argument is provided
  if [ -z "$1" ]; then
    log error "Please provide a name or path to check."
    return 1
  fi

  # Check if it's an environment variable
  if eval "test -n \"\${$1:-}\""; then
    log info "Variable <$1> exists with value: \$$1"
    return
  fi

  # Check if it's a command available on $PATH
  if command -v "$1" > /dev/null 2>&1; then
    log info "Command <$1> is available on PATH at location: $(command -v "$1")"
    return
  fi

  # If it's not an env var or a command, check if it's a file or directory 
  # and get its absolute path
  if [ -f "$1" ]; then 
    if [ "$(echo "$1" | cut -c1)" = "/" ]; then
      log info "File exists at: $1"
    else
      log info "File exists at: $(pwd)/$1"
    fi
  elif [ -d "$1" ]; then 
    if [ "$(echo "$1" | cut -c1)" = "/" ]; then
      log info "Directory exists at: $1"
    else
      log info "Directory exists at: $(pwd)/$1"
    fi
  else 
    log error "Could not find file, directory, env var, or app with name: $1"
    return 1
  fi
}

# ---

# @description `get` | download and install a system package. 
# Usage: `get mysql-client`
get() {
 if command -v apt > /dev/null; then
    $sudo apt update
    $sudo apt install -y "$@"
    $sudo apt autoremove -y
    $sudo apt clean

  elif command -v yum > /dev/null; then
    $sudo yum install -y "$@"

  elif command -v dnf > /dev/null; then
    $sudo dnf install -y "$@"

  elif command -v apk > /dev/null; then
    $sudo apk add --no-cache "$@"

  else
    log error "Could not detect package manager apt, yum, dnf, or apk."
    return 1
  fi
}

# ---

# @description `remove` | uninstall a system package. 
# Usage: `remove mysql-client`
remove() {
  # For APT (Debian/Ubuntu)
  if command -v apt > /dev/null; then
    $sudo apt autoremove --purge -y "$@"

  # For YUM (Older Red Hat, CentOS)
  elif command -v yum > /dev/null; then
    $sudo yum remove -y "$@"

  # For DNF (Modern Red Hat, Fedora, CentOS)
  elif command -v dnf > /dev/null; then
    $sudo dnf remove -y "$@"

  # For APK (Alpine Linux)
  elif command -v apk > /dev/null; then
    $sudo apk del "$@"

  else
    log error "Could not detect package manager."
    return 1
  fi
}

# ---

# @description `grab` - downloads and installs a .deb .or .tar.gz
# Usage: grab https://my_url/myfile.deb
grab() {
    # Check if a URL is provided
    if [ -z "$1" ]; then
        log error "Please provide a URL."
        return 1
    fi

    # If it's a .deb file
    if [[ "$1" == *.deb ]]; then
        wget -O temp.deb "$1" &&
        sudo dpkg -i temp.deb &&
        rm -f temp.deb

    # If it's a .tar.gz file
    elif [[ "$1" == *.tar.gz ]]; then
        wget -O temp.tar.gz "$1" &&
        mkdir -p tar-extracted &&
        tar -xvf temp.tar.gz -C tar-extracted/ &&
        rm -f temp.tar.gz
    else
        log error "Unsupported file type. Please provide a .deb or .tar.gz URL."
        return 1
    fi
}

# ---

# @brief `forEachLine`
# @description Performs a command for each value (`thisLine`) in a file
# @param $1 - The target file to read lines from
# @param $2 - The command to run for each line, where the value from the line can be represented by `$thisLine`
# @example `forEachLine myVars.txt "echo \"The value for $thisLine is: $thisLine\""`
forEachLine() {
    # Ensure both arguments are provided
    if [ "$#" -ne 2 ]; then
        echo "Usage: forEachLine <targetFile> <commandToRun>"
        return 1
    fi

    # Read the file line by line
    while IFS= read -r thisLine; do
        # Use eval to execute the command, replacing occurrences of $thisLine with the current line value
        eval "$(echo "$2" | sed "s/\$thisLine/$thisLine/g")"
    done < "$1"
}

# ---

# @brief `makepass`
# @description Generates a 64 character random string.
makepass() {
  local length="$1"
  if [ -z "$length" ]; then length="64"; fi 

  openssl rand -base64 $1
}

# ---

# @brief `asdfinstall`
# @description adsf version manager helper - setups desired plugin and installs latest version of desired tool
asdfinstall() {
  local tool="$1"

  if [ -z "$1" ]; then
    log error "Please provide a tool name to install. Example: asfdinstall golang"
    return 1
  fi

  asdf plugin add "${tool}"
  asdf plugin install "${tool}" latest
  asdf global "${tool}" latest
  asdf reshim
}

