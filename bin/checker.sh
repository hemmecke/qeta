#!/bin/bash

# ls -1 etafiles/Hemmecke/etaRelations*.input|sed 's|.*etaRelations||;s|\.input$||'|sort -n| while read n; do ( bin/checker.sh $n > etafiles/Hemmecke/checker$n.out; echo "=== $n ==="; )&  done


function usage {
    echo "Usage:"
    echo "  checker.sh N"
    cat <<EOF

The script reads the file etafiles/Hemmecke/etaRelations$N.input.
For each polynomial, it divides it by the leading powerproduct.
Then it replaces each powerproduct in this Laurent polynomial by
the (vector of) Laurent series expansions at each cusp of Gamma_0(N)
of the eta-quotient corresponding to the exponent vector of the
powerproduct. The resulting series vector should be the zero vector.

The output is written to stdout.
EOF
}

function fricas_program {
    LEVEL=$1
    FILE=$2
    cat <<EOF
)r projectlibs
)r qetamacros

S ==> Symbol
PZZ ==> SparseUnivariatePolynomial ZZ
PQQ ==> SparseUnivariatePolynomial QQ
Rec ==> Record(root: PP, elem: PZZ)
SEQUO ==> SymbolicEtaQuotient
PL ==> PolynomialCategoryLifting(NN, SingletonAsOrderedSet, C, PZZ, PQQ)
CX ==> SimpleAlgebraicExtension(QQ, PQQ, pq)
LX ==> QEtaLaurentSeries CX
EQX ==> EtaQuotientX(QQ, mx, CX, xi, LX)
EQXA ==> EtaQuotientExpansionAlgebra(CX, LX, level)

-- compute the basis of eta-quotients in terms of expansions
level := $LEVEL
)r ../etafiles/Hemmecke/etaRelations$LEVEL
erels := etaRelations$N

divs: List PP := DIVISORS level
esyms: List Symbol := indexedSymbols("E", divs)\$QAuxiliaryTools
allmons := [monomials erel for erel in erels]
alldegs := [[vector(degree(mon, esyms)::List(ZZ)) for mon in mons] for mons in allmons]
allrdegs := [[d - first degs for d in degs] for degs in alldegs]
allrs := [[members r for r in rdegs] for rdegs in allrdegs]
alllse := [[etaQuotient(level, r)\$SEQUO for r in rs] for rs in allrs];
mx: PP := lcm [lcm [rootOfUnity e for e in lse] for lse in alllse]
pz: PZZ := cyclotomic(mx)\$CyclotomicPolynomialPackage
pq: PQQ := map(n+->monomial(1\$QQ,1\$NN)\$PQQ, c+->c::QQ::PQQ, pz)\$PL
xsym: Symbol := "x"::Symbol
xi := generator()\$CX
allle := [[etaQuotient(e)\$EQX for e in lse] for lse in alllse];
alleas := [[etaQuotient(r, expansions e)\$EQXA for r in rs for e in le] for le in allle for rs in allrs];
[reduce(+,[leadingCoefficient(mon)*ea for mon in mons for ea in eas]) for mons in allmons for eas in alleas]
EOF
}

# default values
if test "$#" -lt 1; then usage; exit 1; fi

cd tmp

N=$1;     shift;
F="etaRelations$N"

echo [CMD=comparerelations][N=$N][F=$F]

if test -z "$N"; then usage; exit 1; fi

fricas_program $N etafiles/Hemmecke/etaRelations$N.input |tee checker$N.input | fricas -nosman
