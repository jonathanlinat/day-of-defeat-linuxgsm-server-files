#!/bin/bash
# AMX Mod X Compilation Script
# Compiles .sma files from the source directory to the plugins directory

SOURCE_DIR="./source"
PLUGINS_DIR="./../plugins"

if [ ! -d "$PLUGINS_DIR" ]; then
  mkdir -p "$PLUGINS_DIR"
fi

rm -f "$PLUGINS_DIR"/*

for sourcefile in $SOURCE_DIR/*.sma; do
  filename=$(basename "$sourcefile")
  amxxfile="${filename%.sma}.amxx"
  echo -n "Compiling $filename ..."
  ./amxxpc "$sourcefile" -o"$PLUGINS_DIR/$amxxfile"
done
