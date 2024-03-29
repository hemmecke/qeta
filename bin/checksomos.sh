#!/bin/bash

function usageDIR {
    echo "If an argument DIR=/some/path is given, it is interpreted"
    echo "as the name of a directory in which to store the result file."
    echo "Default is DIR=etafiles."
}

function usageVARIANT {
    echo "If an argument VARIANT=[Hemmecke|Radu|Samba] is given, it"
    echo "is interpreted as the variant against which to compare."
    echo "Default is VARIANT=Hemmecke."
}

function usageSOMOS {
    echo "If an argument SOMOS=/path/to/somos is given, it is the path"
    echo "where the somos\$N.input files are stored."
    echo "Default is SOMOS='somos'."
}

function usage {
    echo "Usage:"
    echo "  checksomos.sh N [DIR=etafiles] [VARIANT=Hemmecke]"
    cat <<EOF

The script reads the files $SOMOS/somos\$N.input and a corresponding
file \$DIR/\$VARIANT/etaRelations\$N.input. The script then translates
the Somos-relation into E variables (i.e, from Euler series (with
variables u and q) to eta-functions) and reduces this relation with
respect to the Groebner basis given by etaRelations\$N. This is
(should be) a reduction to zero. The script outputs to stdout
data that contain etaRelations\$N as well as the relations of Somos
in terms of E variables together with their representation in terms
of the Groebner basis.
EOF
    usageDIR
    usageVARIANT
    usageSOMOS
}

function fricas_program {
    LEVEL=$1
    cat <<EOF
)read etacompute
C ==> Integer
PolC ==> Pol C
level := $LEVEL
)read $SOMOS/somos$LEVEL.input
)read $DIR/$VARIANT/etaRelations$LEVEL.input
g := etaRelations$LEVEL;
maxdeg: NN := totalDegree first g
vPrint("maxdeg", maxdeg);
f: XHashTable(Symbol, PolC) := table();
hkeys: List Symbol := keys h;
xkey(k: Symbol, maxdeg: NN): String == (_
    b: ZZ := 10000;_
    s: String := string k;_
    l: ZZ := #s;_
    t: String := "";_
    p1: ZZ := position(char "__", s);_
    p2: ZZ := position(char "__", s, p1+1);_
    p3: ZZ := position(alphabetic(), s, p2+1);_
    if zero? p3 then p3 := l+1 else t := s(p3..l);_
    d: ZZ := parse_integer(s(p1+1..p2-1))\$ScanningUtilities;_
    if d > maxdeg then return "";_
    r: ZZ := parse_integer(s(p2+1..p3-1))\$ScanningUtilities;_
    return concat [string(b^2+d*b+r), t, ".", s]_
);

xkeys: List String := [xkey(k, maxdeg+2) for k in hkeys] ;
skeys: List String := sort [x for x in xkeys | not empty? x];
fkeys: List Symbol := [x(position(char ".", x)\$String+1..#x)::Symbol for x in skeys];
for k in fkeys repeat f(k) := toEta(level, h k)

divs: List ZZ := divisors(level)\$IntegerNumberTheoryFunctions
syms: List Symbol := indexedSymbols("E", divs)\$QAuxiliaryTools
dim: NN := #syms
D ==> HomogeneousDirectProduct(dim, NN);
E ==> Monomials(dim, NN, D, syms)
R ==> PolynomialRing(C, E)
PC ==> PolynomialConversion(C, E, syms)
xnf ==> extendedNormalForm\$QEtaGroebner(C, E);
gsyms: List Symbol := indexedSymbols("g", #g)\$QAuxiliaryTools
toR ==> coerce\$PC
tPrint(x)==display(x::Symbol::OF::Formatter(Format1D));_
printPol(k: Symbol, lsyms: LSym, ldim: NN, p: PolC): Void == (_
    DX := DirectProduct(ldim, NN); _
    EX := Monomials(ldim, NN, DX, lsyms); _
    RX := PolynomialRing(R, EX); _
    r: RX := 0; _
    z: PolC := p; _
    for s in lsyms for i in 1..ldim repeat ( _
        c: PolC := coefficient(p, s, 1); _
        z: PolC := z - c*s; _
        cr: R := toR c; _
        dx: DX := unitVector(i)\$DX; _
        ex: EX := directProduct(dx::Vector(NN)); _
        r := r + monomial(cr, ex)); _
    if not zero? z then (print(k); print(z); error "NONZERO RELATION"); _
    display77(r::OutputForm));

tPrint("-- eta relations --")
for i in 1..#g for p in g repeat vPrint(concat("g", string i), toR p);

tPrint("-- Somos eta relations --");
for k in fkeys repeat vPrint(k, toR(f.k));

tPrint("-- Relation relations --")
for k in fkeys repeat (_
    p: PolC := xnf(f.k, g, syms, k, "g"); _
    lsyms: List Symbol := cons(k, gsyms); _
    ldim: NN := #lsyms; _
    printPol(k, lsyms, ldim, p))
EOF
}

# default values
N=0
DIR=etafiles
VARIANT=Hemmecke
SOMOS=somos

while test -n "$1"; do
    param=$1
    case $param in
        SOMOS=*)
            SOMOS=${param#SOMOS=}
            ;;
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

echo [CMD=checksomos][N=$N][D=$DIR][V=$VARIANT][S=$SOMOS]

if test -z "$N"; then usage; exit 1; fi

fricas_program $N | fricas -nosman
