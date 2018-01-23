#!/bin/sh

# Assume these files are present:
#  lapack-3.7.1.tgz
#  SuiteSparse-4.5.6.tar.gz
#  arpack-ng-master.zip
#  fftw-3.3.7.tar.gz
#  qrupdate-1.1.2.tar.gz
#  glpk-4.63.tar.gz
#  octave-4.2.1.tar.lz
#  struct-1.0.14.tar.gz
#  optim-1.5.2.tar.gz
#  control-3.0.0.tar.gz
#  signal-1.3.2.tar.gz
#  parallel-3.1.1.tar.gz

OCTAVE_DIR=/usr/local/octave
OCTAVE_INCLUDE_DIR=$OCTAVE_DIR/include
OCTAVE_LIB_DIR=$OCTAVE_DIR/lib
OCTAVE_BIN_DIR=$OCTAVE_DIR/bin

export LD_LIBRARY_PATH=$OCTAVE_LIB_DIR
export LDFLAGS=-L$OCTAVE_LIB_DIR
export PATH=$PATH:$OCTAVE_BIN_DIR

#
# !?!WARNING!?!
#
# Starting from scratch!
#
rm -R $OCTAVE_DIR

#
# Build lapack
#
cat > lapack-3.7.1.patch.uue << 'EOF'
begin-base64 644 lapack-3.7.1.patch
LS0tIGxhcGFjay0zLjcuMS9tYWtlLmluYy5leGFtcGxlCTIwMTctMDYtMTgg
MDg6NDY6NTMuMDAwMDAwMDAwICsxMDAwCisrKyBsYXBhY2stMy43LjEubW9k
L21ha2UuaW5jLmV4YW1wbGUJMjAxNy0xMS0xOSAxMzo0ODoyNC41Nzg1NTg0
OTYgKzExMDAKQEAgLTksNyArOSw4IEBACiAjICBDQyBpcyB0aGUgQyBjb21w
aWxlciwgbm9ybWFsbHkgaW52b2tlZCB3aXRoIG9wdGlvbnMgQ0ZMQUdTLgog
IwogQ0MgICAgID0gZ2NjCi1DRkxBR1MgPSAtTzMKK0JMRE9QVFMgPSAtZlBJ
QyAtbTY0IC1tdHVuZT1nZW5lcmljCitDRkxBR1MgPSAtTzMgJChCTERPUFRT
KQogCiAjICBNb2RpZnkgdGhlIEZPUlRSQU4gYW5kIE9QVFMgZGVmaW5pdGlv
bnMgdG8gcmVmZXIgdG8gdGhlIGNvbXBpbGVyCiAjICBhbmQgZGVzaXJlZCBj
b21waWxlciBvcHRpb25zIGZvciB5b3VyIG1hY2hpbmUuICBOT09QVCByZWZl
cnMgdG8KQEAgLTE5LDE1ICsyMCwxNSBAQAogIyAgYW5kIGhhbmRsZSB0aGVz
ZSBxdWFudGl0aWVzIGFwcHJvcHJpYXRlbHkuIEFzIGEgY29uc2VxdWVuY2Us
IG9uZQogIyAgc2hvdWxkIG5vdCBjb21waWxlIExBUEFDSyB3aXRoIGZsYWdz
IHN1Y2ggYXMgLWZmcGUtdHJhcD1vdmVyZmxvdy4KICMKLUZPUlRSQU4gPSBn
Zm9ydHJhbgotT1BUUyAgICA9IC1PMiAtZnJlY3Vyc2l2ZQorRk9SVFJBTiA9
IGdmb3J0cmFuIC1mcmVjdXJzaXZlICQoQkxET1BUUykKK09QVFMgICAgPSAt
TzIKIERSVk9QVFMgPSAkKE9QVFMpCi1OT09QVCAgID0gLU8wIC1mcmVjdXJz
aXZlCitOT09QVCAgID0gLU8wCiAKICMgIERlZmluZSBMT0FERVIgYW5kIExP
QURPUFRTIHRvIHJlZmVyIHRvIHRoZSBsb2FkZXIgYW5kIGRlc2lyZWQKICMg
IGxvYWQgb3B0aW9ucyBmb3IgeW91ciBtYWNoaW5lLgogIwotTE9BREVSICAg
PSBnZm9ydHJhbgorTE9BREVSICAgPSAkKEZPUlRSQU4pCiBMT0FET1BUUyA9
CiAKICMgIFRoZSBhcmNoaXZlciBhbmQgdGhlIGZsYWcocykgdG8gdXNlIHdo
ZW4gYnVpbGRpbmcgYW4gYXJjaGl2ZQpAQCAtNTksNyArNjAsNyBAQAogIyAg
VW5jb21tZW50IHRoZSBmb2xsb3dpbmcgbGluZSB0byBpbmNsdWRlIGRlcHJl
Y2F0ZWQgcm91dGluZXMgaW4KICMgIHRoZSBMQVBBQ0sgbGlicmFyeS4KICMK
LSNCVUlMRF9ERVBSRUNBVEVEID0gWWVzCitCVUlMRF9ERVBSRUNBVEVEID0g
WWVzCiAKICMgIExBUEFDS0UgaGFzIHRoZSBpbnRlcmZhY2UgdG8gc29tZSBy
b3V0aW5lcyBmcm9tIHRtZ2xpYi4KICMgIElmIExBUEFDS0VfV0lUSF9UTUcg
aXMgZGVmaW5lZCwgYWRkIHRob3NlIHJvdXRpbmVzIHRvIExBUEFDS0UuCkBA
IC03OCw3ICs3OSw3IEBACiAjICBtYWNoaW5lLXNwZWNpZmljLCBvcHRpbWl6
ZWQgQkxBUyBsaWJyYXJ5IHNob3VsZCBiZSB1c2VkIHdoZW5ldmVyCiAjICBw
b3NzaWJsZS4pCiAjCi1CTEFTTElCICAgICAgPSAuLi8uLi9saWJyZWZibGFz
LmEKK0JMQVNMSUIgICAgICA9IC4uLy4uL2xpYmJsYXMuYQogQ0JMQVNMSUIg
ICAgID0gLi4vLi4vbGliY2JsYXMuYQogTEFQQUNLTElCICAgID0gbGlibGFw
YWNrLmEKIFRNR0xJQiAgICAgICA9IGxpYnRtZ2xpYi5hCi0tLSBsYXBhY2st
My43LjEvQkxBUy9TUkMvTWFrZWZpbGUJMjAxNy0wNi0xOCAwODo0Njo1My4w
MDAwMDAwMDAgKzEwMDAKKysrIGxhcGFjay0zLjcuMS5tb2QvQkxBUy9TUkMv
TWFrZWZpbGUJMjAxNy0xMS0xOSAxMzo0ODoyNC41Nzk1NTg0ODYgKzExMDAK
QEAgLTU3LDYgKzU3LDEwIEBACiAKIGFsbDogJChCTEFTTElCKQogCitsaWJi
bGFzLnNvOiAkKEFMTE9CSikKKwkkKEZPUlRSQU4pIC1zaGFyZWQgLVdsLC1z
b25hbWUsJEAgLW8gJEAgJChBTExPQkopCisJY3AgLWYgbGliYmxhcy5zbyAu
Li8uLiA7CisKICMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KICMgIENvbW1lbnQgb3V0IHRoZSBu
ZXh0IDYgZGVmaW5pdGlvbnMgaWYgeW91IGFscmVhZHkgaGF2ZQogIyAgdGhl
IExldmVsIDEgQkxBUy4KLS0tIGxhcGFjay0zLjcuMS9TUkMvTWFrZWZpbGUJ
MjAxNy0wNi0xOCAwODo0Njo1My4wMDAwMDAwMDAgKzEwMDAKKysrIGxhcGFj
ay0zLjcuMS5tb2QvU1JDL01ha2VmaWxlCTIwMTctMTEtMTkgMTM6NDg6MjQu
NTc5NTU4NDg2ICsxMTAwCkBAIC01MDcsOCArNTA3LDEyIEBACiAKIGFsbDog
Li4vJChMQVBBQ0tMSUIpCiAKK2xpYmxhcGFjay5zbzogJChBTExPQkopICQo
QUxMWE9CSikgJChERVBSRUNBVEVEKQorCSQoRk9SVFJBTikgLXNoYXJlZCAt
V2wsLXNvbmFtZSwkQCAtbyAkQCAkKEFMTE9CSikgJChBTExYT0JKKSAkKERF
UFJFQ0FURUQpCisJY3AgLWYgbGlibGFwYWNrLnNvIC4uIDsKKwogLi4vJChM
QVBBQ0tMSUIpOiAkKEFMTE9CSikgJChBTExYT0JKKSAkKERFUFJFQ0FURUQp
Ci0JJChBUkNIKSAkKEFSQ0hGTEFHUykgJEAgJF4KKwkkKEFSQ0gpICQoQVJD
SEZMQUdTKSAkQCAkKEFMTE9CSikgJChBTExYT0JKKSAkKERFUFJFQ0FURUQp
CiAJJChSQU5MSUIpICRACiAKIHNpbmdsZTogJChTTEFTUkMpICQoRFNMQVNS
QykgJChTWExBU1JDKSAkKFNDTEFVWCkgJChBTExBVVgpCg==
====
EOF
# Patch
uudecode lapack-3.7.1.patch.uue > lapack-3.7.1.patch
rm -Rf lapack-3.7.1
tar -xf lapack-3.7.1.tgz
pushd lapack-3.7.1
patch -p1 < ../lapack-3.7.1.patch
cp make.inc.example make.inc
popd
# Make libblas.so
pushd lapack-3.7.1/BLAS/SRC
make && make libblas.so
mkdir -p $OCTAVE_LIB_DIR
cp libblas.so $OCTAVE_LIB_DIR
popd
# Make liblapack.so
pushd lapack-3.7.1/SRC
make liblapack.so
cp liblapack.so $OCTAVE_LIB_DIR
popd

