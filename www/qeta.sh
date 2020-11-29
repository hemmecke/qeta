#!/bin/bash

# Create qeta.input via
# ./qeta.sh --level=4 --calc=4 --rvectors="[[-8, 0, 8], [8, 0, -8], [8, -24, 16], [-8, 24, -16]]" --gamma="[[1,2],[1,3]]" --teecmd=qeta.input

# Note that the qeta.cgi script should never call THIS shell script with
# the parameter --teecmd.

here=`dirname $0`
tmp=$here/tmp
teecmd="cat"
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
        --gamma=*)
            gamma="${param#--gamma=}"
            ;;
        --teecmd=*)
            teecmd="tee ${param#--teecmd=}"
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

cat <<EOF  | $teecmd | timeout 60s fricas -nosman | sed '1,/OUTPUT STARTS HERE/d; /Type:/d; s/([0-9]*) -> //g; /   ([0-9]*)$/d'
)cd $tmp
)r projectlibs
)r etamacros
)set stream calculate $calc

tPrint(x)==display(x::Symbol::OF::Formatter(Format1D));_
QMEVS==>QEtaQuotientMonoidExponentVectorsStar;
eqmevx==>etaQuotientMonoidExponentVectorsX\$QMEVS;

S ==> Symbol;
EZ ==> Expression Z;
expr x ==> x :: S :: EZ;
PZ ==> SparseUnivariatePolynomial Z;
PQ ==> SparseUnivariatePolynomial Q;
PL ==> PolynomialCategoryLifting(N, SingletonAsOrderedSet, C, PZ, PQ);
CX ==> SimpleAlgebraicExtension(Q, PQ, pq);
LX ==> QEtaLaurentSeries CX;
MZ ==> Matrix Z -- consider only 2x2 matricies
SL2Z ==> MZ -- matrices with determinant = 1

QAuxMEQ ==> QAuxiliaryModularEtaQuotientPackage;
SEDG ==> SymbolicEtaDeltaGamma;
YEQG ==> SymbolicEtaQuotientGamma;
EQG ==> EtaQuotientGamma(Q, mx, CX, xi);
METAQ ==> ModularEtaQuotient(Q, mx, CX, xi);
MODFUNX ==> ModularFunctionExpansions(CX, level);

INTF ==> IntegerNumberTheoryFunctions
DIVISORS m ==>  [qcoerce(d)@P for d in divisors(m)$INTF]

unityroots(m: P, rs: List List Z, gammas: List SL2Z): List List P == (_
  divs: List P := DIVISORS m;_
  l: List List P := empty(); _
  for r in rs repeat (_
      lp: List P := empty();_
      for g in gammas repeat (_
          e: YEQG := etaQuotient(m, divs, r, g);_
          lp := cons(minRootOfUnity e, lp) _
      );_
      l := cons(lp, l) _
  );_
  l_
);

level := m := $level;
expansionAtAllCusps? := empty? "$gamma";
gammas: List SL2Z := empty();
-- Expand at all cusps if no gamma was given.
if (expansionAtAllCusps?) then (_
  cusps: List Q := cuspsOfGamma0(m)\$QAuxMETAQ;_
  for cusp in cusps repeat (_
    g: SL2Z := cuspToMatrix(m, cusp)\$QAuxMETAQ;_
    gammas := cons(g, gammas));_
  gammas := reverse! gammas_
) else (_
  gammas: List SL2Z := [matrix $gamma]_
);


rs := $rvectors;
if not one?(det:=determinant first gammas) then (_
   tPrint("OUTPUT STARTS HERE");_
   vPrint("gamma", first gammas);_
   vPrint("Error: Determinant of gamma is not 1. det(gamma)", det);_
   systemCommand("quit"))

minroots := unityroots(m, rs, gammas)
mx: P := lcm [lcm l for l in minroots]
pz: PZ := cyclotomic(mx)\$CyclotomicPolynomialPackage;
pq: PQ := map(n+->monomial(1\$Q,1\$N)\$PQ, c+->c::Q::PQ, pz)\$PL;
xsym: Symbol := "x"::Symbol;
xi := generator()\$CX;
divs: List P := DIVISORS m;

tPrint("OUTPUT STARTS HERE")
if not one?(det:=determinant first gammas) then (_
   vPrint("gamma", first gammas);_
   vPrint("Error: Determinant of gamma is not 1. det(gamma)", det);_
   systemCommand("quit"))

vPrint("level", level)
vPrint("divisors", divs)
vPrint("exponent vectors (list of r-vectors) rs", rs)
vPrint("maximal root of unity", mx)
if mx > 2 then _
  vPrint("The symbol ? corresponds to the n-th root of unity where n", mx)
lerr := [r for r in rs | not zero? rStarConditions(m, r)\$QAuxMEQ];

Rec ==> Record(r: List Z, trf: SL2Z, w: Z, lc: CX, xpower: Q, ser: LX)
if not empty? lerr or not expansionAtAllCusps? then (_
  vPrint("Non-modular quotients", lerr);_
  if expansionAtAllCusps? then vPrint("Expansion at cusps", cusps);_
  vPrint("Expansion at gammas", gammas);_
  llse := [[etaQuotient(m, divs, rr, g)\$YEQG for g in gammas] _
           for rr in rs];_
  tPrint("Interpret resulting record as follows:");_
  tPrint("g_r(trf*tau) = lc * x^xpower * ser");_
  tPrint("where x=q^(1/w).");_
  lle := [[[exponents(se),_
            (g := gamma(se)),_
            width(level, g(2, 1)),_
            leadingCoefficient(e := etaQuotient(se)\$EQG),_
            xExponent(se)/24,_
            eulerExpansion e]\$Rec_
           for se in lse] for lse in llse]_
) else (_
  vPrint("Expansion at cusps", cusps);_
  vPrint("Expansion at CUSPS", [cuspToMatrix(m, cusp)\$QAuxMEQ for cusp in cuspsOfGamma0 m]);_
  le := [etaQuotient(m, r)\$METAQ for r in rs];_
  ees := [expansions(e)::METAQX for e in le];_
  [[rr, ex] for rr in rs for ex in ees])

EOF
