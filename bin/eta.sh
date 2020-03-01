#!/bin/bash
# This script should be started from the directory where it is located.
# Best, use the respective Makefile in the same directory.

function usageDIR {
    echo "If an argument DIR=/some/path is given, it is interpreted"
    echo "as the name of a directory in which to store the result file."
    echo "Default is DIR=etafiles."
}

function usageVARIANT {
    echo "If an argument VARIANT=[HemmeckeCached|Hemmecke|Radu|Samba] is given,"
    echo "it is interpreted as the variant that is used to compute the result."
    echo "Default is VARIANT=Hemmecke."
    echo "The variants Radu and Samba can be compiled, but are no longer maintained."
}

###################################################################
function usageQuotientMonoidExponentVectors {
    echo "Usage:"
    echo "  eta QuotientMonoidExponentVectors N [DIR=etafiles]"
    echo "where N is a positive integer computes the exponent vectors"
    echo "for the monoid of eta quotients of level N that are modular functions"
    echo "and have at most a pole at infinity."
    usageDIR
}

function QuotientMonoidExponentVectors {
    cat <<EOF
)read etacompute.input
)set message type off
)set message time on
QEQEV ==> QEtaQuotientExponentVectors4ti2
eqmev ==> etaQuotientMonoidExponentVectors \$ QEQEV
result := eqmev $1;
)set message time off
vPrint("etaQuotientMonoidExponentVectors$1", result)
EOF
}

###################################################################
function usageQuotientIdealGenerators {
    echo "Usage:"
    echo "  eta QuotientIdealGenerators N [DIR=etafiles] [VARIANT=Hemmecke]"
    echo "where N is a positive integer computes the relations between"
    echo "the eta quotients and the eta functions of level N."
    usageDIR
    usageVARIANT
}

function QuotientIdealGenerators {
    DEP=etaQuotientMonoidExponentVectors$1
    cat <<EOF
)read etacompute.input
C ==> Z
QEtaIdeal ==> QEtaIdeal$VARIANT(C, A1 C)
$DEP: List(List Z) := [];
)read $2/$3/$DEP.input
dim: N := # $DEP
syms: LSym := indexedSymbols("M", dim) \$ QAuxiliaryTools
D ==> HomogeneousDirectProduct(dim, N)
E ==> Monomials(dim, N, D, syms) -- show DirectProduct as monomials.
R ==> PolynomialRing(C, E)
PC ==> PolynomialConversion(C, E, syms)
)set message type off
)set message time on
eqig ==> etaQuotientIdealGenerators \$ QEtaIdeal
result := eqig($1, $DEP);
)set message time off
rs: List R := [coerce(x)\$PC for x in result];
vPrint("etaQuotientIdealGenerators$1", rs)
EOF
}


###################################################################
function usageLaurentIdealGenerators {
    echo "Usage:"
    echo "  eta LaurentIdealGenerators N [DIR=etafiles] [VARIANT=Hemmecke]"
    echo "where N is a positive integer computes the relations between"
    echo "the eta quotients and the eta functions of level N."
    usageDIR
    usageVARIANT
}

function LaurentIdealGenerators {
    DEPQMEV=etaQuotientMonoidExponentVectors$1
    DEPQIG=etaQuotientIdealGenerators$1
    cat <<EOF
)read etacompute.input
C ==> Z
QEtaIdeal ==> QEtaIdeal$VARIANT(C, A1 C)
$DEPQMEV: List(List Z) := [];
)read $2/$3/$DEPQMEV.input
$DEPQIG: LPol :=[];
)read $2/$3/$DEPQIG.input
divs: List Z := DIVISORS($1)
esyms: LSym := indexedSymbols("E", divs) \$ QAuxiliaryTools
ysyms: LSym := indexedSymbols("Y", divs) \$ QAuxiliaryTools
syms: LSym := concat(ysyms, esyms)
dim: N := #syms
D ==> HomogeneousDirectProduct(dim, N)
E ==> Monomials(dim, N, D, syms)
R ==> PolynomialRing(C, E)
PC ==> PolynomialConversion(C, E, syms)
)set message type off
)set message time on
elig ==> etaLaurentIdealGenerators \$ QEtaIdeal
result := elig($1, $DEPQMEV, $DEPQIG)
)set message time off
rs: List R := [coerce(x) \$ PC for x in result];
vPrint("etaLaurentIdealGenerators$1", rs)
EOF
}

###################################################################
function usageRelations {
    echo "Usage:"
    echo "  eta Relations N [DIR=etafiles] [VARIANT=Hemmecke]"
    echo "where N is a positive integer computes the relations between"
    echo "the eta quotients and the eta functions of level N."
    usageDIR
    usageVARIANT
}


function Relations {
    DEP=etaLaurentIdealGenerators$1
    cat <<EOF
)read etacompute.input
C ==> Z
QEtaIdeal ==> QEtaIdeal$VARIANT(C, A1 C)
$DEP: LPol := [];
)read $2/$3/$DEP.input
divs: List Z := divisors($1)\$IntegerNumberTheoryFunctions
syms: LSym := indexedSymbols("E", divs)\$QAuxiliaryTools
dim: N := #syms
D ==> HomogeneousDirectProduct(dim, N);
E ==> Monomials(dim, N, D, syms)
R ==> PolynomialRing(C, E)
PC ==> PolynomialConversion(C, E, syms)
)set message type off
)set message time on
xetaRelations ==> etaRelations $ QEtaIdeal
result := xetaRelations($1, $DEP);
)set message time off
rs: List R := [coerce(x) \$ PC for x in result];
vPrint("etaRelations$1",rs)
EOF
}

function usage {
   usageQuotientMonoidExponentVectors; echo;
   usageQuotientIdealGenerators; echo;
   usageLaurentIdealGenerators; echo;
   usageRelations; echo;
}

CMD=$1
shift

# default values
N=0
DIR=etafiles
VARIANT=Hemmecke

while test -n "$1"; do
    param=$1
    case $param in
        DIR=*)
            DIR=${param#DIR=}
            ;;
        VARIANT=*)
            VARIANT=${param#VARIANT=}
            ;;
        *)
            N=$param
            ;;
    esac
    shift
done

echo [C=$CMD][N=$N][D=$DIR][V=$VARIANT]

if test "$N" = "0" -o -z "$CMD"; then usage; exit 1; fi

v=$(tr [:upper:] [:lower:] <<< ${VARIANT:0:1})

FILE=$DIR/$VARIANT/eta$CMD$N
echo [F=$FILE]

# Do the elimination of inverses (Y-variables) via Sage(Singular:slimgb).
if [ $CMD = "Relations" ]; then
    GENS=etaLaurentIdealGenerators$N
    INFILE=$DIR/$VARIANT/$GENS
    sed -e 's/^--/#--/;s/:=/=/;s/;$//' $INFILE.input > $INFILE.sage
    sage etagb.sage $N "$INFILE.sage" $GENS "etaRelations$N" 2>&1 | sed 's/ //g;s/,/, /g' | tee $FILE.tmp
else
    $CMD $N $DIR $VARIANT | FRICAS_INITFILE='' fricas -nosman 2>&1 | tee $FILE.tmp
fi

echo [F=$FILE]
echo "X$CMD $N finished"
