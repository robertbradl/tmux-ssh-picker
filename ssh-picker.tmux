#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmux bind-key m run-shell "tmux display-popup -E -B -s none -w 50% -h 40% '~/.config/tmux/scripts/window-menu.sh'"
