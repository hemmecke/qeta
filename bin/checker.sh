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
of the eta quotient corresponding to the exponent vector of the
powerproduct. The resulting series vector should be the zero vector.

The output is written to stdout.
EOF
}

function fricas_program {
    LEVEL=$1
    FILE=$2
    cat <<EOF
)r qetalibs
)r etamacros

S ==> Symbol
PZ ==> SparseUnivariatePolynomial Z
PQ ==> SparseUnivariatePolynomial Q
Rec ==> Record(root: P, elem: PZ)
SEQUO ==> SymbolicEtaQuotient
PL ==> PolynomialCategoryLifting(N, SingletonAsOrderedSet, C, PZ, PQ)
CX ==> SimpleAlgebraicExtension(Q, PQ, pq)
LX ==> UnivariateLaurentSeries(CX, xsym, 0)
EQX ==> EtaQuotientX(Q, mx, CX, xi, LX)
EQXA ==> EtaQuotientExpansionAlgebra(CX, LX, level)

-- compute the basis of eta quotients in terms of expansions
level := $LEVEL
)r ../etafiles/Hemmecke/etaRelations$LEVEL
erels := etaRelations$N

divs: List P := [qcoerce(d)@P for d in divisors level]
esyms: LSym := indexedSymbols("E", divs)\$QAuxiliaryTools
allmons := [monomials erel for erel in erels]
alldegs := [[vector(degree(mon, esyms)::List(Z)) for mon in mons] for mons in allmons]
allrdegs := [[d - first degs for d in degs] for degs in alldegs]
allrs := [[members r for r in rdegs] for rdegs in allrdegs]
alllse := [[etaQuotient(level, divs, r)\$SEQUO for r in rs] for rs in allrs];
mx: P := lcm [lcm [rootOfUnity e for e in lse] for lse in alllse]
pz: PZ := cyclotomic(mx)\$CyclotomicPolynomialPackage
pq: PQ := map(n+->monomial(1\$Q,1\$N)\$PQ, c+->c::Q::PQ, pz)\$PL
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
