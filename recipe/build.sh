#!/bin/bash

set -x

autoreconf -vfi

if [[ "${mpi}" == "openmpi" ]]; then
  if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
    # tell the mpicc/mpifort wrappers which compiler to actually invoke, and
    # where to find the MPI install -- without these, cross-compiling (e.g.
    # osx-64 -> osx-arm64) fails configure's basic compiler check, since the
    # wrapper falls back to build-time defaults baked into the openmpi
    # package that don't match the cross target. Same fix as used in
    # conda-forge/scalapack-feedstock.
    export OMPI_CC="${CC}"
    export OMPI_FC="${FC}"
    export OPAL_PREFIX="${PREFIX}"
  fi
  export MPI_LAUNCH="${PREFIX}/bin/mpirun --oversubscribe"
  export OMPI_MCA_plm_rsh_agent=""
else
  export MPI_LAUNCH="${PREFIX}/bin/mpirun"
fi

export CC=mpicc
export FC=mpifort

IDXTYPE_ARGS=""
if [[ "${idxtype}" == "long" ]]; then
  IDXTYPE_ARGS="--with-idxtype=long"
fi

./configure --prefix=${PREFIX} \
            --with-mpi-root=${PREFIX} \
            --with-pic \
            ${IDXTYPE_ARGS}

make -j ${CPU_COUNT} all
make install
