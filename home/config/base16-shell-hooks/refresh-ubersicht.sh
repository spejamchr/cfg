#!/usr/bin/env bash

osascript -e 'tell application "Übersicht"
    refresh widget id "topbar-Components-Body-jsx"
    refresh widget id "topbar-Components-Gilbert-jsx"
end tell'
