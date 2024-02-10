#!/bin/sh
# Install SDPA sdpam.m and mex files

#
# 1. Install the Fedora MUMPS, MUMPS-devel packages.
#    (The sdpa configure scripts gets confused when installing MUMPS locally).
# 2. Install the Fedora, openblas and openblas-devel packages to link the
#    SDPA mex file with openblas. 
#

TOP_DIR=`pwd`

#
# Set Octave directories
#
OCTAVE_VER=8.4.0
OCTAVE_DIR="/usr/local/octave-"$OCTAVE_VER
OCTAVE_INCLUDE_DIR=$OCTAVE_DIR/include
OCTAVE_LIB_DIR=$OCTAVE_DIR/lib
OCTAVE_BIN_DIR=$OCTAVE_DIR/bin
OCTAVE_SHARE_DIR=$OCTAVE_DIR/share/octave
export LD_LIBRARY_PATH=$OCTAVE_LIB_DIR
export LDFLAGS=-L$OCTAVE_LIB_DIR
export PATH=$PATH:$OCTAVE_BIN_DIR

OCTAVE_LOCAL_VERSION="`$OCTAVE_BIN_DIR/octave-cli --eval 'disp(OCTAVE_VERSION);'`"
OCTAVE_SITE_M_DIR=$OCTAVE_SHARE_DIR/$OCTAVE_LOCAL_VERSION/site/m

#
# Install SDPA
#
SDPA_VER=7.3.17
SDPA_ARCHIVE="sdpa_"$SDPA_VER".tar.gz"
SDPA_URL="https://sourceforge.net/projects/sdpa/files/sdpa/sdpa_"$SDPA_VER$".tar.gz"
if ! test -f $SDPA_ARCHIVE ; then
    wget -c $SDPA_URL
fi
rm -Rf sdpa-$SDPA_VER
tar -xf $SDPA_ARCHIVE
sed -i -e "s/catch(badalloc)/catch(std::bad_alloc&)/" sdpa-$SDPA_VER/sdpa_tool.h
# Silence some warning messages
cat > sdpa-$SDPA_VER".patch.uue" <<EOF
begin-base64 644 sdpa-7.3.17.patch
LS0tIHNkcGEtNy4zLjE3Lm9yaWcvc2RwYV9saW5lYXIuY3BwCTIwMjMtMDYt
MjEgMTg6Mjk6NDUuMDAwMDAwMDAwICsxMDAwCisrKyBzZHBhLTcuMy4xNy9z
ZHBhX2xpbmVhci5jcHAJMjAyNC0wMi0wOSAyMzozMzoxNi41NjM0NzI5NDQg
KzExMDAKQEAgLTEzMTYsNyArMTMxNiw3IEBACiBib29sIExhbDo6bXVsdGlw
bHkoRGVuc2VNYXRyaXgmIHJldE1hdCwKIAkJICAgRGVuc2VNYXRyaXgmIGFN
YXQsIGRvdWJsZSogc2NhbGFyKQogewotICBpZiAocmV0TWF0Lm5Sb3chPWFN
YXQublJvdyB8fCByZXRNYXQubkNvbCE9cmV0TWF0Lm5Db2wKKyAgaWYgKHJl
dE1hdC5uUm93IT1hTWF0Lm5Sb3cgfHwgcmV0TWF0Lm5Db2whPWFNYXQubkNv
bAogICAgICAgfHwgcmV0TWF0LnR5cGUhPWFNYXQudHlwZSkgewogICAgIHJF
cnJvcigibXVsdGlwbHkgOjogZGlmZmVyZW50IG1hdHJpeCBzaXplIik7CiAg
IH0KLS0tIHNkcGEtNy4zLjE3Lm9yaWcvc2RwYV9uZXd0b24uY3BwCTIwMjMt
MDYtMjEgMTg6Mjk6NDUuMDAwMDAwMDAwICsxMDAwCisrKyBzZHBhLTcuMy4x
Ny9zZHBhX25ld3Rvbi5jcHAJMjAyNC0wMi0wOSAyMzozMjo0NS4yNTM3MDgz
MTcgKzExMDAKQEAgLTE0NjAsNiArMTQ2MCw4IEBACiAgICAgY2FzZSBGMjog
dGFyZy0+Y29tLT5CX0YyICs9IHQ7IGJyZWFrOwogICAgIGNhc2UgRjM6IHRh
cmctPmNvbS0+Ql9GMyArPSB0OyBicmVhazsKICAgICB9CisgICAgI2Vsc2UK
KyAgICAodm9pZCl0OwogICAgICNlbmRpZgogICB9CiAKLS0tIHNkcGEtNy4z
LjE3Lm9yaWcvc2RwYV90b29sLmgJMjAyMy0wNi0yMSAxODoyOTo0NS4wMDAw
MDAwMDAgKzEwMDAKKysrIHNkcGEtNy4zLjE3L3NkcGFfdG9vbC5oCTIwMjQt
MDItMDkgMjM6MzM6NDIuMDEyMjgxNTU3ICsxMTAwCkBAIC02Nyw3ICs2Nyw3
IEBACiAjZGVmaW5lIE5ld0FycmF5KHZhbCx0eXBlLG51bWJlcikgXAogICB7
dmFsID0gTlVMTDsgXAogICAgIHRyeXsgdmFsID0gbmV3IHR5cGVbbnVtYmVy
XTsgfSBcCi0gICAgY2F0Y2goYmFkX2FsbG9jKXsgXAorICAgIGNhdGNoKGJh
ZF9hbGxvYyYpeyBcCiAgICAgICAgIHJNZXNzYWdlKCJNZW1vcnkgRXhoYXVz
dGVkIChiYWRfYWxsb2MpIik7IGFib3J0KCk7IH0gXAogICAgIGNhdGNoKC4u
Lil7IFwKICAgICAgICAgck1lc3NhZ2UoIkZhdGFsIEVycm9yIChyZWxhdGVk
IG1lbW9yeSBhbGxvY2F0aW9uIik7IGFib3J0KCk7IH0gXAo=
====
EOF
uudecode sdpa-$SDPA_VER.patch.uue
pushd sdpa-$SDPA_VER
patch -p 1 < ../sdpa-$SDPA_VER.patch

