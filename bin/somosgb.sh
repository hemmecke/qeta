#!/bin/bash

function usageDIR {
    echo "If an argument DIR=/some/path is given, it is interpreted"
    echo "as the name of a directory in which to store the result file."
    echo "Default is DIR=etafiles."
}

function usageSOMOS {
    echo "If an argument SOMOS=/path/to/somos is given, it is the path"
    echo "where the somos\$N.input files are stored."
    echo "Default is SOMOS='somos'."
}

function usage {
    echo "Usage:"
    echo "  somosgb.sh N [DIR=etafiles] [IDEAL=Polynomial] [SOMOS=somos]"
    cat <<EOF

The script reads the files "\$SOMOS/somos\$N.input", translates
the Somos-relation into E variables (i.e, from Euler series (with
variables u and q) to eta-functions), creates the file
\$DIR/Somos/somosetagens\$N.input", and translates it into
\$DIR/Somos/somosetagens\$N.sage", a form that SageMath can read.
Then a degrevlex Groebner bases (slimgb from Singular via SageMath)
from these polynomials is computed and stored in
"\$DIR/Somos/somosEtaGroebner.out".

If the parameter "IDEAL=Laurent" is given, then it is assumed that the file
"\$DIR/Somos/somosEtaGroebner.input" exists. That files is translated into
"\$DIR/Somos/somosLaurentGenerators.sage" (a format that SageMath can read)
and then SageMath is called with the script etagb.sage.

EOF
    usageDIR
    usageSOMOS
}

function fricas_program {
    LEVEL=$1
    cat <<EOF
)read etacompute
tPrint(x)==display(x::Symbol::OF::Formatter(Format1D));_
level := $LEVEL
)read $SOMOS/somos$LEVEL.input
f: XHashTable(Symbol, Pol) := table();
hkeys: List Symbol := keys h;
xkey(k: Symbol): String == (_
    b: Z := 10000;_
    s: String := string k;_
    l: Z := #s;_
    t: String := "";_
    p1: Z := position(char "__", s);_
    p2: Z := position(char "__", s, p1+1);_
    p3: Z := position(alphabetic(), s, p2+1);_
    if zero? p3 then p3 := l+1 else t := s(p3..l);_
    d: Z := parse_integer(s(p1+1..p2-1))\$ScanningUtilities;_
    r: Z := parse_integer(s(p2+1..p3-1))\$ScanningUtilities;_
    return concat [string(b^2+d*b+r), t, ".", s]_
);

xkeys: List String := [xkey k for k in hkeys] ;
skeys: List String := sort xkeys;
fkeys: List Symbol := [x(position(char ".", x)\$String+1..#x)::Symbol for x in skeys];
for k in fkeys repeat f(k) := toEta(level, h k)

divs: List Z := divisors(level)\$IntegerNumberTheoryFunctions
syms: List Symbol := indexedSymbols("E", divs)\$QAuxiliaryTools
dim: N := #syms
D ==> HomogeneousDirectProduct(dim, N);
toR ==> coerce\$PC
tPrint("-- Somos eta relations --");
for k in fkeys repeat vPrint(k, toR(f.k));
tPrint("-- Somos eta generators --");
vPrint("somosEtaGenerators$LEVEL", fkeys);
EOF
}

function somosetagens_input {
    LEVEL=$1
    fricas_program $LEVEL \
        | fricas -nosman \
        | perl -e 'while (<>) {' \
               -e '  if ($P) {' \
               -e '    chomp;' \
               -e '    s/^\(\d+\).* -> //;' \
               -e '    if (/[tqx].* :/){$v=$_;$v=~s/ :.*//;print "$v";s/.* :/ :/;}'\
               -e '    if (! /_$/ and ! /^ *$/) {s/$/;\n/};' \
               -e '    s/_$//;' \
               -e '    if (/-- Somos eta generators --/) {$G=1};' \
               -e '    if (!$G) {s/_//g};' \
               -e '    s/^ *-- /-- /;' \
               -e '    if (! /^ *$/) {print;}' \
               -e '  } elsif (/^.*-- .* --$/) {' \
               -e '    s/^.*  -- /-- /;' \
               -e '    $P=1; print;}' \
               -e '}'
    # > $DIR/Somos/somosetagens$LEVEL.input
}

# default values
N=0
DIR=etafiles
IDEAL=Polynomial

while test -n "$1"; do
    param=$1
    case $param in
        SOMOS=*)
            SOMOS=${param#SOMOS=}
            ;;
        DIR=*)
            DIR=${param#DIR=}
            ;;
        IDEAL=*)
            IDEAL=${param#IDEAL=}
            ;;
        *)
            N=$param
            ;;
    esac
    shift
done

echo [CMD=somosgb][N=$N][D=$DIR][I=$IDEAL]

if test "$N" = "0"; then usage; exit 1; fi

if test "$IDEAL" = "Laurent"; then
    GENFILE=$DIR/Somos/somosLaurentGenerators$N.sage
    sed -e 's/^somosEtaGroebner/somosLaurentGenerators/' \
        -e 's/:=/=/' \
        -e 's/^--/#--/' \
        $DIR/Somos/somosEtaGroebner$N.input \
        >  $GENFILE
    sage etagb.sage $N $GENFILE somosLaurentGenerators$N somosLaurentGroebner$N \
        | sed 's/ //g;s/,/, /g' \
        > $DIR/Somos/somosLaurentGroebner$N.tmp
else
    GENFILE=$DIR/Somos/somosEtaGenerators$N.sage
    somosetagens_input $N \
        | sed -e 's/^--/#--/;s/:=/=/;s/;$//' \
        >  $GENFILE
    sage etagb.sage $N $GENFILE somosEtaGenerators$N somosEtaGroebner$N \
        | sed 's/ //g;s/,/, /g' \
        > $DIR/Somos/somosEtaGroebner$N.tmp
fi
