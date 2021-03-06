import math
import sys
import os
import numpy as np
from astropy.io import fits as pyfits
from extract_overscan import extract_overscan
from pipeutils import open_fits_file

inlist = str(sys.argv[1])
biasname = str(sys.argv[2])
darkname = str(sys.argv[3])
outdir = str(sys.argv[4])+'/'

biasname = outdir+biasname

os.system('rm -f '+outdir+'dsorted*')

def darkmaker():
    

    with open_fits_file(biasname) as hdulist:
        bias = hdulist[0].data
    position = 0
    i = 1
    for line in file(inlist):
        fname = outdir+'dsorted'+"{0:03d}".format(position)
        f = open(fname, 'a')
        f.write(line)
        f.close()
        if i == 50:
            i = 0
            position += 1
        i += 1

    os.system('ls '+outdir+'dsorted* >removeindexlist.dat')


    i = 1

    for line in file('removeindexlist.dat'):

        datamatrix = []
        mastermatrix = []
        call = line.strip('\n')
        for line in file(call):
            line = line.strip()
            with open_fits_file(line) as hdulist:
                overscan = extract_overscan(hdulist)
                data = hdulist[0].data[0:2048,20:2068]
                exposure = hdulist[0].header['exposure']
            corrected = (data-np.median(overscan)-bias)/exposure
            datamatrix.append(corrected)
        print np.shape(datamatrix)
        master = np.median(datamatrix, axis=0)
        print i
        mastermatrix.append(master)
        i += 1

    print 'averaging'
    print np.shape(mastermatrix)
    dark = np.mean(mastermatrix, axis=0)
    
    phdu = pyfits.PrimaryHDU(dark)

    outname = outdir+darkname
    command = 'rm -f '+outname
    os.system(command)
    phdu.writeto(outname)

    os.system('rm -f removeindexlist.dat '+outdir+'dsorted*')


darkmaker()
