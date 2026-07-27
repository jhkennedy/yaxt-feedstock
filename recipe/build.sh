#!/bin/bash

set -x

autoreconf -vfi

if [[ "${mpi}" == "openmpi" ]]; then
  # tell the mpicc/mpifort wrappers which compiler to actually invoke --
  # without this they fall back to whatever compiler openmpi itself was
  # built with, which breaks cross-compilation (e.g. osx-64 -> osx-arm64):
  # the wrapper ends up invoking a build-arch compiler while linking
  # against host-arch (target) MPI libraries.
  export OMPI_CC="${CC}"
  export OMPI_FC="${FC}"
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