export SDPA_DIR=$TOP_DIR/sdpa-$SDPA_VER
export SDPA_INCLUDE_DIR=$SDPA_DIR
export SDPA_LIB=$SDPA_DIR/libsdpa.a 
export MUMPS_INCLUDE_DIR=/usr/include/MUMPS
export MUMPS_LIBS="-lmumps_common -lpord -lmpiseq -ldmumps"
export ALL_LIBS="$SDPA_LIB $MUMPS_LIBS"

export BLAS_LIBS="-lopenblasp" 
#export LIBBLAS=$BLAS_LIBS
export LAPACK_LIBS=$BLAS_LIBS
export BLAS_INCLUDE_DIR=/usr/include/openblas
export CFLAGS="-I$BLAS_INCLUDE_DIR -I$MUMPS_INCLUDE_DIR -I$SDPA_INCLUDE_DIR" 
export CXXFLAGS="-I$BLAS_INCLUDE_DIR -I$MUMPS_INCLUDE_DIR -I$SDPA_INCLUDE_DIR" 

./configure --prefix="$SDPA_DIR" \
--with-blas="$BLAS_LIBS" \
--with-lapack="$LAPACK_LIBS" \
--with-mumps-include="-I$MUMPS_INCLUDE_DIR" \
--with-mumps-libs="$MUMPS_LIBS"

make V=1

#
# Make Octave .mex files
#
cd mex
make MAKE_INCLUDE_DIR=$SDPA_INCLUDE_DIR COMPILE_ENVIRONMENT=octave 

mkdir -p $OCTAVE_SITE_M_DIR/SDPA
mv -f * $OCTAVE_SITE_M_DIR/SDPA

#
# Test
#
# From "SDPA-M (SemiDefinite Programming Algorithm in MATLAB)
# User’s Manual — Version 6.2.0", K. Fujisawa, Y. Futakata,
# M. Kojima, S. Matsuyama, S. Nakamura, K. Nakata and M. Yamashita
# B-359, January 2000 Revised: May 2005
#
rm -f example_1*
cat > example_1.dat <<EOF
"Example 1: mDim = 3, nBLOCK = 1, {2}"
   3  =  mDIM
   1  =  nBLOCK
   2  = bLOCKsTRUCT
{48, -8, 20}
{ {-11,  0}, { 0, 23} }
{ { 10,  4}, { 4,  0} }
{ {  0,  0}, { 0, -8} }
{ {  0, -8}, {-8, -2} }
EOF
cat > example_1.ini <<EOF
{0.0, -4.0, 0.0}
{ {11.0, 0.0}, {0.0, 9.0} }
{ {5.9,  -1.375}, {-1.375, 1.0} }
EOF
cat > example_1.m <<EOF
% read a problem data from the data file "example_1.dat".
[mDIM,nBLOCK,bLOCKsTRUCT,c,F] = read_data("example_1.dat");

% read an initial point from the initial point file "example_1.ini".
[x0,X0,Y0] = initial_point("example_1.ini",mDIM,nBLOCK,bLOCKsTRUCT);

% next command is to redirect the output into the file named "example_1.out".
% default output is on display.
OPTION = param(struct("print","example_1.out"));

% solve the problem using sdpam.
[objVal,x,X,Y,INFO] = sdpam(mDIM,nBLOCK,bLOCKsTRUCT,c,F,x0,X0,Y0,OPTION);
EOF
octave example_1.m
cat example_1.out

#
# Done
#
popd
rm -Rf sdpa-$SDPA_VER sdpa-$SDPA_VER.patch sdpa-$SDPA_VER.patch.uue
