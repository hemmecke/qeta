#!/bin/bash
###################################################################
#
# Eta relations
# Copyright 2015-2021,  Ralf Hemmecke <ralf@hemmecke.org>
#
###################################################################
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
function usageQuotientMonoidSpecifications {
    echo "Usage:"
    echo "  eta QuotientMonoidSpecifications N [DIR=etafiles]"
    echo "where N is a positive integer computes the specifications"
    echo "for the monoid of eta-quotients of level N that are modular functions"
    echo "and have at most a pole at infinity."
    usageDIR
}

function QuotientMonoidSpecifications {
    cat <<EOF
)read etacompute.input )quiet
)set message type off
)set message time on
result := mSPECSInfM0($1, etaFunctionIndices $1);
)set message time off
vPrint("etaQuotientMonoidSpecifications$1", result)
EOF
}

###################################################################
function usageQuotientIdealGenerators {
    echo "Usage:"
    echo "  eta quotientIdealGenerators N [DIR=etafiles] [VARIANT=Hemmecke]"
    echo "where N is a positive integer computes the relations between"
    echo "the eta-quotients and the eta-functions of level N."
    usageDIR
    usageVARIANT
}

function QuotientIdealGenerators {
    DEP=etaQuotientMonoidSpecifications$1
    cat <<EOF
)read etacompute.input )quiet
C ==> ZZ
QEtaIdeal ==> QEtaIdeal$VARIANT(C,QMOD0)
$DEP: List(List List ZZ) := [];
)read $2/$3/$DEP.input )quiet
dim: NN := # $DEP
syms: List Symbol := indexedSymbols("M", dim) \$ QAuxiliaryTools
D ==> HomogeneousDirectProduct(dim, NN)
E ==> Monomials(dim, NN, D, syms) -- show DirectProduct as monomials.
R ==> PolynomialRing(C, E)
PC ==> PolynomialConversion(C, E, syms)
)set message type off
)set message time on
eqig ==> etaQuotientIdealGenerators \$ QEtaIdeal
result := eqig([eqSPEC x for x in $DEP]);
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
    echo "the eta-quotients and the eta-functions of level N."
    usageDIR
    usageVARIANT
}

function LaurentIdealGenerators {
    DEPQMSPECS=etaQuotientMonoidSpecifications$1
    DEPQIG=etaQuotientIdealGenerators$1
    cat <<EOF
)read etacompute.input )quiet
C ==> ZZ
QEtaIdeal ==> QEtaIdeal$VARIANT(C,QMOD0)
$DEPQMSPECS: List(List List ZZ) := [];
)read $2/$3/$DEPQMSPECS.input )quiet
$DEPQIG: LPol C :=[];
)read $2/$3/$DEPQIG.input )quiet
divs: List ZZ := divisors($1)
esyms: List Symbol := indexedSymbols("E", divs) \$ QAuxiliaryTools
ysyms: List Symbol := indexedSymbols("Y", divs) \$ QAuxiliaryTools
syms: List Symbol := concat(ysyms, esyms)
dim: NN := #syms
D ==> HomogeneousDirectProduct(dim, NN)
E ==> Monomials(dim, NN, D, syms)
R ==> PolynomialRing(C, E)
PC ==> PolynomialConversion(C, E, syms)
elig ==> etaLaurentIdealGenerators \$ QEtaIdeal
)set message type off
)set message time on
result := elig(etaFunctionIndices $1, [eqSPEC x for x in $DEPQMSPECS], $DEPQIG)
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
    echo "the eta-quotients and the eta-functions of level N."
    usageDIR
    usageVARIANT
}


function Relations {
    DEP=etaLaurentIdealGenerators$1
    cat <<EOF
)read etacompute.input )quiet
C ==> ZZ
QEtaIdeal ==> QEtaIdeal$VARIANT(C,QMOD0)
$DEP: LPol C := [];
)read $2/$3/$DEP.input )quiet
divs: List ZZ := divisors($1)\$IntegerNumberTheoryFunctions
syms: List Symbol := indexedSymbols("E", divs)\$QAuxiliaryTools
dim: NN := #syms
D ==> HomogeneousDirectProduct(dim, NN);
E ==> Monomials(dim, NN, D, syms)
R ==> PolynomialRing(C, E)
PC ==> PolynomialConversion(C, E, syms)
)set message type off
)set message time on
result := etaRelations(etaFunctionIndices $1, $DEP) \$ QEtaIdeal;
)set message time off
rs: List R := [coerce(x) \$ PC for x in result];
vPrint("etaRelations$1",rs)
EOF
}

function usage {
   usageQuotientMonoidSpecifications; echo;
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
    sage $ROOT/sagemath/etagb.sage $N "$INFILE.sage" $GENS "etaRelations$N" 2>&1 \
        | sed 's/ //g;s/,/, /g;s/Time:/ Time: /;s/sec$/ sec/' \
        | tee $FILE.tmp
else
    echo ======== $FILE ==============
    $CMD $N $DIR $VARIANT | tee $FILE.fricas.input | FRICAS_INITFILE='' fricas -nosman 2>&1 \
        | tee $FILE.tmp
fi

echo [F=$FILE]
echo "X$CMD $N finished"
