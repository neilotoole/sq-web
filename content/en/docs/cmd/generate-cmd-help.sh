#!/usr/bin/env bash

set -e

cmds=("sql" "src" "add" "ls" "rm" "inspect"
  "ping" "version" "driver" "tbl" "completion" "help")

rm ./*.help.txt

for cmd in "${cmds[@]}"; do
  sq "$cmd" --help > "$cmd".help.txt
done
