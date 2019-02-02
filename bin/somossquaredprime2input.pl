#!/usr/bin/env perl
# Translate the .gp files from Somos
# http://eta.math.georgetown.edu/etal/index.html
# into something that FriCAS can read.

# We basically have to turn /* ... */ comments into FriCAS comments by
# prepending these lines with --.

# Furthermore the braces have to be removed and = has to be replaced by :=.

# In other words, we translate from

## /* level121.gp -- Dedekind eta product identity for level 121 */
## {p=11; idpp=[
## [-1,0,0,60,0],
## ...
## [108347059433883722041830251,250,5,0,55]
## ]};

# into

## -- level121.gp -- Dedekind eta product identity for level 121
## p:=11; idpp:=[ _
## [-1,0,0,60,0], _
## ...
## [108347059433883722041830251,250,5,0,55] _
## ];

# Usage: perl somossquaredprime2input.pl somos-level121.gp

while (<>) {
    if (s|^/\*|--|) {
        s| *\*/||;
        print;
        next;
    }
    if (/^ *$/) {print; next}
    chomp;
    s/{|}//g;
    s/=/:=/g;
    print "$_ _\n";
}
print "--END\n"
