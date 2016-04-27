#!/usr/bin/env python2
import heapq
from operator import itemgetter
import sys

import numpy
import h5py
from Bio import SeqIO
import utils


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


def compare(fp, database):
    chunk_size = 10000
    f = h5py.File(database, "r")
    fps = f["fingerprints"]
    counts = f["counts"]
    titles = f["titles"]
    count = utils.cpopcount(fp)
    rankList = RankedList(maxlen=20)
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


def main():
    fastaIn = sys.argv[1]
    database = sys.argv[2]
    with open(fastaIn) as seqFile:
        fasta = next(SeqIO.parse(seqFile, "fasta"))
        fp, count = utils.makeFP(str(fasta.seq), 2**12)
    rankList = compare(fp, database)
    for (i, j) in rankList:
        print(i, j)
    return


if __name__ == "__main__":
    sys.exit(main())