#
# Build arpack-ng
#
rm -Rf arpack-ng-master
unzip arpack-ng-master.zip
pushd arpack-ng-master
sh ./bootstrap
./configure --prefix=$OCTAVE_DIR --with-blas=-lblas --with-lapack=-llapack
make && make install
popd

#
# Build SuiteSparse
#
rm -Rf SuiteSparse
tar -xf SuiteSparse-4.5.6.tar.gz
pushd SuiteSparse
make INSTALL=$OCTAVE_DIR OPTIMIZATION=-O2 BLAS=-lblas install
popd

#
# Build qrupdate
#
rm -Rf qrupdate-1.1.2
tar -xf qrupdate-1.1.2.tar.gz
pushd qrupdate-1.1.2
rm -f Makeconf
cat > Makeconf << 'EOF'
FC=gfortran
FFLAGS=-fimplicit-none -O2 -funroll-loops 
FPICFLAGS=-fPIC

ifeq ($(strip $(PREFIX)),)
  PREFIX=/usr/local
endif

BLAS=-L$(PREFIX)/lib -lblas
LAPACK=-L$(PREFIX)/lib -llapack

VERSION=1.1
MAJOR=1
LIBDIR=lib
DESTDIR=
EOF
make PREFIX=$OCTAVE_DIR solib install
popd

