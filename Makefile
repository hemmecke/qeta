###################################################################
#
# Eta relations
# Copyright 2015-2020,  Ralf Hemmecke <ralf@hemmecke.org>
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
# This file contain links to the source code and documentation.
# Do not change the official variables to something else
# than the official places.

# The official FriCAS homepage. It is supposed that the API description
# lives under "${FRICAS_URL}/api".
FRICAS_URL=https://fricas.github.io

# The official package homepage. It is supposed that the API description
# lives under "${PACKAGE_URL}/api".
PACKAGE_URL=https://hemmecke.github.io/qeta

# Here lives the official git repository of the package.
# It should be possible to say "git clone ${PACKAGE_SOURCE}".
PACKAGE_SOURCE=https://github.com/hemmecke/qeta

# In case we consider another git branch of ${PACKAGE_SOURCE}.
BRANCH=master

# Base source URL into the git repo. Appending the repsective path
# should give a valid URL to view/edit a file.
# Local references must include a absolute path like this:
# PACKAGE_SOURCE_VIEW="file:///home/hemmecke/g/qeta".
PACKAGE_SOURCE_VIEW=${PACKAGE_SOURCE}/blob/${BRANCH}
PACKAGE_SOURCE_EDIT=${PACKAGE_SOURCE}/edit/${BRANCH}
SHOW_ON_GITHUB_URL=${PACKAGE_SOURCE_VIEW}/sphinx/source/{path}
EDIT_ON_GITHUB_URL=${PACKAGE_SOURCE_EDIT}/sphinx/source/{path}
###################################################################
PACKAGE_NAME=QEta
PACKAGE_VERSION=2.1
PACKAGE_TARNAME=qeta
PACKAGE_BUGREPORT=ralf@hemmecke.org
###################################################################
# The following environment variables considered in
# sphinx/source/conf.py, so we export them for sphinx "make html".
export PACKAGE_URL
export FRICAS_URL
export PACKAGE_SOURCE
export PACKAGE_SOURCE_VIEW
export PACKAGE_SOURCE_EDIT
export PACKAGE_NAME
export PACKAGE_VERSION
export PACKAGE_TARNAME
export PACKAGE_BUGREPORT
export SHOW_ON_GITHUB_URL
export EDIT_ON_GITHUB_URL
###################################################################
PROJECT=${PACKAGE_TARNAME}
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
SPADFILES=4ti2 qfunct cachedpow \
  qetagamma0 qetagamma1 \
  qetaalg qetasqrt qetaaux qetaqmev qetaser qetaquotinf qetatool \
  qetasamba \
  qetaicat qetaih qetaihc qetasomos \
  qetapowersamba qetacofactorspace \
  qetaquotsymb qetaquot qetacofactormod qetamodfunexp \
  qetark \
  ivar iffts ffalgclos algclos newtonpuiseux \

PREREQS_SPAD=${patsubst %,%.spad,${SPADFILES}}
# We also add convenience.input and modfuns.input so that we can
# execute .input-test files as Jupyter notebooks in the tmp directory
# without having to take care of the directory.
PREREQS_INPUT=checksomos.input etacompute.input etamacros.input \
  convenience.input modfuns.input
PREREQS_SAGE=etagb.sage
PREREQS=${patsubst %,${TMP}/%,Makefile ${PREREQS_INPUT} ${PREREQS_SPAD} ${PREREQS_SAGE}}

prerequisites: ${PREREQS}

QETAEXTS=aux bbl blg idx ilg ind log out synctex.gz toc
clean:
	-cd ${TMP} && ${MAKE} clean
	rm -f $(patsubst %,qeta.%, ${QETAEXTS})

distclean: clean
	-cd ${TMP} && ${MAKE} distclean
	rm -f qeta.pdf project.pdf

recompile-spad compile-spad doc localdoc github.io-local\
    compute-all eqmev eqig elig er checksomos runfricassomos seg slg ceg clg:
	${MAKE} prerequisites
	cd ${TMP} && ${MAKE} ROOT="${ROOT}" SPADFILES="${SPADFILES}" $@

${TMP}/Makefile: Makefile.sub
	${MKDIR_P} ${TMP}
	cp -a $< $@
${patsubst %,${TPROJECT}.%, bib sty}: ${TPROJECT}.%: ${PROJECT}.%
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
# Compute the eta-quotient relations for (some) entries of the
# lmfdb.org database.

# This target creates lmfdb.ids and the zudilin/mf-*.input files.
zudilin/lmfdb.ids:
	$(MKDIR_P) zudilin
	cd zudilin && ../bin/getlmfdb.sh

zudilin/rel-%.tmp: zudilin/mf-%.input
	bin/lmfdb.sh $*

zudilin/rel-%.input: zudilin/rel-%.tmp
	if grep 'SUCCESS:=true' $< 2>/dev/null; then \
	  awk '/^fpol:=/,/SUCCESS:=true/{print}' $< \
	  | sed '$$d' > $@; else :; fi

IDS=$(shell cat zudilin/lmfdb.ids 2>/dev/null)
RELS=$(patsubst %,zudilin/rel-%.input, ${IDS})
zudilin/allrels: zudilin/lmfdb.ids $(RELS)

zudilin/index.html:
	echo '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">' > $@
	echo '<html>' >>$@
	echo '  <head>' >>$@
	echo '    <meta charset="utf-8">' >>$@
	echo '    <title>Eta-quotient relations for modular form</title>' >>$@
	echo '  </head>' >>$@
	echo '  <body>' >>$@
	echo '    <h1>Eta-quotient relations for modular forms</h1>' >>$@
	echo '    <p>' >>$@
	ls -l zudilin/rel-*.input \
	| sed 's|.* zudilin/||;s|\(rel-\(.*\)\.input\)|<a href="https://www.lmfdb.org/ModularForm/GL2/Q/holomorphic/\2">Modular form \2</a> -- <a href="\1">eta-quotient relation</a><br />|' >>$@
	echo '    </p>' >>$@
	echo '    <hr>' >>$@
	echo '    <address>' >>$@
	echo '      <a href="mailto:hemmecke@risc.jku.at">Ralf Hemmecke</a>'>>$@
	echo '    </address>' >>$@
	echo '  </body>' >>$@
	echo '</html>' >>$@

toweb: zudilin/index.html
	scp $< risc:/home/www/people/hemmecke/qeta/lmfdb/
	scp zudilin/rel-*.input risc:/home/www/people/hemmecke/qeta/lmfdb/

###################################################################
# documentation
# Compile all .spad files to .pdf and join them together.
pdfall: pdf
	pdfjam --fitpaper true --rotateoversize true \
               --outfile project.pdf qeta.pdf \
               ${patsubst %,${TMP}/%.pdf, ${SPADFILES}}

# We generate qeta.pdf in the directory where qeta.tex lives so that
# we can use forward and inverse search.
pdf: ${patsubst %,${TPROJECT}.%, bib sty} ${TPROJECT}abstracts.tex \
     ${patsubst %,${TMP}/%.pdf,${SPADFILES}}
	TEXINPUTS=${TMP}:  pdflatex --synctex=1 ${PROJECT}.tex \
	  && bibtex ${PROJECT}.aux \
	  && makeindex ${PROJECT}

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

###################################################################
# documentation sphinx
# Compile all .spad files to .rst files and run sphinx on them.
# Put the result into the html directory.

.PHONY: html
html localhtml: %html:
	-rm -rf html
	${MAKE} ${*}doc
	cp -R tmp/sphinx/build/html .
