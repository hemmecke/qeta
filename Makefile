###################################################################
#
# Eta relations
# Copyright 2015-2018,  Ralf Hemmecke <ralf@hemmecke.org>
#
###################################################################
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
###################################################################
# Compute the eta relations and generate also intermediate data.
#
# Note that generated files that don't count as "results" will be put
# into the subdirectory "tmp/". That directory can always be removed.
# In fact, the main work will be done via Makefile.sub inside the tmp/
# subdirectory.
###################################################################
MKDIR_P=mkdir -p

# We assume that make is executed from the directory where THIS Makefile
# is located.
ROOT:=${shell pwd}
BIN=${ROOT}/bin

###################################################################
# toplevel targets
all: er
SPADFILES=qfunct cachedpow qetasqrt qetaqmev qetadom qetatool qetasamba \
  qetaradu qetaicat qetaih qeta3hdp qetair qetais qetasomos \
  qetaauxmeq qetapowersamba qetafun qetakolberg

PREREQS_INPUT=checksomos.input etacompute.input etamacros.input
PREREQS_SAGE=etagb.sage
PREREQS_SPAD=${patsubst %,%.spad,${SPADFILES}}
PREREQS=${patsubst %,tmp/%,Makefile ${PREREQS_INPUT} ${PREREQS_SAGE} ${PREREQS_SPAD}}

prerequisites: ${PREREQS}

allall compile-spad eqmev eqig elig er checksomos runfricassomos \
seg slg ceg clg clean distclean:
	${MAKE} prerequisites
	cd tmp && ${MAKE} ROOT="${ROOT}" SPADFILES="${SPADFILES}" $@

tmp/Makefile: Makefile.sub
	${MKDIR_P} tmp
	cp $< $@
tmp/qeta.tex tmp/qeta.bib tmp/qeta.sty: tmp/qeta.%: qeta.%
	${MKDIR_P} tmp
	cp $< $@
${patsubst %,tmp/%,${PREREQS_INPUT}}: tmp/%: input/%
	${MKDIR_P} tmp
	cp $< $@
${patsubst %,tmp/%,${PREREQS_SAGE}}: tmp/%: sagemath/%
	${MKDIR_P} tmp
	cp $< $@
${patsubst %,tmp/%,${PREREQS_SPAD}}: tmp/%: src/%
	${MKDIR_P} tmp
	cp $< $@

###################################################################
# documentation
# Compile all .spad files to .pdf and join them together.
TMP=${ROOT}/tmp
pdfall: pdf
	cd tmp && pdftk qeta.pdf ${patsubst %,%.pdf, ${SPADFILES}} output qetaall.pdf
pdf: ${patsubst %,tmp/qeta.%, tex bib sty} ${patsubst %,tmp/%.pdf,${SPADFILES}}
	cd tmp && pdflatex qeta.tex && bibtex qeta.aux
${patsubst %,tmp/%.pdf,${SPADFILES}}: tmp/%.pdf: src/%.spad
	EXECUTE=: ${BIN}/litdoceta.sh $<
	if grep 'LaTeX Warning: There were undefined references' tmp/$*.log; then \
	    EXECUTE=: ${BIN}/litdoceta.sh $<; \
	fi
	if grep 'LaTeX Warning: .*Rerun' tmp/$*.log; then \
	    EXECUTE=: ${BIN}/litdoceta.sh $<; \
	fi
