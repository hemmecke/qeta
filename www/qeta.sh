#!/bin/bash

here=`dirname $0`
tmp=$here/qeta/tmp

# Check the parameters of the script.

while test -n "$1"; do
    param=$1
    case $param in
        --level=*)
            level="${param#--level=}"
            ;;
        --calc=*)
            calc="${param#--calc=}"
            ;;
        --rvectors=*)
            rvectors="${param#--rvectors=}"
            ;;
        *)
            echo "Unknown option or parameter"
            echo "$param"
            exit 1
            ;;
    esac
    shift
done

#echo "DIRNAME = $here"
#echo "level = $level"
#echo "stream calculate = $calc"
#echo "rvectors = $rvectors"

cat <<EOF  | timeout 60s /zvol/fricas/x86_64/bin/fricas -nosman | sed '1,/OUTPUT STARTS HERE/d; /Type:/d; s/([0-9]*) -> //g; /   ([0-9]*)$/d'
)cd $tmp
)r qetalibs
)r etamacros
)set stream calculate $calc

QMEVS==>QEtaQuotientMonoidExponentVectorsStar;
eqmevx==>etaQuotientMonoidExponentVectorsX\$QMEVS;

S ==> Symbol;
EZ ==> Expression Z;
expr x ==> x :: S :: EZ;
SymEtaMat ==> Record(symetaquo: SymbolicEtaQuotient, data: Matrix EZ);
PL ==> PolynomialCategoryLifting(N, SingletonAsOrderedSet, C, PZ, PQ);
CX ==> SimpleAlgebraicExtension(Q, PQ, pq);
LX ==> UnivariateLaurentSeries(CX, xsym, 0);
MEQ ==> ModularEtaQuotient(Q, mx, CX, xi, LX);
MEQXA ==> ModularEtaQuotientExpansionAlgebra(CX, LX, level);

PZ ==> SparseUnivariatePolynomial Z;
PQ ==> SparseUnivariatePolynomial Q;
Rec ==> Record(root: P, elem: PZ);

unityroots(m: P): List P == (_
  divs: List P := [qcoerce(delta)@P for delta in divisors m];_
  rs := eqmevx m;_
  l: List P := empty(); _
  for r in rs repeat (_
    e := etaQuotient(m, divs, r)\$SymbolicEtaQuotient;_
    l := cons(rootOfUnity e, l) _
  );_
  l_
);

level := m := $level;
mx: P := lcm unityroots(m);
pz: PZ := cyclotomic(mx)\$CyclotomicPolynomialPackage;
pq: PQ := map(n+->monomial(1$Q,1$N)\$PQ, c+->c::Q::PQ, pz)\$PL;
xsym: Symbol := "x"::Symbol;
xi := generator()\$CX;
divs: List P := [qcoerce(d)@P for d in divisors m];
rs := $rvectors;

vPrint("OUTPUT STARTS HERE", level)
vPrint("level", level)
vPrint("divisors", divs)
vPrint("exponent vectors", rs)
vPrint("maximal root of unity", mx)
vPrint("Expansion at cusps", cuspsOfGamma0 m)
QAMEQP ==> QAuxiliaryModularEtaQuotientPackage
lerr := [r for r in rs | not zero? rStarConditions(m, r)$QAMEQP];
if not empty? lerr then (_
    vPrint("ERROR: exponent vectors", lerr);_
    display("do not correspond to modular functions"::Symbol::OF::LinearOutputFormat, 77))_
else (_
    lse := [etaQuotient(m, divs, r)\$SymbolicEtaQuotient for r in rs];_
    le := [etaQuotient(e)\$MEQ for e in lse];_
    eas := [etaQuotient(r, expansions e)\$MEQXA for e in le for r in rs];_
    ords := [qetaGrades ea for ea in eas];_
    eas)

EOF
