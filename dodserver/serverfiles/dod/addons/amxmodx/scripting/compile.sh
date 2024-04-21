#!/bin/bash

# AMX Mod X
#
# by the AMX Mod X Development Team
#  originally developed by OLO
#
# This file is part of AMX Mod X.

# new code contributed by \malex\

# Ensure the compiled directory exists
test -e compiled || mkdir compiled

# Clear any previous compilation logs
rm -f temp.txt

for sourcefile in *.sma
do
  # Construct the .amxx filename from the .sma filename
  amxxfile="`echo $sourcefile | sed -e 's/\.sma$/.amxx/'`"
  echo -n "Compiling $sourcefile ..."

  # Compile the .sma to .amxx and store it in the compiled/ directory
  ./amxxpc $sourcefile -ocompiled/$amxxfile >> temp.txt
  echo "done"
done

# Ensure the plugins directory exists
test -e ../plugins || mkdir ../plugins

# Copy the compiled files to the plugins directory, replacing any existing files
echo "Copying compiled plugins to the plugins directory..."
cp compiled/*.amxx ../plugins/

echo "Copy complete."

# Display the compilation log
less temp.txt

# Remove the temporary file after use
rm temp.txt