#
# Build glpk
#
rm -Rf glpk-4.63
tar -xf glpk-4.63.tar.gz
pushd glpk-4.63
./configure --prefix=$OCTAVE_DIR
make -j 6 && make install
popd

#
# Build fftw
#
rm -Rf fftw-3.3.7
tar -xf fftw-3.3.7.tar.gz
pushd fftw-3.3.7
./configure --prefix=$OCTAVE_DIR --enable-shared \
            --with-combined-threads --enable-threads
make -j 6 && make install
popd

#
# Build fftw single-precision
#
rm -Rf fftw-3.3.7
tar -xf fftw-3.3.7.tar.gz
pushd fftw-3.3.7
./configure --prefix=$OCTAVE_DIR --enable-shared \
            --with-combined-threads --enable-threads --enable-single
make -j 6 && make install
popd

#
# Build octave
#

# Unpack octave
cat > octave-4.2.1.patch.uue << 'EOF'
begin-base64 666 octave-4.2.1.patch
LS0tIG9jdGF2ZS00LjIuMS5vbGQvY29uZmlndXJlCTIwMTctMDItMjMgMDU6
MTg6MzYuMDAwMDAwMDAwICsxMTAwCisrKyBvY3RhdmUtNC4yLjEvY29uZmln
dXJlCTIwMTctMTEtMTkgMTc6MTg6MDIuNDQzMzg1NTQzICsxMTAwCkBAIC03
MzcwMyw5ICs3MzcwMyw5IEBACiAgIGRvbmUKIGZpCiAKLUdDQ19BRERSRVNT
X1NBTklUSVpFUl9GTEFHUz0iLWZzYW5pdGl6ZT1hZGRyZXNzIC1mbm8tb21p
dC1mcmFtZS1wb2ludGVyIgotR1hYX0FERFJFU1NfU0FOSVRJWkVSX0ZMQUdT
PSItZnNhbml0aXplPWFkZHJlc3MgLWZuby1vbWl0LWZyYW1lLXBvaW50ZXIi
Ci1MRF9BRERSRVNTX1NBTklUSVpFUl9GTEFHUz0iLWZzYW5pdGl6ZT1hZGRy
ZXNzIgorR0NDX0FERFJFU1NfU0FOSVRJWkVSX0ZMQUdTPSItZnNhbml0aXpl
PWFkZHJlc3MgLWZzYW5pdGl6ZT11bmRlZmluZWQgLWZuby1zYW5pdGl6ZT12
cHRyIC1mbm8tb21pdC1mcmFtZS1wb2ludGVyIgorR1hYX0FERFJFU1NfU0FO
SVRJWkVSX0ZMQUdTPSItZnNhbml0aXplPWFkZHJlc3MgLWZzYW5pdGl6ZT11
bmRlZmluZWQgLWZuby1zYW5pdGl6ZT12cHRyIC1mbm8tb21pdC1mcmFtZS1w
b2ludGVyIgorTERfQUREUkVTU19TQU5JVElaRVJfRkxBR1M9Ii1mc2FuaXRp
emU9YWRkcmVzcyAtZnNhbml0aXplPXVuZGVmaW5lZCAtZm5vLXNhbml0aXpl
PXZwdHIiCiAKIHRyeV9hZGRyZXNzX3Nhbml0aXplcl9mbGFncz1ubwogCi0t
LSBvY3RhdmUtNC4yLjEub2xkL2xpYm9jdGF2ZS9zeXN0ZW0vZmlsZS1zdGF0
LmNjCTIwMTctMDItMjMgMDU6MDE6NTUuMDAwMDAwMDAwICsxMTAwCisrKyBv
Y3RhdmUtNC4yLjEvbGlib2N0YXZlL3N5c3RlbS9maWxlLXN0YXQuY2MJMjAx
Ny0xMS0xOSAxNzoxNzoxMi41MDc4NzY5MjUgKzExMDAKQEAgLTE3NCw3ICsx
NzQsNyBAQAogICAgICAgICAgIHVwZGF0ZV9pbnRlcm5hbCAoKTsKICAgICAg
IH0KIAotICAgIGlubGluZSBmaWxlX3N0YXQ6On5maWxlX3N0YXQgKCkgeyB9
CisgICAgZmlsZV9zdGF0Ojp+ZmlsZV9zdGF0ICgpIHsgfQogCiAgICAgdm9p
ZAogICAgIGZpbGVfc3RhdDo6dXBkYXRlX2ludGVybmFsIChib29sIGZvcmNl
KQotLS0gb2N0YXZlLTQuMi4xLm9sZC9saWJvY3RhdmUvbnVtZXJpYy9zY2h1
ci5jYwkyMDE3LTAyLTIzIDA1OjAxOjU1LjAwMDAwMDAwMCArMTEwMAorKysg
b2N0YXZlLTQuMi4xL2xpYm9jdGF2ZS9udW1lcmljL3NjaHVyLmNjCTIwMTct
MTEtMTkgMTc6MTc6MTIuNTA4ODc2OTE1ICsxMTAwCkBAIC0xMDIsNyArMTAy
LDcgQEAKICAgICAgIGlmIChvcmRfY2hhciA9PSAnQScgfHwgb3JkX2NoYXIg
PT0gJ0QnIHx8IG9yZF9jaGFyID09ICdhJyB8fCBvcmRfY2hhciA9PSAnZCcp
CiAgICAgICAgIHNvcnQgPSAnUyc7CiAKLSAgICAgIHZvbGF0aWxlIGRvdWJs
ZV9zZWxlY3RvciBzZWxlY3RvciA9IDA7CisgICAgICAgZG91YmxlX3NlbGVj
dG9yIHNlbGVjdG9yID0gMDsKICAgICAgIGlmIChvcmRfY2hhciA9PSAnQScg
fHwgb3JkX2NoYXIgPT0gJ2EnKQogICAgICAgICBzZWxlY3RvciA9IHNlbGVj
dF9hbmE8ZG91YmxlPjsKICAgICAgIGVsc2UgaWYgKG9yZF9jaGFyID09ICdE
JyB8fCBvcmRfY2hhciA9PSAnZCcpCkBAIC0xODksNyArMTg5LDcgQEAKICAg
ICAgIGlmIChvcmRfY2hhciA9PSAnQScgfHwgb3JkX2NoYXIgPT0gJ0QnIHx8
IG9yZF9jaGFyID09ICdhJyB8fCBvcmRfY2hhciA9PSAnZCcpCiAgICAgICAg
IHNvcnQgPSAnUyc7CiAKLSAgICAgIHZvbGF0aWxlIGZsb2F0X3NlbGVjdG9y
IHNlbGVjdG9yID0gMDsKKyAgICAgICBmbG9hdF9zZWxlY3RvciBzZWxlY3Rv
ciA9IDA7CiAgICAgICBpZiAob3JkX2NoYXIgPT0gJ0EnIHx8IG9yZF9jaGFy
ID09ICdhJykKICAgICAgICAgc2VsZWN0b3IgPSBzZWxlY3RfYW5hPGZsb2F0
PjsKICAgICAgIGVsc2UgaWYgKG9yZF9jaGFyID09ICdEJyB8fCBvcmRfY2hh
ciA9PSAnZCcpCkBAIC0yNzYsNyArMjc2LDcgQEAKICAgICAgIGlmIChvcmRf
Y2hhciA9PSAnQScgfHwgb3JkX2NoYXIgPT0gJ0QnIHx8IG9yZF9jaGFyID09
ICdhJyB8fCBvcmRfY2hhciA9PSAnZCcpCiAgICAgICAgIHNvcnQgPSAnUyc7
CiAKLSAgICAgIHZvbGF0aWxlIGNvbXBsZXhfc2VsZWN0b3Igc2VsZWN0b3Ig
PSAwOworICAgICAgIGNvbXBsZXhfc2VsZWN0b3Igc2VsZWN0b3IgPSAwOwog
ICAgICAgaWYgKG9yZF9jaGFyID09ICdBJyB8fCBvcmRfY2hhciA9PSAnYScp
CiAgICAgICAgIHNlbGVjdG9yID0gc2VsZWN0X2FuYTxDb21wbGV4PjsKICAg
ICAgIGVsc2UgaWYgKG9yZF9jaGFyID09ICdEJyB8fCBvcmRfY2hhciA9PSAn
ZCcpCkBAIC0zODQsNyArMzg0LDcgQEAKICAgICAgIGlmIChvcmRfY2hhciA9
PSAnQScgfHwgb3JkX2NoYXIgPT0gJ0QnIHx8IG9yZF9jaGFyID09ICdhJyB8
fCBvcmRfY2hhciA9PSAnZCcpCiAgICAgICAgIHNvcnQgPSAnUyc7CiAKLSAg
ICAgIHZvbGF0aWxlIGZsb2F0X2NvbXBsZXhfc2VsZWN0b3Igc2VsZWN0b3Ig
PSAwOworICAgICAgIGZsb2F0X2NvbXBsZXhfc2VsZWN0b3Igc2VsZWN0b3Ig
PSAwOwogICAgICAgaWYgKG9yZF9jaGFyID09ICdBJyB8fCBvcmRfY2hhciA9
PSAnYScpCiAgICAgICAgIHNlbGVjdG9yID0gc2VsZWN0X2FuYTxGbG9hdENv
bXBsZXg+OwogICAgICAgZWxzZSBpZiAob3JkX2NoYXIgPT0gJ0QnIHx8IG9y
ZF9jaGFyID09ICdkJykK
====
EOF
uudecode octave-4.2.1.patch.uue > octave-4.2.1.patch
rm -Rf octave-4.2.1
tar -xf octave-4.2.1.tar.lz
pushd octave-4.2.1
patch -p 1 < ../octave-4.2.1.patch
popd
rm -Rf build
mkdir build
pushd build
OPTFLAGS="-m64 -mtune=generic -O2"
export CFLAGS=$OPTFLAGS" -std=c11 -I"$OCTAVE_INCLUDE_DIR
export CXXFLAGS=$OPTFLAGS" -std=c++11 -I"$OCTAVE_INCLUDE_DIR
export FFLAGS=$OPTFLAGS
export LDFLAGS=-L$OCTAVE_LIB_DIR
../octave-4.2.1/configure --prefix=$OCTAVE_DIR \
                          --disable-java \
                          --disable-atomic-refcount \
                          --without-fltk \
                          --without-qt \
                          --without-sndfile \
                          --without-portaudio \
                          --without-qhull \
                          --without-magick \
                          --without-hdf5 \
                          --with-blas=-lblas \
                          --with-lapack=-llapack \
                          --with-arpack-includedir=$OCTAVE_INCLUDE_DIR \
                          --with-arpack-libdir=$OCTAVE_LIB_DIR \
                          --with-qrupdate-includedir=$OCTAVE_INCLUDE_DIR \
                          --with-qrupdate-libdir=$OCTAVE_LIB_DIR \
                          --with-amd-includedir=$OCTAVE_INCLUDE_DIR \
                          --with-amd-libdir=$OCTAVE_LIB_DIR \
                          --with-camd-includedir=$OCTAVE_INCLUDE_DIR \
                          --with-camd-libdir=$OCTAVE_LIB_DIR \
                          --with-colamd-includedir=$OCTAVE_INCLUDE_DIR \
                          --with-colamd-libdir=$OCTAVE_LIB_DIR \
                          --with-ccolamd-includedir=$OCTAVE_INCLUDE_DIR \
                          --with-ccolamd-libdir=$OCTAVE_LIB_DIR \
                          --with-cholmod-includedir=$OCTAVE_INCLUDE_DIR \
                          --with-cholmod-libdir=$OCTAVE_LIB_DIR \
                          --with-cxsparse-includedir=$OCTAVE_INCLUDE_DIR \
                          --with-cxsparse-libdir=$OCTAVE_LIB_DIR \
                          --with-umfpack-includedir=$OCTAVE_INCLUDE_DIR \
                          --with-umfpack-libdir=$OCTAVE_LIB_DIR \
                          --with-glpk-includedir=$OCTAVE_INCLUDE_DIR \
                          --with-glpk-libdir=$OCTAVE_LIB_DIR \
                          --with-fftw3-includedir=$OCTAVE_INCLUDE_DIR \
                          --with-fftw3-libdir=$OCTAVE_LIB_DIR \
                          --with-fftw3f-includedir=$OCTAVE_INCLUDE_DIR \
                          --with-fftw3f-libdir=$OCTAVE_LIB_DIR

#
# Add --enable-address-sanitizer-flags for sanitizer build
#

#
# Generate profile
#
export PGO_GEN_FLAGS="-fprofile-generate"
export PGO_LTO_FLAGS="-fprofile-use -flto=6 -ffat-lto-objects"
make XTRA_CFLAGS=$PGO_GEN_FLAGS XTRA_CXXFLAGS=$PGO_GEN_FLAGS V=1 -j6
find . -name \*.gcda -exec rm -f {} ';'
make check

#
# Use profile
#
find . -name \*.o -exec rm -f {} ';'
find . -name \*.lo -exec rm -f {} ';'
find . -name \*.la -exec rm -f {} ';'
make XTRA_CFLAGS="$PGO_LTO_FLAGS" XTRA_CXXFLAGS="$PGO_LTO_FLAGS" V=1 -j6
make install

#
# Done
#
popd

#
# Install packages
#
$OCTAVE_BIN_DIR/octave-cli \
  --eval "pkg install struct-1.0.14.tar.gz ; ...
          pkg install optim-1.5.2.tar.gz ; ...
          pkg install control-3.0.0.tar.gz ; ...
          pkg install signal-1.3.2.tar.gz ; ...
          pkg install parallel-3.1.1.tar.gz ; ...
          pkg list"
