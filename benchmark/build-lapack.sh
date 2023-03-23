#!/bin/bash

# A script to build shared and static versions of the Lapack libraries:
#  1. Assumes the NETLIB source archive lapack-$LPVER.tar.gz is present
#  2. Under directory lapack-$LPVER, make.inc.example, SRC/Makefile and
#     BLAS/SRC/Makefile are modified with lapack-$LPVER.patch

alias cp=cp

MAKE_OPTS="-j 6"
ALL_BUILDS="generic intel haswell nehalem skylake"

# Patch lapack files make.inc.example, SRC/Makefile and BLAS/SRC/Makefile
cat > lapack.patch.uue << 'EOF'
begin-base64 644 lapack.patch
LS0tIGxhcGFjay0zLjExLjAub3JpZy9CTEFTL1NSQy9NYWtlZmlsZQkyMDIy
LTExLTEyIDA0OjQ5OjU0LjAwMDAwMDAwMCArMTEwMAorKysgbGFwYWNrLTMu
MTEuMC9CTEFTL1NSQy9NYWtlZmlsZQkyMDIzLTAzLTE4IDE2OjMwOjAwLjY0
OTQyNDA3NCArMTEwMApAQCAtMTQ5LDYgKzE0OSw5IEBACiAJJChBUikgJChB
UkZMQUdTKSAkQCAkXgogCSQoUkFOTElCKSAkQAogCiskKG5vdGRpciAkKEJM
QVNMSUI6JS5hPSUuc28pKTogJChBTExPQkopCisJJChGQykgLXNoYXJlZCAt
V2wsLXNvbmFtZSwkQCAtbyAkQCAkXgorCiAuUEhPTlk6IHNpbmdsZSBkb3Vi
bGUgY29tcGxleCBjb21wbGV4MTYKIHNpbmdsZTogJChTQkxBUzEpICQoQUxM
QkxBUykgJChTQkxBUzIpICQoU0JMQVMzKQogCSQoQVIpICQoQVJGTEFHUykg
JChCTEFTTElCKSAkXgotLS0gbGFwYWNrLTMuMTEuMC5vcmlnL1NSQy9NYWtl
ZmlsZQkyMDIyLTExLTEyIDA0OjQ5OjU0LjAwMDAwMDAwMCArMTEwMAorKysg
bGFwYWNrLTMuMTEuMC9TUkMvTWFrZWZpbGUJMjAyMy0wMy0xOCAxNjozMDow
MC42NDg0MjQwODIgKzExMDAKQEAgLTU1Niw2ICs1NTYsOSBAQAogCSQoQVIp
ICQoQVJGTEFHUykgJEAgJF4KIAkkKFJBTkxJQikgJEAKIAorJChub3RkaXIg
JChMQVBBQ0tMSUI6JS5hPSUuc28pKTogJChBTExPQkopICQoQUxMWE9CSikg
JChERVBSRUNBVEVEKQorCSQoRkMpIC1zaGFyZWQgLVdsLC1zb25hbWUsJEAg
LW8gJEAgJF4KKwogLlBIT05ZOiBzaW5nbGUgY29tcGxleCBkb3VibGUgY29t
cGxleDE2CiAKIFNJTkdMRV9ERVBTIDo9ICQoU0xBU1JDKSAkKERTTEFTUkMp
Ci0tLSBsYXBhY2stMy4xMS4wLm9yaWcvbWFrZS5pbmMuZXhhbXBsZQkyMDIy
LTExLTEyIDA0OjQ5OjU0LjAwMDAwMDAwMCArMTEwMAorKysgbGFwYWNrLTMu
MTEuMC9tYWtlLmluYy5leGFtcGxlCTIwMjMtMDMtMTggMTY6MzA6MDAuNjQ5
NDI0MDc0ICsxMTAwCkBAIC03LDcgKzcsOCBAQAogIyAgQ0MgaXMgdGhlIEMg
Y29tcGlsZXIsIG5vcm1hbGx5IGludm9rZWQgd2l0aCBvcHRpb25zIENGTEFH
Uy4KICMKIENDID0gZ2NjCi1DRkxBR1MgPSAtTzMKK0JMRE9QVFMgPSAtZlBJ
QyAtbTY0IC1tYXJjaD1uZWhhbGVtCitDRkxBR1MgPSAtTzMgJChCTERPUFRT
KQogCiAjICBNb2RpZnkgdGhlIEZDIGFuZCBGRkxBR1MgZGVmaW5pdGlvbnMg
dG8gdGhlIGRlc2lyZWQgY29tcGlsZXIKICMgIGFuZCBkZXNpcmVkIGNvbXBp
bGVyIG9wdGlvbnMgZm9yIHlvdXIgbWFjaGluZS4gIE5PT1BUIHJlZmVycyB0
bwpAQCAtMTcsMTAgKzE4LDEwIEBACiAjICBhbmQgaGFuZGxlIHRoZXNlIHF1
YW50aXRpZXMgYXBwcm9wcmlhdGVseS4gQXMgYSBjb25zZXF1ZW5jZSwgb25l
CiAjICBzaG91bGQgbm90IGNvbXBpbGUgTEFQQUNLIHdpdGggZmxhZ3Mgc3Vj
aCBhcyAtZmZwZS10cmFwPW92ZXJmbG93LgogIwotRkMgPSBnZm9ydHJhbgot
RkZMQUdTID0gLU8yIC1mcmVjdXJzaXZlCitGQyA9IGdmb3J0cmFuIC1mcmVj
dXJzaXZlICQoQkxET1BUUykKK0ZGTEFHUyA9IC1PMiAKIEZGTEFHU19EUlYg
PSAkKEZGTEFHUykKLUZGTEFHU19OT09QVCA9IC1PMCAtZnJlY3Vyc2l2ZQor
RkZMQUdTX05PT1BUID0gLU8wCiAKICMgIERlZmluZSBMREZMQUdTIHRvIHRo
ZSBkZXNpcmVkIGxpbmtlciBvcHRpb25zIGZvciB5b3VyIG1hY2hpbmUuCiAj
CkBAIC01NSw3ICs1Niw3IEBACiAjICBVbmNvbW1lbnQgdGhlIGZvbGxvd2lu
ZyBsaW5lIHRvIGluY2x1ZGUgZGVwcmVjYXRlZCByb3V0aW5lcyBpbgogIyAg
dGhlIExBUEFDSyBsaWJyYXJ5LgogIwotI0JVSUxEX0RFUFJFQ0FURUQgPSBZ
ZXMKK0JVSUxEX0RFUFJFQ0FURUQgPSBZZXMKIAogIyAgTEFQQUNLRSBoYXMg
dGhlIGludGVyZmFjZSB0byBzb21lIHJvdXRpbmVzIGZyb20gdG1nbGliLgog
IyAgSWYgTEFQQUNLRV9XSVRIX1RNRyBpcyBkZWZpbmVkLCBhZGQgdGhvc2Ug
cm91dGluZXMgdG8gTEFQQUNLRS4KQEAgLTc0LDcgKzc1LDcgQEAKICMgIG1h
Y2hpbmUtc3BlY2lmaWMsIG9wdGltaXplZCBCTEFTIGxpYnJhcnkgc2hvdWxk
IGJlIHVzZWQgd2hlbmV2ZXIKICMgIHBvc3NpYmxlLikKICMKLUJMQVNMSUIg
ICAgICA9ICQoVE9QU1JDRElSKS9saWJyZWZibGFzLmEKK0JMQVNMSUIgICAg
ICA9ICQoVE9QU1JDRElSKS9saWJibGFzLmEKIENCTEFTTElCICAgICA9ICQo
VE9QU1JDRElSKS9saWJjYmxhcy5hCiBMQVBBQ0tMSUIgICAgPSAkKFRPUFNS
Q0RJUikvbGlibGFwYWNrLmEKIFRNR0xJQiAgICAgICA9ICQoVE9QU1JDRElS
KS9saWJ0bWdsaWIuYQo=
====
EOF
uudecode lapack.patch.uue
rm -Rf lapack-$LPVER
tar -xf lapack-$LPVER.tar.gz
pushd lapack-$LPVER
patch -p1 < ../lapack.patch
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
  cp -Rf ../../lapack-$LPVER .
  popd
done

# Set build options in each directory
for dir in generic intel ; do
  sed -i -e "s/^BLDOPTS\ *=.*/BLDOPTS\ \ = -fPIC -m64 -mtune=$dir/" $dir/lapack-$LPVER/make.inc
done
for dir in haswell nehalem skylake ; do
  sed -i -e "s/^BLDOPTS\ *=.*/BLDOPTS\ \ = -fPIC -march=$dir/" $dir/lapack-$LPVER/make.inc
done

# Build in each directory
for dir in $ALL_BUILDS ; do
  echo $dir ;
  pushd $dir/lapack-$LPVER/BLAS/SRC ;
  make $MAKE_OPTS ;
  make $MAKE_OPTS libblas.so ;
  cp libblas.so ../.. ;
  popd ;
  pushd $dir/lapack-$LPVER/SRC ;
  make $MAKE_OPTS ;
  make $MAKE_OPTS liblapack.so ;
  cp liblapack.so .. ;
  popd ;
done

# Done
popd
