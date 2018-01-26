#!/bin/bash
# Translate the .gp files from Somos
# http://eta.math.georgetown.edu/etaL/index.html
# into something that FriCAS can read.

# We basically have to turn /* ... */ comments into FriCAS comments by
# prepending these lines with --.

# Furthermore the braces have to be removed and = has to be replaced by :=.

perl -e 'while(<>) {' \
     -e '  if (s|^/\*|--|) {s| *\*/||; print; next;}' \
     -e '  if (/^ *$/) {print; next}' \
     -e '  chomp;' \
     -e '  s/{|}//g; s/=/:=/g;' \
     -e '  print "$_ _\n";' \
     -e '}' \
     -e 'print "--END\n"' \
   $1
