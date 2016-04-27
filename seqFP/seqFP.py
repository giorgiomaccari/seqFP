from __future__ import division, absolute_import, print_function

import argparse
import heapq
from operator import itemgetter
import sys

import numpy
import h5py
from Bio import SeqIO

from . import utils
__all__ = ["compare", "createDB"]


class RankedList(list):
    def __init__(self, *args, **kwargs):
        super(list, self).__init__(*args)
        self._maxlen = kwargs.get("maxlen", 10)
        heapq.heapify(self)

    def append(self, new):
        if self.__len__() >= self._maxlen:
            heapq.heappushpop(self, new)
        else:
            heapq.heappush(self, new)

    def extend(self, new):
        for i in heapq.nlargest(self._maxlen, new, itemgetter(0)):
            self.append(i)


def compare(seq, database, outlen=20):
    chunk_size = 10000
    f = h5py.File(database, "r")
    fps = f["fingerprints"]
    counts = f["counts"]
    titles = f["titles"]
    fp, count = utils.makeFP(seq, f.attrs['fpsize'])
    rankList = RankedList(maxlen=outlen)
    for i in range(0, fps.shape[0], chunk_size):
        tanimotos = utils.tanimoto_multi(fp,
                                         fps[i:i+chunk_size],
                                         count,
                                         counts[i:i+chunk_size])
        rankList.extend(zip(tanimotos, titles[i:i+chunk_size]))
    rankList = sorted(rankList,
                      key=itemgetter(0),
                      reverse=True)
    f.close()
    return rankList


def createDB(sequences, fp_size=2**12, outfile="fingerprints.hdf5"):
    f = h5py.File(outfile, "w")
    f.attrs['file_name'] = outfile
    f.attrs['HDF5_Version'] = h5py.version.hdf5_version
    f.attrs['h5py_version'] = h5py.version.version
    f.attrs['fpsize'] = fp_size
    f.attrs['fpInts'] = int(numpy.ceil(fp_size / 32))
    f.attrs['numOfSequences'] = 0
    fps = f.create_dataset("fingerprints",
                           (0, f.attrs['fpInts']),
                           maxshape=(None, f.attrs['fpInts']),
                           dtype='u4')
    cnt = f.create_dataset("counts",
                           (0, ),
                           maxshape=(None, ),
                           dtype='u4')
    tit = f.create_dataset("titles",
                           (0, ),
                           maxshape=(None, ),
                           dtype='S50')

    with open(sequences) as seqFile:
        for ID, fasta in enumerate(SeqIO.parse(seqFile, "fasta")):
            fp, count = utils.makeFP(str(fasta.seq), fp_size)
            f.attrs['numOfSequences'] = ID + 1
            fps.resize(ID + 1, axis=0)
            cnt.resize(ID + 1, axis=0)
            tit.resize(ID + 1, axis=0)
            fps[ID] = fp
            cnt[ID] = count
            tit[ID] = fasta.id.encode('UTF-8')[:50]
    f.close()
    return


def compareCLI(argv=None):
    if argv is None:
        argv = sys.argv[1:]
    parser = argparse.ArgumentParser(
      prog="compareFP",
      description="""
        Compare a protein sequence to a database of
        precomputed fingerprints""",
      epilog="Copyright Maccari Giorgio 2016")
    parser.add_argument('-s', '--sequence', required=True)
    parser.add_argument('-d', '--database', required=True)
    parser.add_argument('-l', '--outlen', type=int, default=20)
    args = parser.parse_args(argv)
    fastaIn = args.sequence
    database = args.database
    outlen = args.outlen
    with open(fastaIn) as seqFile:
        fasta = next(SeqIO.parse(seqFile, "fasta"))
    rankList = compare(str(fasta.seq), database, outlen)
    for (i, j) in rankList:
        print(i, j)
    return 0

def createDBCLI(argv=None):
    if argv is None:
        argv = sys.argv[1:]
    parser = argparse.ArgumentParser(
      prog="createDB",
      description="""
        Create a database of fingerprints from a set of
        protein sequences.""",
      epilog="Copyright Maccari Giorgio 2016")
    parser.add_argument('-s', '--sequences', required=True)
    parser.add_argument('-d', '--database', required=True)
    parser.add_argument('-S', '--fpsize',
                        default = 2**12, type=int)
    args = parser.parse_args(argv)
    createDB(args.sequences, args.fpsize, args.database)
    return 0
