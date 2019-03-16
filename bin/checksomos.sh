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
variables u and q) to eta functions) and reduces this relation with
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
maxdeg: N := totalDegree first g
vPrint("maxdeg", maxdeg);
f: XHashTable(Symbol, PolC) := table();
hkeys: LSym := keys h;
xkey(k: Symbol, maxdeg: N): String == (_
    b: Z := 10000;_
    s: String := string k;_
    l: Z := #s;_
    t: String := "";_
    p1: Z := position(char "__", s);_
    p2: Z := position(char "__", s, p1+1);_
    p3: Z := position(alphabetic(), s, p2+1);_
    if zero? p3 then p3 := l+1 else t := s(p3..l);_
    d: Z := parse_integer(s(p1+1..p2-1))\$ScanningUtilities;_
    if d > maxdeg then return "";_
    r: Z := parse_integer(s(p2+1..p3-1))\$ScanningUtilities;_
    return concat [string(b^2+d*b+r), t, ".", s]_
);

xkeys: List String := [xkey(k, maxdeg+2) for k in hkeys] ;
skeys: List String := sort [x for x in xkeys | not empty? x];
fkeys: LSym := [x(position(char ".", x)\$String+1..#x)::Symbol for x in skeys];
for k in fkeys repeat f(k) := toEta(level, h k)

)set output linear on
)set output algebra off
)set message type off
divs: List Z := divisors(level)\$IntegerNumberTheoryFunctions
syms: LSym := indexedSymbols("E", divs)\$QAuxiliaryTools
dim: N := #syms
D ==> HomogeneousDirectProduct(dim, N);
E ==> Monomials(dim, D, syms)
R ==> PolynomialRing(C, E)
PC ==> PolynomialConversion(C, E, syms)
xnf ==> extendedNormalForm\$QEtaGroebner(C, E);
gsyms: LSym := indexedSymbols("g", #g)\$QAuxiliaryTools
toR ==> coerce\$PC
OF==>OutputForm
display77(x) ==> display((x::OF)::LinearOutputFormat, 77)
vPrint(x,y) ==> display77(hconcat([x::Symbol::OF, " := "::Symbol::OF, y::OF]))
printPol(k: Symbol, lsyms: LSym, ldim: N, p: PolC): Void == (_
    DX := DirectProduct(ldim, N); _
    EX := Monomials(ldim, DX, lsyms); _
    RX := PolynomialRing(R, EX); _
    r: RX := 0; _
    z: PolC := p; _
    for s in lsyms for i in 1..ldim repeat ( _
        c: PolC := coefficient(p, s, 1); _
        z: PolC := z - c*s; _
        cr: R := toR c; _
        dx: DX := unitVector(i)\$DX; _
        ex: EX := directProduct(dx::Vector(N)); _
        r := r + monomial(cr, ex)); _
    if not zero? z then (print(k); print(z); error "NONZERO RELATION"); _
    display77(r::OutputForm));

print("-- eta relations --"::Symbol::OF)
for i in 1..#g for p in g repeat vPrint(concat("g", string i), toR p);

print("-- Somos eta relations --"::Symbol::OF);
for k in fkeys repeat vPrint(k, toR(f.k));

print("-- Relation relations --"::Symbol::OF)
for k in fkeys repeat (_
    p: PolC := xnf(f.k, g, syms, k, "g"); _
    lsyms: LSym := cons(k, gsyms); _
    ldim: N := #lsyms; _
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
