#!/bin/bash

# Get data of for the coefficients of modular forms corresponding
# to the 200 endtries of
# https://www.lmfdb.org/EllipticCurve/Q/hst=List&conductor=1-300
# of the "LMFDB - The L-functions and Modular Forms Database".

# Usage:
#  Go to some directory and then call bin/getlmfdb.sh.

function download_coefficients {
    url=$1
    echo "$url"
}

LMFDB='https://www.lmfdb.org'
ECQURL="${LMFDB}/EllipticCurve/Q"
BASEURL="${ECQURL}/?hst=List&conductor=1-300&start="
MODFORM='ModularForm/GL2/Q/holomorphic'
MODFORMSAGE="${LMFDB}/${MODFORM}/download_qexp"

function get_list {
    echo "======= $BASEURL$1" >&2
    curl "$BASEURL$1" 2>/dev/null \
        | grep -A1 '^<tr>$' \
        | grep EllipticCurve \
        | sed 's|.*href="/EllipticCurve/Q/||;s|">.*||'
}

function get_urls {
    get_list 0
    get_list 50
    get_list 100
    get_list 150
}

function get_ids {
    get_urls | while read url; do
        echo =========== $url >&2
        curl ${ECQURL}/${url} \
            | grep "\"/${MODFORM}/.*\">Modular form " \
            | sed "s|.*href=\"/${MODFORM}/||;s|/\">Modular.*||" \
            | sed 's|/|.|g'
    done | sort | uniq
}

if test -r lmfdb.ids; then
    echo "lmfdb.ids already exists." >&2
else
    get_ids > lmfdb.ids
fi

cat lmfdb.ids | while read id; do
    echo ============ $id >&2
    curl "${MODFORMSAGE}/$id" > "mf-$id.sage"
    level=$(echo $id | sed 's|\..*||')
    weight=$(echo $id | sed 's|[^.]*\.\([0-9]*\)\..*|\1|')
    echo "lvl := $level" > "mf-$id.input"
    echo "wght := $weight" >> "mf-$id.input"
    (echo "load(\"mf-$id.sage\");f=make_data();[f[i] for i in range(0,1000)]")\
    | sage \
    | awk '/^$/{next}/^sage: /,/^sage: Exiting/ {print}'\
    | sed 's|,$|,_|; s|[]]$|];|; /sage: Exiting.*/d; s|^sage: |coefs := _\n |'\
    >> "mf-$id.input"
done

exit


# Unused...
get_urls | while read url; do
    id=$(echo $url | sed 's|/|.|;s|/||')
    echo $id
    QEXPCOEFFICIENTS="${ECQURL}/download_qexp/$id/1000"
    f="mf-$id.input"
    echo "-- $QEXPCOEFFICIENTS" > $f
    echo "coeffs := [_" >> $f
    curl "$QEXPCOEFFICIENTS" >> $f
    echo "];" >> $f
done
