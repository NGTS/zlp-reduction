#!/usr/bin/env sh

set -e

OUTPUTDIR=${PWD}/output

setup_outputdir() {
    test -d $OUTPUTDIR && rm -rf $OUTPUTDIR
    mkdir -p $OUTPUTDIR
}

setup_environment() {
    export PYTHONPATH=../zlp-script/scripts:$PYTHONPATH
    setup_outputdir
}

test_create_bias() {
    BIASLIST=$TMPDIR/biaslist.txt
    find testdata/bias -name 'IMAGE*.bz2' > $BIASLIST

    MBIAS=mbias.fits

    python bin/pipebias.py $BIASLIST $MBIAS $OUTPUTDIR

    FILENAME=$OUTPUTDIR/$MBIAS py.test -m bias testing
}

test_create_dark() {
    DARKLIST=$TMPDIR/darklist.txt
    find testdata/dark -name 'IMAGE*.bz2' > $DARKLIST

    MDARK=mdark.fits

    python bin/pipedark.py $DARKLIST $MBIAS $MDARK $OUTPUTDIR

    FILENAME=$OUTPUTDIR/$MDARK py.test -m dark testing
}

main() {
    setup_environment
    test_create_bias
    test_create_dark
}

main
