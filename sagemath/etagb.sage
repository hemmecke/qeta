#!/usr/bin/env sage

import sys
from sage.all import *

if len(sys.argv) != 5:
    print("Usage: %s <n> <infile> <gens> <outvar>" % sys.argv[0])
    print("Outputs Groebner basis of eta relations of level n.")
    print("If the <gens> parameter contains the word Laurent, then")
    print("the GB computation is done in the Laurent polynomial ring.")
    sys.exit(1)

n = sys.argv[1]
infile = sys.argv[2]
gens = sys.argv[3]
outvar = sys.argv[4]

divs = divisors(int(n))
m = len(divs)
esyms = ['E%d' % i for i in divs]

# If the identifier of the generators contains "Laurent", the GB
# computation is done in the Laurent polynomial ring and then contracted
# to E variables.
laurent = gens.find('Laurent')
if laurent < 0:
    syms = ",".join(esyms)
    ord = 'degrevlex'
else:
    ysyms = ['Y%d' % i for i in divs]
    syms = ",".join(ysyms + esyms)
    ord = 'degrevlex(%d),degrevlex(%d)' % (m,m)

R = eval('PolynomialRing(QQ,"' + syms + '",order="' + ord + '")')
exec(syms + ' = R.gens()')

def ydegree(f):
    d = f.degrees()
    return sum(d[i] for i in range(m))

sage.repl.load.load(infile, globals())

if laurent < 0:
    generators = eval(gens)
else:
    invrelations = [eval('Y%d * E%d - 1' % (i,i)) for i in divs]
    gensred = [g.reduce(invrelations) for g in eval(gens)]
    generators = invrelations + [g for g in gensred if g != 0]

I = Ideal(generators)
time G = I.groebner_basis('libsingular:slimgb')
sys.stdout.write(outvar + ' := ')

if laurent < 0:
    print([p.numerator() for p in G.part(0)])
else:
    print([p.numerator() for p in G.part(0) if ydegree(p)==0])
