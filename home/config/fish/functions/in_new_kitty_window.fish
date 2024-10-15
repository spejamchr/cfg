function in_new_kitty_window
  if [ $TERM != "xterm-kitty" ]
    echo "Only available in kitty"
    return 1
  end

  set -l title $argv[1]

  set -l id $(kitty @ launch --type tab --tab-title $title --title $title --keep-focus)

  if [ (count $argv) -gt 1 ]
    fish --command "sleep 0.1 && kitty @ send-text -m id:$id \"$argv[2..]\" \n" &
  end
end
