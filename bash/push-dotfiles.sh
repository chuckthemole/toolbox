#!/bin/bash

# Simple scp wrapper to copy dotfiles to a remote EC2 instance
# Usage:
#   ./push-dotfiles.sh -k ~/.ssh/key.pem -d user@host [files...]
#   ./push-dotfiles.sh -k ~/.ssh/key.pem -d user@host --bash

set -e

show_help() {
  echo "Usage: $0 -k <key.pem> -d <user@host> [files...]"
  echo "Options:"
  echo "  -k <pem>       Path to your .pem private key (required)"
  echo "  -d <dest>      Destination in format user@ip (required)"
  echo "  --bash         Push common bash dotfiles (~/.bashrc, ~/.bash_profile, etc.)"
  echo "  files...       List of files to push manually"
  echo ""
  echo "Examples:"
  echo "  $0 -k ~/.ssh/buildshift-rsa.pem -d debian@13.58.250.41 --bash"
  echo "  $0 -k ~/.ssh/buildshift-rsa.pem -d debian@13.58.250.41 ~/.vimrc ~/.gitconfig"
}

# Defaults
KEY=""
DEST=""
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
  echo "❌ Error: both -k (key.pem) and -d (destination) are required"
  show_help
  exit 1
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "❌ Error: no files specified"
  show_help
  exit 1
fi

# Run scp
echo "🔑 Using key: $KEY"
echo "📡 Destination: $DEST"
echo "📂 Files: ${FILES[*]}"

scp -i "$KEY" "${FILES[@]}" "$DEST:~"
echo "✅ Done."

