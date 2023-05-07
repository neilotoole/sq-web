#!/usr/bin/env bash
# Generate CMD.help.txt file for each sq command,
# using "sq CMD --help > CMD.help.txt". The generated
# help text is included from the corresponding markdown
# file.

set -e

# Always execute in this dir
cd $(dirname "$0")

cmds=(
  "add"
  "completion"
  "config location"
  "config ls"
  "config get"
  "config set"
  "config edit"
  "driver ls"
  "group"
  "help"
  "inspect"
  "ls"
  "mv"
  "ping"
  "rm"
  "sql"
  "src"
  "tbl copy"
  "tbl drop"
  "tbl truncate"
  "version"
   )

rm -f ./*.help.txt
rm -f ./*.output.txt

for cmd in "${cmds[@]}"; do
  # space -> dash, e.g. "driver ls" -> "driver-ls"
  dest="${cmd// /-}.help.txt"

  # shellcheck disable=SC2086
  sq $cmd --help > "$dest"
done

# Special handling for the root command.
sq --help > sq.help.txt

# Show output for some commands
sq driver ls > driver-ls.output.txt
