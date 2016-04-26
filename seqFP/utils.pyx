"""
Compile with gcc flag -mpopcnt
"""
import numpy as np
cimport numpy as np
from cutils cimport FP
cimport cython
from libc.stdint cimport uint32_t
from libcpp.vector cimport vector
from libcpp.string cimport string

cdef extern int __builtin_popcount(unsigned int) nogil

@cython.boundscheck(False)
@cython.wraparound(False)
cdef int _c_popcount_32(uint32_t[:] arr) nogil:
    """
    Iterates over the elements of an 2D array and replaces them by their popcount
    Parameters:
    -----------
    arr: numpy_array, dtype=np.uint32, shape=(n, )
       The array for which the popcounts should be computed.
    """
    cdef int i
    cdef int j
    j = 0
    for i in xrange(arr.shape[0]):
        j += __builtin_popcount(arr[i])
    return j


@cython.boundscheck(False)
@cython.wraparound(False)
cdef float _c_tanimoto(uint32_t[:] fp1, uint32_t[:] fp2) nogil:
    """
    Computes the tanimoto index from fp1 and fp2
    Parameters:
    ---------
    fp1: numpy_array, dtype=np.uint32, shape=(n, )
       First fingerprint
    fp2: numpy_array, dtype=np.uint32, shape=(n, )
       Second fingerprint
    """
    cdef int i
    cdef int intersection
    cdef int fp1count
    cdef int fp2count
    cdef float tanimoto
    
    intersection = 0
    fp1count = 0
    fp2count = 0
    for i in xrange(fp1.shape[0]):
        intersection += __builtin_popcount(fp1[i] & fp2[i])
        fp1count += __builtin_popcount(fp1[i])
        fp2count += __builtin_popcount(fp2[i])
    tanimoto = float(intersection) / float(fp1count + fp2count - intersection)
    return tanimoto

@cython.boundscheck(False)
@cython.wraparound(False)
cdef float _c_tanimoto2(uint32_t[:] fp1, uint32_t[:] fp2, int count1, int count2) nogil:
    """
    Computes the tanimoto index from fp1 and fp2
    Parameters:
    ---------
    fp1: numpy_array, dtype=np.uint32, shape=(n, )
       First fingerprint
    fp2: numpy_array, dtype=np.uint32, shape=(n, )
       Second fingerprint
    """
    cdef int i
    cdef int intersection
    cdef float tanimoto
    intersection = 0
    for i in xrange(fp1.shape[0]):
        intersection += __builtin_popcount(fp1[i] & fp2[i])
    tanimoto = float(intersection) / float(count1 + count2 - intersection)
    return tanimoto


@cython.boundscheck(False)
@cython.wraparound(False)
cdef void _c_tanimoto_multi(uint32_t[:] fp1, uint32_t[:, :] fps, int count1, uint32_t[:] counts, float[:] tanimotos) nogil:
    """
    Computes the tanimoto index from fp1 and fp2
    Parameters:
    ---------
    fp1: numpy_array, dtype=np.uint32, shape=(n, )
       First fingerprint
    fp2: numpy_array, dtype=np.uint32, shape=(n, )
       Second fingerprint
    """
    cdef int i
    cdef int j
    cdef int intersection
    cdef float tanimoto
    for j in xrange(fps.shape[0]):
        intersection = 0
        for i in xrange(fps.shape[1]):
            intersection += __builtin_popcount(fp1[i] & fps[j, i])
        tanimoto = float(intersection) / float(count1 + counts[j] - intersection)
        tanimotos[j] = tanimoto
    return

@cython.boundscheck(False)
@cython.wraparound(False)
cdef void _c_makeFP(str sequence, uint32_t fpsize, uint32_t[:] fp):
    cdef int i
    cdef FP _fp = FP(fpsize)
    cdef string s = sequence.encode('UTF-8')
    
    _fp.digest(s)
#    fpV = cmakeFP(sequence, fpsize)
    for i in xrange(_fp.int_fp.size()):
        fp[i] = _fp.int_fp[i]
    return

def cpopcount(arr):
    """
    Computes the popcount of each element of a numpy array in-place.
    http://en.wikipedia.org/wiki/Hamming_weight
    Parameters:
    -----------
    arr: numpy_array, dtype=np.uint32
         The array of integers for which the popcounts should be computed.
    """
    count = _c_popcount_32(arr)
    return count


def tanimoto(fp1, fp2, count1=None, count2=None):
    """
    Computes the tanimoto index from fp1 and fp2
    Parameters:
    ---------
    fp1: numpy_array, dtype=np.uint32, shape=(n, )
       First fingerprint
    fp2: numpy_array, dtype=np.uint32, shape=(n, )
       Second fingerprint
    """
    if count1 is None:
        tanimoto = _c_tanimoto(fp1, fp2)
    else:
        tanimoto = _c_tanimoto2(fp1, fp2, count1, count2)
    return tanimoto


def tanimoto_multi(fp1, fps, count1, counts):
    tanimotos = np.zeros(fps.shape[0], 'f')
    _c_tanimoto_multi(fp1, fps, count1, counts, tanimotos)
    return tanimotos

def makeFP(sequence, fpsize):
    fp = np.zeros(int(np.ceil(fpsize/32)), 'u4')
    _c_makeFP(sequence, fpsize, fp)
    return fp, _c_popcount_32(fp)

