#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require_relative '../_lib/helper.rb'

if `uname`.split.first.downcase != 'darwin'
  STDERR.puts 'This script must be run in macOS.'
  exit(false)
end

def udefs(namespace, key, type_flag, val)
  ['defaults', 'write', namespace, key, type_flag, val]
end

def generate_commands
  commands = []
  kill = Set.new

  if prompt_yn('Disable the dashboard?')
    commands << udefs('com.apple.dashboard', 'mcx-disabled', '-bool', 'YES')
    kill << 'Dashboard'
  end
  if prompt_yn('Disable window animations?')
    commands << udefs('NSGlobalDomain', 'NSAutomaticWindowAnimationsEnabled', '-bool', 'NO')
  end
  if prompt_yn('Dock: Fade out hidden app icons?')
    commands << udefs('com.apple.dock', 'showhidden', '-bool', 'YES')
    kill << 'Dock'
  end
  if prompt_yn('Finder: Show the ~/Library folder?')
    commands << ['chflags', 'nohidden', File.expand_path('~/Library')]
    kill << 'Finder'
  end

  kill.each { |app| commands << ['killall', app] }
  commands
end

def main
  heading 'Customising'
  commands = generate_commands

  heading 'Confirming'
  commands.each { |args| puts "Run: #{PINK}#{args.shelljoin}#{OFF}" }
  return false unless prompt_yn('Apply this configuration?')

  heading 'Applying configuration'
  commands.each do |args|
    run_command(args)
  end
  true
end

exit(main) if $PROGRAM_NAME == __FILE__