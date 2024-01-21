#!/bin/bash

# A script to build shared and static versions of the Lapack libraries:
#  1. Assumes the NETLIB source archive lapack-$LAPACK_VERSION.tar.gz is present
#  2. Under directory lapack-$LAPACK_VERSION, make.inc.example, SRC/Makefile and
#     BLAS/SRC/Makefile are modified with lapack-$LAPACK_VERSION.patch

alias cp=cp

MAKE_OPTS="-j 6"
ALL_BUILDS="generic intel haswell nehalem skylake"

# Patch lapack files make.inc.example, SRC/Makefile and BLAS/SRC/Makefile
cat > lapack-$LAPACK_VERSION.patch.uue << 'EOF'
begin-base64 644 lapack-3.12.0.patch
LS0tIGxhcGFjay0zLjEyLjAvQkxBUy9TUkMvTWFrZWZpbGUJMjAyMy0xMS0y
NSAwNzo0MToxNS4wMDAwMDAwMDAgKzExMDAKKysrIGxhcGFjay0zLjEyLjAu
bmV3L0JMQVMvU1JDL01ha2VmaWxlCTIwMjQtMDEtMTkgMjM6NTk6MzcuODI1
OTU5Njk4ICsxMTAwCkBAIC0xNDksNiArMTQ5LDkgQEAKIAkkKEFSKSAkKEFS
RkxBR1MpICRAICReCiAJJChSQU5MSUIpICRACiAKKyQobm90ZGlyICQoQkxB
U0xJQjolLmE9JS5zbykpOiAkKEFMTE9CSikKKwkkKEZDKSAtc2hhcmVkIC1X
bCwtc29uYW1lLCRAIC1vICRAICReCisKIC5QSE9OWTogc2luZ2xlIGRvdWJs
ZSBjb21wbGV4IGNvbXBsZXgxNgogc2luZ2xlOiAkKFNCTEFTMSkgJChBTExC
TEFTKSAkKFNCTEFTMikgJChTQkxBUzMpCiAJJChBUikgJChBUkZMQUdTKSAk
KEJMQVNMSUIpICReCi0tLSBsYXBhY2stMy4xMi4wL1NSQy9NYWtlZmlsZQky
MDIzLTExLTI1IDA3OjQxOjE1LjAwMDAwMDAwMCArMTEwMAorKysgbGFwYWNr
LTMuMTIuMC5uZXcvU1JDL01ha2VmaWxlCTIwMjQtMDEtMTkgMjM6NTk6Mzcu
ODI4OTU5Njg0ICsxMTAwCkBAIC01NjEsNiArNTYxLDkgQEAKIAkkKEFSKSAk
KEFSRkxBR1MpICRAICReCiAJJChSQU5MSUIpICRACiAKKyQobm90ZGlyICQo
TEFQQUNLTElCOiUuYT0lLnNvKSk6ICQoQUxMT0JKKSAkKEFMTFhPQkopICQo
REVQUkVDQVRFRCkKKwkkKEZDKSAtc2hhcmVkIC1XbCwtc29uYW1lLCRAIC1v
ICRAICReCisKIC5QSE9OWTogc2luZ2xlIGNvbXBsZXggZG91YmxlIGNvbXBs
ZXgxNgogCiBTSU5HTEVfREVQUyA6PSAkKFNMQVNSQykgJChEU0xBU1JDKQot
LS0gbGFwYWNrLTMuMTIuMC9tYWtlLmluYy5leGFtcGxlCTIwMjMtMTEtMjUg
MDc6NDE6MTUuMDAwMDAwMDAwICsxMTAwCisrKyBsYXBhY2stMy4xMi4wLm5l
dy9tYWtlLmluYy5leGFtcGxlCTIwMjQtMDEtMTkgMjM6NTk6MzcuODI5OTU5
NjgwICsxMTAwCkBAIC03LDcgKzcsOCBAQAogIyAgQ0MgaXMgdGhlIEMgY29t
cGlsZXIsIG5vcm1hbGx5IGludm9rZWQgd2l0aCBvcHRpb25zIENGTEFHUy4K
ICMKIENDID0gZ2NjCi1DRkxBR1MgPSAtTzMKK0JMRE9QVFMgPSAtZlBJQyAt
bTY0IC1tYXJjaD1uZWhhbGVtCitDRkxBR1MgPSAtTzMgJChCTERPUFRTKQog
CiAjICBNb2RpZnkgdGhlIEZDIGFuZCBGRkxBR1MgZGVmaW5pdGlvbnMgdG8g
dGhlIGRlc2lyZWQgY29tcGlsZXIKICMgIGFuZCBkZXNpcmVkIGNvbXBpbGVy
IG9wdGlvbnMgZm9yIHlvdXIgbWFjaGluZS4gIE5PT1BUIHJlZmVycyB0bwpA
QCAtMTcsMTAgKzE4LDEwIEBACiAjICBhbmQgaGFuZGxlIHRoZXNlIHF1YW50
aXRpZXMgYXBwcm9wcmlhdGVseS4gQXMgYSBjb25zZXF1ZW5jZSwgb25lCiAj
ICBzaG91bGQgbm90IGNvbXBpbGUgTEFQQUNLIHdpdGggZmxhZ3Mgc3VjaCBh
cyAtZmZwZS10cmFwPW92ZXJmbG93LgogIwotRkMgPSBnZm9ydHJhbgotRkZM
QUdTID0gLU8yIC1mcmVjdXJzaXZlCitGQyA9IGdmb3J0cmFuIC1mcmVjdXJz
aXZlICQoQkxET1BUUykKK0ZGTEFHUyA9IC1PMiAKIEZGTEFHU19EUlYgPSAk
KEZGTEFHUykKLUZGTEFHU19OT09QVCA9IC1PMCAtZnJlY3Vyc2l2ZQorRkZM
QUdTX05PT1BUID0gLU8wCiAKICMgIERlZmluZSBMREZMQUdTIHRvIHRoZSBk
ZXNpcmVkIGxpbmtlciBvcHRpb25zIGZvciB5b3VyIG1hY2hpbmUuCiAjCkBA
IC01NSw3ICs1Niw3IEBACiAjICBVbmNvbW1lbnQgdGhlIGZvbGxvd2luZyBs
aW5lIHRvIGluY2x1ZGUgZGVwcmVjYXRlZCByb3V0aW5lcyBpbgogIyAgdGhl
IExBUEFDSyBsaWJyYXJ5LgogIwotI0JVSUxEX0RFUFJFQ0FURUQgPSBZZXMK
K0JVSUxEX0RFUFJFQ0FURUQgPSBZZXMKIAogIyAgTEFQQUNLRSBoYXMgdGhl
IGludGVyZmFjZSB0byBzb21lIHJvdXRpbmVzIGZyb20gdG1nbGliLgogIyAg
SWYgTEFQQUNLRV9XSVRIX1RNRyBpcyBkZWZpbmVkLCBhZGQgdGhvc2Ugcm91
dGluZXMgdG8gTEFQQUNLRS4KQEAgLTc0LDcgKzc1LDcgQEAKICMgIG1hY2hp
bmUtc3BlY2lmaWMsIG9wdGltaXplZCBCTEFTIGxpYnJhcnkgc2hvdWxkIGJl
IHVzZWQgd2hlbmV2ZXIKICMgIHBvc3NpYmxlLikKICMKLUJMQVNMSUIgICAg
ICA9ICQoVE9QU1JDRElSKS9saWJyZWZibGFzLmEKK0JMQVNMSUIgICAgICA9
ICQoVE9QU1JDRElSKS9saWJibGFzLmEKIENCTEFTTElCICAgICA9ICQoVE9Q
U1JDRElSKS9saWJjYmxhcy5hCiBMQVBBQ0tMSUIgICAgPSAkKFRPUFNSQ0RJ
UikvbGlibGFwYWNrLmEKIFRNR0xJQiAgICAgICA9ICQoVE9QU1JDRElSKS9s
aWJ0bWdsaWIuYQo=
====
EOF
uudecode lapack-$LAPACK_VERSION.patch.uue
rm -Rf lapack-$LAPACK_VERSION
tar -xf lapack-$LAPACK_VERSION.tar.gz
pushd lapack-$LAPACK_VERSION
patch -p1 < ../lapack-$LAPACK_VERSION.patch
cp make.inc.example make.inc
popd

