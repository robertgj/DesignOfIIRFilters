#!/bin/sh
#
# Install SCS scs.m and mex files
#
# Run this script as root!
#

OCTAVE_VER=8.4.0
OCTAVE_BIN_DIR=/usr/local/octave-$OCTAVE_VER/bin
OCTAVE_LIB_DIR=/usr/local/octave-$OCTAVE_VER/lib
OCTAVE_SHARE_DIR=/usr/local/octave-$OCTAVE_VER/share
MEX="$OCTAVE_BIN_DIR/mkoctfile -mex"
OCTAVE_LOCAL_VERSION=\
"`$OCTAVE_BIN_DIR/octave-cli --eval 'disp(OCTAVE_VERSION);'`"
OCTAVE_SITE_M_DIR=$OCTAVE_SHARE_DIR/octave/$OCTAVE_LOCAL_VERSION/site/m

#
# Get SCS source
#
SCS_VER=3.2.3
SCS_ARCHIVE=scs-$SCS_VER".tar.gz"
SCS_URL="https://github.com/cvxgrp/scs/archive/refs/tags/"$SCS_VER.tar.gz
if ! test -f $SCS_ARCHIVE ; then
    wget -c $SCS_URL
    mv $SCS_VER.tar.gz $SCS_ARCHIVE
fi
tar -xf $SCS_ARCHIVE

#
# Get SCS Matlab interface source
#
SCS_MATLAB_ARCHIVE="scs-matlab-master.zip"
SCS_MATLAB_URL="https://github.com/bodono/scs-matlab/archive/refs/heads/master.zip"
if ! test -f $SCS_MATLAB_ARCHIVE ; then
    wget -c $SCS_MATLAB_URL
    mv master.zip $SCS_MATLAB_ARCHIVE
fi
unzip $SCS_MATLAB_ARCHIVE

#
# Patch scs
#
cat > "scs-"$SCS_VER".patch" <<EOF
--- scs-3.2.3/include/scs_blas.h	2023-04-05 18:18:05.000000000 +1000
+++ scs-3.2.3.new/include/scs_blas.h	2024-03-10 15:33:28.361709731 +1100
@@ -34,6 +34,7 @@
 #endif
 
 #ifdef MATLAB_MEX_FILE
+#include <stddef.h>
 typedef ptrdiff_t blas_int;
 #elif defined BLAS64
 #include <stdint.h>
--- scs-3.2.3/src/cones.c	2023-04-05 18:18:05.000000000 +1000
+++ scs-3.2.3.new/src/cones.c	2024-03-10 15:33:50.322543822 +1100
@@ -331,7 +331,7 @@
 static scs_int set_up_sd_cone_work_space(ScsConeWork *c, const ScsCone *k) {
   scs_int i;
 #ifdef USE_LAPACK
-  blas_int n_max = 0;
+  blas_int n_max = 1;
   blas_int neg_one = -1;
   blas_int info = 0;
   scs_float wkopt = 0.0;
EOF
pushd scs-$SCS_VER
patch -p 1 < ../"scs-"$SCS_VER".patch"
popd

#
# Patch scs-matlab
#
cat > "scs-matlab-master.patch" <<EOF
--- scs-matlab-master/scs_mex.c	2023-04-05 18:38:52.000000000 +1000
+++ scs-matlab-master.new/scs_mex.c	2024-03-10 15:57:07.972988845 +1100
@@ -1,6 +1,5 @@
 #include "glbopts.h"
 #include "linalg.h"
-#include "matrix.h"
 #include "mex.h"
 #include "scs.h"
 #include "scs_matrix.h"
EOF
pushd scs-matlab-master
patch -p 1 < ../"scs-matlab-master.patch"
popd

#
# Compile and install direct (LMI) and indirect(conjugate-gradient) solvers
#
cp -R scs-matlab-master/* scs-$SCS_VER
pushd scs-$SCS_VER
SCS_COMMON_FILES="linsys/external/amd/amd_order.c \
  linsys/external/amd/amd_dump.c \
  linsys/external/amd/amd_postorder.c \
  linsys/external/amd/amd_post_tree.c \
  linsys/external/amd/amd_aat.c \
  linsys/external/amd/amd_2.c \
  linsys/external/amd/amd_1.c \
  linsys/external/amd/amd_defaults.c \
  linsys/external/amd/amd_control.c \
  linsys/external/amd/amd_info.c \
  linsys/external/amd/amd_valid.c \
  linsys/external/amd/amd_global.c \
  linsys/external/amd/amd_preprocess.c \
  linsys/external/amd/SuiteSparse_config.c \
  src/linalg.c \
  src/cones.c \
  src/exp_cone.c \
  src/aa.c \
  src/util.c \
  src/scs.c \
  src/ctrlc.c \
  src/normalize.c \
  src/scs_version.c \
  linsys/scs_matrix.c \
  linsys/csparse.c \
  src/rw.c \
  scs_mex.c \
  linsys/external/qdldl/qdldl.c"

# Compile direct solver
$MEX -O -v  \
  -DMATLAB_MEX_FILE -DUSE_LAPACK -DCOPYAMATRIX -DVERBOSITY=0 -DNO_READ_WRITE=1 \
  -Ilinsys -Iinclude -DDLONG -std=c99  -O0 -ggdb \
  $SCS_COMMON_FILES \
  linsys/cpu/direct/private.c \
  -L$OCTAVE_LIB_DIR -lm -lblas -llapack -output scs_direct

# Compile indirect solver
$MEX -O -v  \
  -DMATLAB_MEX_FILE -DUSE_LAPACK -DCOPYAMATRIX -DVERBOSITY=0 -DNO_READ_WRITE=1 \
  -DINDIRECT -Ilinsys -Iinclude -DDLONG -std=c99  -O0 -ggdb \
  $SCS_COMMON_FILES \
  linsys/cpu/indirect/private.c \
  -L$OCTAVE_LIB_DIR -lm -lblas -llapack -output scs_indirect

# Install
rm -Rf $OCTAVE_SITE_M_DIR/SCS
mkdir -p $OCTAVE_SITE_M_DIR/SCS
cp -f LICENSE README.md scs*.m scs*.mex $OCTAVE_SITE_M_DIR/SCS
popd

#
# Done
#
rm -Rf scs-matlab-master* scs-$SCS_VER*
