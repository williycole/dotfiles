#!/bin/sh
osascript -e 'tell application "Ghostty" to activate' \
          -e 'tell application "System Events" to keystroke "," using {command down, shift down}'
