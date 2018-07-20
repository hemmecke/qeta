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
PZ ==> SparseUnivariatePolynomial Z;
PQ ==> SparseUnivariatePolynomial Q;
PL ==> PolynomialCategoryLifting(N, SingletonAsOrderedSet, C, PZ, PQ);
CX ==> SimpleAlgebraicExtension(Q, PQ, pq);
LX ==> UnivariateLaurentSeries(CX, xsym, 0);
MZ ==> Matrix Z -- consider only 2x2 matricies
SL2Z ==> MZ -- matrices with determinant = 1
QAuxMEQ ==> QAuxiliaryModularEtaQuotientPackage;
SEQG ==> SymbolicEtaQuotientGamma
MEQ ==> ModularEtaQuotient(Q, mx, CX, xi, LX);
MEQX ==> ModularEtaQuotientExpansions(CX, LX, level);

unityroots(m: P, rs: List List Z): List List P == (_
  divs: List P := [qcoerce(delta)@P for delta in divisors m];_
  cusps: List Q := cuspsOfGamma0(m)$QAuxMEQ;_
  l: List List P := empty(); _
  for r in rs repeat (_
      lp: List P := empty();_
      for cusp in cusps repeat (_
          gamma: SL2Z := cuspToMatrix(m, cusp)$QAuxMEQ;_
          e: SEQG := etaQuotient(m, divs, r, gamma);_
          lp := cons(minRootOfUnity e, lp) _
      );_
      l := cons(lp, l) _
  );_
  l_
);

level := m := $level;
minroots := unityroots(m, eqmevx m)
mx: P := lcm [lcm l for l in minroots]
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

QAMEQP ==> QAuxiliaryModularEtaQuotientPackage
lerr := [r for r in rs | not zero? rStarConditions(m, r)\$QAuxMEQ];
if not empty? lerr then (_
    vPrint("ERROR: exponent vectors", lerr);_
    display("do not correspond to modular functions"::Symbol::OF::LinearOutputFormat, 77))_
else (_
    vPrint("Expansion at cusps", cuspsOfGamma0 m);_
    le := [etaQuotient(m, r)\$MEQ for r in rs];_
    ees := [expansions(e)::MEQX for e in le])

EOF
