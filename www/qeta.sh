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

# cat <<EOF  | $teecmd | timeout 60s fricas -nosman | sed '1,/OUTPUT STARTS HERE/d; /Type:/d; s/([0-9]*) -> //g; /   ([0-9]*)$/d'
cat <<EOF  | $teecmd | timeout 60s fricas -nosman | sed '1,/OUTPUT STARTS HERE/d; /Type:/d; s/([0-9]*) -> //g; /   ([0-9]*)$/d'
)cd $tmp
)r projectlibs
)r etamacros
)set stream calculate $calc

tPrint(x)==display(x::Symbol::OF::Formatter(Format1D));_

expr x ==> x :: Symbol :: Expression(ZZ);
PZZ ==> SparseUnivariatePolynomial ZZ;
PQQ ==> SparseUnivariatePolynomial QQ;
PL ==> PolynomialCategoryLifting(NN, SingletonAsOrderedSet, ZZ, PZZ, PQQ);
CX ==> SimpleAlgebraicExtension(QQ, PQQ, pq);

unityroots(m: PP, rs: List List ZZ, gammas: List SL2Z): List List PP == (_
  l: List List PP := empty(); _
  for r in rs repeat (_
      lp: List PP := empty();_
      for g in gammas repeat (_
          e: YEQG := etaQuotient(m, r, g);_
          lp := cons(minimalRootOfUnity e, lp) _
      );_
      l := cons(lp, l) _
  );_
  l_
);

level := $level;
expansionAtAllCusps? := empty? "$gamma";
gammas: List SL2Z := empty();
-- Expand at all cusps if no gamma was given.
if (expansionAtAllCusps?) then (_
  spitzen: List Cusp := cusps()\$GAMMA0(level);_
  for cusp in spitzen repeat (_
    g: SL2Z := cuspToMatrix(cusp)\$GAMMA0(level);_
    gammas := cons(g, gammas));_
  gammas := reverse! gammas_
) else (_
  gammas: List SL2Z := [matrix $gamma]_
);


rs := $rvectors;
if not one?(det:=determinant first gammas) then (_
   tPrint("OUTPUT STARTS HERE");_
   cPrint("gamma", first gammas);_
   cPrint("Error: Determinant of gamma is not 1. det(gamma)", det);_
   systemCommand("quit"))

minroots := unityroots(level, rs, gammas)
xiord: PP := lcm [lcm l for l in minroots]
pz: PZZ := cyclotomic(xiord)\$CyclotomicPolynomialPackage;
pq: PQQ := map(n+->monomial(1\$QQ,1\$NN)\$PQQ, c+->c::QQ::PQQ, pz)\$PL;
xsym: Symbol := "x"::Symbol;
xi := generator()\$CX;

tPrint("OUTPUT STARTS HERE")
if not one?(det:=determinant first gammas) then (_
   vPrint("gamma", first gammas);_
   vPrint("Error: Determinant of gamma is not 1. det(gamma)", det);_
   systemCommand("quit"))

vPrint("level", level)
vPrint("exponent vectors (list of r-vectors) rs", rs)
vPrint("maximal root of unity", xiord)
if xiord > 2 then _
  vPrint("The symbol ? corresponds to the n-th root of unity where n", xiord)
lerr := [r for r in rs | not modularGamma0?(level, r)\$QETAAUX];

Rec ==> Record(r: List ZZ, trf: SL2Z, w: ZZ, ser: L1 CX)
if not empty? lerr or not expansionAtAllCusps? then (_
  vPrint("Non-modular quotients", lerr);_
  if expansionAtAllCusps? then vPrint("Expansion at cusps", spitzen);_
  vPrint("Expansion at gammas", gammas);_
  llse := [[etaQuotient(level, rr, g)\$YEQG for g in gammas] _
           for rr in rs];_
  tPrint("Interpret resulting record as follows:");_
  tPrint("g_r(trf*tau) = x^xpower * ser");_
  tPrint("where x=q^(1/w).");_
  lle := [[(g := gamma se;_
            w := WIDTH0(level, g);_
            lx := laurentExpansion(se, w)\$QELX(QQ,CX);_
            [exponents se, g, w, lx]\$Rec)_
           for se in lse] for lse in llse]_
) else (_
  vPrint("Expansion at cusps", spitzen);_
  vPrint("Expansion at CUSPS", [cuspToMatrix(cusp)\$GAMMA0(level) for cusp in spitzen]);_
  le := [etaQuotient(level, r)\$QELX(QQ,CX) for r in rs];_
  ees := [EXPANDn e for e in le];_
  [[rr, ex] for rr in rs for ex in ees])

EOF
