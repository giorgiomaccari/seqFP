from libcpp.vector cimport vector
from libcpp.string cimport string
from libc.stdint cimport uint32_t

cdef extern from "cutils.h":
    cdef cppclass FP:
        FP()
        FP(uint32_t fpsize)
        void digest(string sequence)
        vector[uint32_t] int_fp
    cdef uint32_t mypopcnt(uint32_t i) nogil
