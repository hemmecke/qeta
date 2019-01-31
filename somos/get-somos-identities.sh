#!/bin/sh

# Running this script downloads the L*.txt files as well as eta07.gp and
# Somos-level*.gp from the Website of Somos.
# From the .gp files, we then compute somos*.input files

somosurl="http://eta.math.georgetown.edu"
#somosurl="https://web.archive.org/web/20180903181137/http://eta.math.georgetown.edu"

HERE=`pwd`

curl $somosurl/etal/index.html > data/index.html
IDS=$(grep '">level' data/index.html | sed 's/.*level//;s/<.*//')

for n in $IDS; do
    echo $n;
    (cd data; wget -c $somosurl/etal/L$n.txt)
done;

curl $somosurl/eta07.gp > data/Somos-eta07.gp

# First we create a file somos.input, that contains the relations from Somos
# but in a format that can be read by FriCAS.
# Reading that file should be done as follows:
# fricas (1) -> h: XHashTable(Symbol, Polynomial(Integer)) := table();
# fricas (2) -> )read somos.input

awk '/^[qtx][0-9]*_/ {sub(/^/, "h("); sub(/ *= *\+/, ") := "); print; next} {print "--" $0}' data/Somos-eta07.gp > data/somos.input

# We also generate smaller files that can be read separately. One file per level.
LEVELS=$(grep '^h(' data/somos.input | sed 's/h([qtx]//;s/_.*//' | sort -n -u)
for l in $LEVELS; do
    echo === Level = $l ===
    F=data/somos$l.input
    echo 'h: XHashTable(Symbol, Polynomial(Integer)) := table();' > $F
    grep "^h(.${l}_" data/somos.input >> $F
    echo "h$l: XHashTable(Symbol, Polynomial(Integer)) := h;" >> $F
done

# There are some relations that are not in eta07.gp (and not yet in somos.input).
# These are relations for bigger squares of primes.
# We create here somos*.input for each of the following levels and also append
# the relations to the file somos.input so that somos.input will contain all
# known relations from Somos.
LEVELS="121 169 289 361"
for l in $LEVELS; do (
    cd data;
    echo "=== Somos Level = $l ===";
    curl $somosurl/etaL/level$l.gp > Somos-level$l.gp;
    $HERE/somos2input.sh Somos-level$l.gp > Somos-level$l.input;
    echo 'h: XHashTable(Symbol, Polynomial(Integer)) := table();' > somos$l.input;
    cat <<EOF | fricas -nosman | sed ':a;N;$!ba;s/_\n//g' | grep -- '-> -- h' | sed 's/^.*-> -- //' | tee -a somos$l.input >> somos.input
)set output algebra off
)set output linear on
)set message type off
N ==> NonNegativeInteger
Z ==> Integer
LSym ==> List Symbol
Pol ==> Polynomial Z
OF ==> OutputForm
)r Somos-level$l
level := p*p
divs: List Z := divisors(level)$IntegerNumberTheoryFunctions
usyms: LSym := [concat("u", convert(i)@String)::Symbol for i in divs]
syms: LSym := cons("q"::Symbol, usyms)
z: Pol := 0
for x in idpp repeat (_
    co: Z := first x; _
    le: List Record(k: Symbol, c: N) := _
        [[s, qcoerce(n)@N] for s in syms for n in rest x]; _
    ex: IndexedExponents(Symbol) := [le]; _
    z := z + monomial(co, ex));
tdeg := totalDegree(z, usyms);
rdivs: List Z := cons(-24, divs);
RSZ ==> Record(key:Symbol,entry:Z);
X ==> XHashTable(Symbol,Z);
lkv: List(RSZ) := [[v,r]@RSZ for v in syms for r in rdivs];
h: X := table(lkv);
v:=[listOfTerms degree(m) for m in monomials z];
w := removeDuplicates [reduce(_+,[h(kv.k)*(kv.c) for kv in x],0) for x in v];
rk: Z := first w;
s: String := concat(["-- h(x${l}__", string(tdeg), "__", string(rk), ") := "]);
txt: OF := hconcat [s::Symbol::OF, z::OF, ";"::Symbol::OF];
display(txt::LinearOutputFormat, 77)
EOF
    echo "h$l: XHashTable(Symbol, Polynomial(Integer)) := h;" >> somos$l.input
) done
