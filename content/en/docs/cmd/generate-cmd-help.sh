#!/usr/bin/env bash
# Generate CMD.help.txt file for each sq command,
# using "sq CMD --help > CMD.help.txt". The generated
# help text is included from the corresponding markdown
# file.

set -e

# Always execute in this dir
cd $(dirname "$0")

cmds=(
  "sql"
  "src"
  "add"
  "ls"
  "rm"
  "inspect"
  "ping"
  "version"
  "driver ls"
  "tbl copy"
  "tbl truncate"
  "tbl drop"
  "completion"
  "help"
   )

rm -f ./*.help.txt

# Special handling for the root command.
sq --help > root.help.txt

for cmd in "${cmds[@]}"; do
  # space -> underscore, e.g. "driver ls" -> "driver_ls"
  dest="${cmd// /_}.help.txt"

  # shellcheck disable=SC2086
  sq $cmd --help > "$dest"
done
