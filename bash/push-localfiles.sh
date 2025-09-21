#!/bin/bash

# Simple scp wrapper to copy localfiles to a remote EC2 instance
# Usage:
#   ./push-localfiles.sh -k ~/.ssh/key.pem -d user@host [files...]
#   ./push-localfiles.sh -k ~/.ssh/key.pem -d user@host --bash
#
# Optional logging:
#   ./push-localfiles.sh -k key.pem -d user@host --bash -o scp.log

set -e

show_help() {
  echo "Usage: $0 -k <key.pem> -d <user@host> [files...]"
  echo "Options:"
  echo "  -k <pem>       Path to your .pem private key (required)"
  echo "  -d <dest>      Destination in format user@ip (required)"
  echo "  -o <file>      Log verbose scp output to file (optional)"
  echo "  --bash         Push common bash localfiles (~/.bashrc, ~/.bash_profile, etc.)"
  echo "  files...       List of files to push manually"
  echo ""
  echo "Examples:"
  echo "  $0 -k ~/.ssh/buildshift-rsa.pem -d user@host --bash"
  echo "  $0 -k ~/.ssh/buildshift-rsa.pem -d user@host ~/.vimrc ~/.gitconfig"
  echo "  $0 -k ~/.ssh/buildshift-rsa.pem -d user@host --bash -o scp.log"
}

# Defaults
KEY=""
DEST=""
LOGFILE=""
FILES=()

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -k)
      KEY="$2"
      shift 2
      ;;
    -d)
      DEST="$2"
      shift 2
      ;;
    -o)
      LOGFILE="$2"
      shift 2
      ;;
    --bash)
      FILES+=(
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.bashrc_alias"
        "$HOME/.bashrc_colors"
        "$HOME/.bashrc_functions"
        "$HOME/.bashrc_npmcompletion"
      )
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      FILES+=("$1")
      shift
      ;;
  esac
done

# Validate
if [[ -z "$KEY" || -z "$DEST" ]]; then
  echo "Error: both -k (key.pem) and -d (destination) are required"
  show_help
  exit 1
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "Error: no files specified"
  show_help
  exit 1
fi

# Build scp command
SCP_CMD=(scp -i "$KEY")
if [[ -n "$LOGFILE" ]]; then
  SCP_CMD+=(-v)
fi
SCP_CMD+=("${FILES[@]}" "$DEST:~")

# Print command
echo "Using key: $KEY"
echo "Destination: $DEST"
echo "Files: ${FILES[*]}"
echo "Command: ${SCP_CMD[*]}"

# Run scp (log if requested)
if [[ -n "$LOGFILE" ]]; then
  "${SCP_CMD[@]}" >"$LOGFILE" 2>&1
  echo "Done. Verbose output logged to $LOGFILE"
else
  "${SCP_CMD[@]}"
  echo "Done."
fi
