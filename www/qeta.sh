#!/bin/bash

# Create qeta.input via
# ./qeta.sh --level=4 --calc=4 --rvectors="[[-8, 0, 8], [8, 0, -8], [8, -24, 16], [-8, 24, -16]]" --gamma="[[1,3],[1,2]]" --teecmd=qeta.input

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

cat <<EOF  | $teecmd | timeout 60s /zvol/fricas/x86_64/bin/fricas -nosman | sed '1,/OUTPUT STARTS HERE/d; /Type:/d; s/([0-9]*) -> //g; /   ([0-9]*)$/d'
)cd $tmp
)r qetalibs
)r etamacros
)set stream calculate $calc

tPrint(x)==display(x::Symbol::OF::LinearOutputFormat, 77);_
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
SEDG ==> SymbolicEtaDeltaGamma;
SEQG ==> SymbolicEtaQuotientGamma;
EQG ==> EtaQuotientGamma(Q, mx, CX, xi, LX);
MEQ ==> ModularEtaQuotient(Q, mx, CX, xi, LX);
MEQX ==> ModularEtaQuotientExpansions(CX, LX, level);

unityroots(m: P, rs: List List Z, gammas: List SL2Z): List List P == (_
  divs: List P := [qcoerce(delta)@P for delta in divisors m];_
  l: List List P := empty(); _
  for r in rs repeat (_
      lp: List P := empty();_
      for g in gammas repeat (_
          e: SEQG := etaQuotient(m, divs, r, g);_
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
  cusps: List Q := cuspsOfGamma0(m)\$QAuxMEQ;_
  for cusp in cusps repeat (_
    g: SL2Z := cuspToMatrix(m, cusp)\$QAuxMEQ;_
    gammas := cons(g, gammas));_
  gammas := reverse! gammas_
) else (_
  gammas: List SL2Z := [matrix $gamma]_
);

rs := $rvectors;
minroots := unityroots(m, rs, gammas)
mx: P := lcm [lcm l for l in minroots]
pz: PZ := cyclotomic(mx)\$CyclotomicPolynomialPackage;
pq: PQ := map(n+->monomial(1\$Q,1\$N)\$PQ, c+->c::Q::PQ, pz)\$PL;
xsym: Symbol := "x"::Symbol;
xi := generator()\$CX;
divs: List P := [qcoerce(d)@P for d in divisors m];
tPrint("OUTPUT STARTS HERE")
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
  llse := [[etaQuotient(m, divs, rr, g)\$SEQG for g in gammas] _
           for rr in rs];_
  tPrint("Interpret resulting record as follows:");_
  tPrint("g_r(trf*tau) = lc * x^xpower * ser");_
  tPrint("where x=q^(1/w).");_
  lle := [[[exponents(se),_
            (g := gamma(se)),_
            width(level, g(2, 1)),_
            leadingCoefficient(e := etaQuotient(se)\$EQG),_
            xExponent(se)/24,_
            expansion e]\$Rec_
           for se in lse] for lse in llse]_
) else (_
  vPrint("Expansion at cusps", cusps);_
  vPrint("Expansion at CUSPS", [cuspToMatrix(m, cusp)\$QAuxMEQ for cusp in cuspsOfGamma0 m]);_
  le := [etaQuotient(m, r)\$MEQ for r in rs];_
  ees := [expansions(e)::MEQX for e in le];_
  [[rr, ex] for rr in rs for ex in ees])

EOF
