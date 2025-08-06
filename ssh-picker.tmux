#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
tmux bind-key m run-shell "$CURRENT_DIR/scripts/ssh-picker.sh"
