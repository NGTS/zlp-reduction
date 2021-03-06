#!/usr/bin/env sh

set -e

OUTPUTDIR=${PWD}/output
SMAP=${PWD}/testdata/smap.fits

setup_outputdir() {
    test -d $OUTPUTDIR && rm -rf $OUTPUTDIR
    mkdir -p $OUTPUTDIR
}

setup_environment() {
    export PYTHONPATH=../zlp-script/scripts:$PYTHONPATH
}

test_create_bias() {
    BIASLIST=$TMPDIR/biaslist.txt
    find testdata/bias -name 'IMAGE*.bz2' > $BIASLIST

    MBIAS=mbias.fits

    python bin/pipebias.py $BIASLIST $MBIAS $OUTPUTDIR

    FILENAME=$OUTPUTDIR/$MBIAS py.test -m bias
}

test_create_dark() {
    DARKLIST=$TMPDIR/darklist.txt
    find testdata/dark -name 'IMAGE*.bz2' > $DARKLIST

    MDARK=mdark.fits

    python bin/pipedark.py $DARKLIST $MBIAS $MDARK $OUTPUTDIR

    FILENAME=$OUTPUTDIR/$MDARK py.test -m dark
}

test_create_flat() {
    FLATLIST=$TMPDIR/flatlist.txt
    find testdata/flat -name 'IMAGE*.bz2' > $FLATLIST

    MFLAT=mflat.fits
    SMAPNAME=smap.fits
    cp $SMAP $OUTPUTDIR/$SMAPNAME

    python bin/pipeflat.py $FLATLIST $MBIAS $MDARK $SMAPNAME $MFLAT $OUTPUTDIR

    FILENAME=$OUTPUTDIR/$MFLAT py.test -m flat
}

test_reduce_files() {
    SCIENCELIST=$TMPDIR/sciencelist.txt
    find testdata/source -name 'IMAGE*.bz2' > $SCIENCELIST

    python bin/pipered.py $SCIENCELIST $MBIAS $MDARK $SMAPNAME $MFLAT $OUTPUTDIR $OUTPUTDIR
    py.test -m reduction
}

test_flat_already_exists() {
    FLATLIST=$TMPDIR/flatlist.txt
    find testdata/flat -name 'IMAGE*.bz2' > $FLATLIST

    MFLAT=mflat.fits
    SMAPNAME=smap.fits
    cp $SMAP $OUTPUTDIR/$SMAPNAME

    # Ensure the file already exists
    touch $OUTPUTDIR/$MFLAT
    python bin/pipeflat.py $FLATLIST $MBIAS $MDARK $SMAPNAME $MFLAT $OUTPUTDIR

    FILENAME=$OUTPUTDIR/$MFLAT py.test -m flat
}

main() {
    setup_environment
    setup_outputdir
    test_create_bias
    test_create_dark
    test_create_flat
    test_reduce_files
    test_flat_already_exists
}

main
