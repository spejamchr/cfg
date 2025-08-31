#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

def kitty_info
  JSON.parse(`kitty @ ls`)
end

def nvim_window_ids
  kitty_info
    .flat_map { |h| h["tabs"] }
    .flat_map { |t| t["windows"] }
    .filter { |w| w["foreground_processes"].any? { |p| p["cmdline"].first == "nvim" } }
    .map { |w| w["id"] }
end

# Tell all nvim sessions to reload ~/.vimrc_background
#
# This is a little brittle. The escape sequences--\033\033--are sent to exit
# insert/visual mode and return to normal mode.
nvim_window_ids.each do |id|
  `kitty @ --to unix:/tmp/mykitty send-text -m id:#{id} $'\033\033:source ~/.vimrc_background\n'`
end