# Create directories
mkdir -p lapack
pushd lapack
mkdir -p $ALL_BUILDS

# Populate directories
for dir in $ALL_BUILDS ; do
  echo $dir
  pushd $dir
  cp -Rf ../../lapack-$LAPACK_VERSION .
  popd
done

# Set build options in each directory
for dir in generic intel ; do
  sed -i -e "s/^BLDOPTS\ *=.*/BLDOPTS\ \ = -fPIC -m64 -mtune=$dir/" $dir/lapack-$LAPACK_VERSION/make.inc
done
for dir in haswell nehalem skylake ; do
  sed -i -e "s/^BLDOPTS\ *=.*/BLDOPTS\ \ = -fPIC -march=$dir/" $dir/lapack-$LAPACK_VERSION/make.inc
done

# Build in each directory
for dir in $ALL_BUILDS ; do
  echo $dir ;
  pushd $dir/lapack-$LAPACK_VERSION/BLAS/SRC ;
  make $MAKE_OPTS ;
  make $MAKE_OPTS libblas.so ;
  cp libblas.so ../.. ;
  popd ;
  pushd $dir/lapack-$LAPACK_VERSION/SRC ;
  make $MAKE_OPTS ;
  make $MAKE_OPTS liblapack.so ;
  cp liblapack.so .. ;
  popd ;
done

# Done
popd
