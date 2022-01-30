#!/usr/bin/perl

# This file computes the dependencies of the .spad files that are
# given through stdin.
# All ")abbrev" lines are considered and constructors are saved.
# All files that contain an explicit mention of that constructor
# are declared to be a dependency of the file containing the respective
# ")abbrev" line.
# Docstrings and comments are skipped.
# We do not sort out strings, so if a constructor name appears inside
# a string, then that is falsely recognized as a dependency.

%C=();
@files=();

sub read_definitions {
    ($fn)=@_;
#    print "<<< $fn\n";
    open(FLINES, "<$fn");
    while ($line=<FLINES>) {
        if($line =~ /[)]endif/){$ignore=0;next}
        if($line =~ /[)]if/){$ignore=1}
        if($ignore) {next}
        $line =~ s/--.*//;
        if ($line =~ /^[)]abbrev [a-z]* [A-Z]* ([a-zA-Z0-9]*)/) {
            $c=$1;
            $C{$c}=$fn;
#            print "def $fn: $c\n";
        }
    }
    close FLINES;
}

sub write_dependencies {
    ($fn)=@_;
#    print ">>> $fn\n";
    %D=();
    open(FLINES, "<$fn");
    while ($line=<FLINES>) {
        if($line =~ /[)]endif/){$ignore=0;next}
        if($line =~ /[)]if/){$ignore=1}
        if($ignore) {next}
        if($line =~ / *[+][+]/) {next}
        if($line =~ /^[)]abbrev/) {next}
        $line =~ s/--.*//;
#        print "=== $line";
        for $c (keys %C) {
            if (($line =~ /\W$c\W/) and ($C{$c} ne $fn)) {
#                print "match $fn: $c\n";
                $D{$C{$c}}=1; # -- we have found a dependency
            }
        }
    }
    close FLINES;
    $l="";
    for $d (sort keys %D) {$l = "$l $d"}
    $l =~ s/\.spad/.compile/g;
    if ($l ne "") {print "$fn:$l\n"}
}

while (<>) {
    $fn=$_;
    chomp $fn;
    push(@files,$fn);
    read_definitions($fn);
}

for $fn (@files) {write_dependencies($fn);}
