#!/bin/bash
#. setup.sh
echo lapack.sh
#make lapack out folder
if [ ! -d ${BIOTRUMP_OUT} ]; then
  echo "${BIOTRUMP_OUT} does not exist. mkdir"
  mkdir ${BIOTRUMP_OUT}
fi
if [ ! -d ${LAPACK_OUT} ]; then
  echo "${LAPACK_OUT} does not exist. mkdir"
  mkdir ${LAPACK_OUT}
fi
if [ ! -d ${LAPACK_OUT} ]; then
  echo "${LAPACK_OUT} does not exis. mkdir"
  mkdir ${LAPACK_OUT}
fi
pushd ${LAPACK_OUT}

#copied from cmake-gui : tools->show my changes
cmake -DCMAKE_VERBOSE_MAKEFILE:BOOL="1" -DLAPACKE:BOOL="1" -DLAPACKE_WITH_TMG:BOOL="1" \
-DUSE_OPTIMIZED_BLAS:BOOL="1" -DBLAS_LIBRARIES:FILEPATH=/home/thomas/build/BLAS/ATLAS/git/build/lib \
${LAPACK_SRC}
time make $@
popd
