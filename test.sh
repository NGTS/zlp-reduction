#!/usr/bin/env sh

set -e

OUTPUTDIR=${PWD}/output

setup_environment() {
    export PYTHONPATH=../zlp-script/scripts:$PYTHONPATH
}

setup_outputdir() {
    test -d $OUTPUTDIR && rm -rf $OUTPUTDIR
    mkdir -p $OUTPUTDIR
}

test_create_bias() {
    BIASLIST=$TMPDIR/biaslist.txt
    find testdata/bias -name 'IMAGE*.bz2' > $BIASLIST

    MBIAS=mbias.fits

    python bin/pipebias.py $BIASLIST $MBIAS $OUTPUTDIR
    FILENAME=$OUTPUTDIR/$MBIAS py.test -m bias testing
}

run_test() {
    setup_outputdir
    $1
}

main() {
    setup_environment
    run_test test_create_bias
}

main
