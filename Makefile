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
PROJECT=qeta
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
TMP=tmp
LITDOC=${ROOT}/bin/litdoc.sh
TPROJECT=${TMP}/${PROJECT}

###################################################################
# toplevel targets
all: compile-spad
# The files in SPADFILES_OLD are here only for historical reasons.
# They are not used or maintained anymore.
SPADFILES_OLD = qetaradu qeta3hdp qetair qetais
SPADFILES=4ti2 qfunct cachedpow \
  qetaalg qetasqrt qetaqmev qetadom qetatool \
  qetasamba \
  qetaicat qetaih qetaihc qetasomos \
  qetaauxmeq qetapowersamba qetakolberg qetafun
PREREQS_SPAD=${patsubst %,%.spad,${SPADFILES}}
PREREQS_INPUT=checksomos.input etacompute.input etamacros.input
PREREQS_SAGE=etagb.sage
PREREQS=${patsubst %,${TMP}/%,Makefile ${PREREQS_INPUT} ${PREREQS_SPAD} ${PREREQS_SAGE}}

prerequisites: ${PREREQS}

recompile-spad compile-spad clean distclean html github.io-local\
    compute-all eqmev eqig elig er checksomos runfricassomos seg slg ceg clg:
	${MAKE} prerequisites
	cd ${TMP} && ${MAKE} ROOT="${ROOT}" SPADFILES="${SPADFILES}" $@

${TMP}/Makefile: Makefile.sub
	${MKDIR_P} ${TMP}
	cp -a $< $@
${patsubst %,${TPROJECT}.%, tex bib sty}: ${TPROJECT}.%: ${PROJECT}.%
	${MKDIR_P} ${TMP}
	cp -a $< $@
${patsubst %,${TMP}/%,${PREREQS_INPUT}}: ${TMP}/%: input/%
	${MKDIR_P} ${TMP}
	cp -a $< $@
${patsubst %,${TMP}/%,${PREREQS_SPAD}}: ${TMP}/%: src/%
	${MKDIR_P} ${TMP}
	cp -a $< $@
${patsubst %,${TMP}/%,${PREREQS_SAGE}}: ${TMP}/%: sagemath/%
	${MKDIR_P} ${TMP}
	cp -a $< $@

###################################################################
# documentation
# Compile all .spad files to .pdf and join them together.
pdfall: pdf
	cd ${TMP} && \
	pdfjoin --outfile project.pdf qeta.pdf ${patsubst %,%.pdf, ${SPADFILES}}

pdf: ${patsubst %,${TPROJECT}.%, tex bib sty} ${TPROJECT}abstracts.tex \
     ${patsubst %,${TMP}/%.pdf,${SPADFILES}}
	cd ${TMP} && pdflatex ${PROJECT}.tex && bibtex ${PROJECT}.aux

${TPROJECT}abstracts.tex: ${patsubst %,${TMP}/%, ${PREREQS_SPAD}}
	(echo '\\begin{description}'; \
	for f in $^; do \
	    b=$$(echo $$f | sed 's|${TMP}/||'); \
	    echo "\\item[$$b:]"; \
	    awk '/^\\begin{abstract}/,/\\end{abstract}/ {print}' $$f \
	    | grep -Ev '^\\begin{abstract}|^\\end{abstract}'; \
	done; \
	echo '\\end{description}') \
	> $@

${patsubst %,${TMP}/%.pdf,${SPADFILES}}: ${TMP}/%.pdf: src/%.spad
	EXECUTE=: ${LITDOC} $<
	if grep 'LaTeX Warning: There were undefined references' ${TMP}/$*.log;\
	    then EXECUTE=: ${LITDOC} $<; fi
	if grep 'LaTeX Warning: .*Rerun' ${TMP}/$*.log; \
	    then EXECUTE=: ${LITDOC} $<; fi
