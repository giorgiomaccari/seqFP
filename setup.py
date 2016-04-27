#!/usr/bin/env python
from setuptools import setup, find_packages, Extension
from Cython.Distutils import build_ext
from os import path
from sys import version_info

if version_info < (3, ):
    from io import open

here = path.abspath(path.dirname(__file__))

with open(path.join(here, 'README.rst'), encoding='utf-8') as f:
    long_description = f.read()

setup(
  name='utils',
  version='0.9.0',
  description='Fingerprints for sequences',
  long_description=long_description,
  url="TODO",
  author="Giorgio Maccari",
  author_email="giorgio.maccari@gmail.com",
  license="GPL3",
  classifiers=[
    'Development Status :: 3 - Alpha',
    'Intended Audience :: Science/Research',
    'Topic :: Scientific/Engineering :: Bio-Informatics',
    'License :: OSI Approved :: GNU General Public License v3 (GPLv3)',
    'Programming Language :: Python :: 2',
    'Programming Language :: Python :: 2.7',
    'Programming Language :: Python :: 3',
    'Programming Language :: Python :: 3.3',
    'Programming Language :: Python :: 3.4',
    'Programming Language :: Python :: 3.5',
    'Programming Language :: C++',
    'Programming Language :: Cython'],
  keywords='sequence similarity identity',
  packages=find_packages(exclude=['contrib', 'docs', 'tests']),
  install_requires=["numpy", "h5py", "biopython"],
  ext_modules=[Extension('utils',
               sources=['seqFP/cutils.cpp', 'seqFP/utils.pyx'],
               extra_compile_args=['-O3', '-mpopcnt'],
               language='c++')],
  cmdclass={'build_ext': build_ext}
  )
