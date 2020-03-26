#!/bin/bash

# Assume that data for modular forms have been obtained by the program
# bin/getlmfdb.sh and have been put into the directory zudilin/.
# Furthermore, we assume that there is a file zudilin/lmfdb.ids that
# contains the LMFDB labels for modular forms. The (for us) relevant
# data for the label $id is stored in the file zudilin/mf-$id.input.

# This script read zudilin/lmfdb.ids and computes via
# input/lmfdb.input for a label $id from the respective file
# zudilin/mf-$id.input the file zudilin/rel-$id.input which contains a
# relation for the modular form in terms of eta quotients in the form
# of Laurent polynomials with variables Ei and with exponent vectors.

# Usage:
#  Call from the root directory of the qeta project.
#  bin/lmfdb.sh id

function dbgPrint { echo "============ $1" >&2; }

if test $# -eq 0; then
    echo "missing the label argument"
    exit 1
fi

id=$1
dbgPrint "$id"

FILE=zudilin/rel-$id

function holomorphic {
    cat <<EOF
)read zudilin/mf-$id.input )quiet
)read input/lmfdb.input )quiet
EOF
}

holomorphic | FRICAS_INITFILE='' fricas -nosman 2>&1 | tee $FILE.tmp
