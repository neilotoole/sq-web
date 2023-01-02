#!/usr/bin/env bash
# Generate CMD.help.txt file for each sq command,
# using "sq CMD --help > CMD.help.txt". The generated
# help text is included from the corresponding markdown
# file.

set -e

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

for cmd in "${cmds[@]}"; do
  dest="${cmd// /_}.help.txt" # space to underscore
  sq "$cmd" --help > "$dest"
done
