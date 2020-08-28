#!/bin/bash

function usage {
    cat <<EOF
Usage:
  bin/liddoc.sh foo
  bin/liddoc.sh foo.spad
  bin/liddoc.sh src/foo.spad

extracts the LaTeX document inside )if LiterateDoc ... )endif
of the file src/foo.spad and compiles it with pdflatex and bibtex
inside a temporary directory given by the environment variable TMP.

The script is assumed to be called from the root directory of the project
If the files
  doc/literatedoc.awk
  doc/literatedoc.sty
are not available, the will be downloaded from
  https://raw.githubusercontent.com/hemmecke/fricas/formatted/src/doc/

If TMP is nonempty then the output is compiled in the directory TMP.
Otherwise /tmp is used.
EOF
    exit 1
}

# The directory where we expect literatedoc.awk and literatedoc.sty
P=`pwd`
LITDOC=$P/tmp

function maybe_download {
    L="https://raw.githubusercontent.com/hemmecke/fricas/formatted/src/doc"
    F="/home/hemmecke/g/fricas/src/doc"
    if test ! -r $LITDOC/$1; then
        mkdir -p $LITDOC
        if test -r $F/$1; then
            cp $F/$1 $LITDOC/$1
        else
            curl $L/$1 > $LITDOC/$1
        fi
    fi
}

ME=`basename $0`

# Check whether we are called from the root directory.
if test ! -r bin/$ME; then usage; fi

maybe_download literatedoc.awk
maybe_download literatedoc.sty


if [ -z "$TMP" ]; then TMP=/tmp; fi
if test -s $1; then         # $1 = src/foo.spad
    N=$(basename $1 .spad)
elif test -s src/$1; then   # $1 = foo.spad
    N=$(basename $1 .spad)
elif test -r src/$1.spad; then  # $1 = foo
    N=$1
else
    echo "Error: neither file $1 nor $1.spad nor src/$1 exists."
    echo
    usage
fi

cd $TMP
awk -f $LITDOC/literatedoc.awk $P/src/$N.spad > $N.tex
export TEXINPUTS=.:$P/:$LITDOC/:$TEXINPUTS
export BIBINPUTS=$P/:$BIBINPUTS
pdflatex $N.tex
bibtex $N.aux
makeindex $N.idx
echo "++++++++++++++++++++ LaTeX Warnings ++++++++++++++++++++"
grep -i warning $N.log | sort -u
echo "++++++++++++++++++++ LaTeX Warnings ++++++++++++++++++++"
echo `pwd`/$N.pdf
if ! (ps aux | grep -v grep | grep "okular $N.pdf"); then
    echo start okular
    $EXECUTE okular $N.pdf&
else
    echo okular already running
fi
