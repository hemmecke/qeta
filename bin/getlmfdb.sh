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

get_urls | while read url; do
    id=$(curl ${ECQURL}/${url} \
        | grep "\"/${MODFORM}/.*\">Modular form " \
        | sed "s|.*href=\"/${MODFORM}/||;s|/\">Modular.*||" \
        | sed 's|/|.|g')
    echo ============ $id
    curl "${MODFORMSAGE}/$id" > "mf-$id.sage"
    ( echo "load(\"mf-$id.sage\")"; echo "make_data()" ) \
    | sage \
    | grep -A1 'In [[]2[]]:' \
    | sed 's|$|;|;s|^In.*|ff := _|' > "mf-$id.input"
done

exit

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
