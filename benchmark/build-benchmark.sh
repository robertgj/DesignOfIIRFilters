#!/bin/bash

# Assume these packages are installed:
#  dnf install atlas blas lapack gsl gsl-devel openblas openblas-threads

# Assume these archive files are present:
export LAPACK_VERSION=3.12.1
export SUITESPARSE_VERSION=7.10.0
export ARPACK_NG_VERSION=3.9.1
export FFTW_VERSION=3.3.10
export QRUPDATE_VERSION=1.1.2
export OCTAVE_VERSION=9.4.0
export SEDUMI_VERSION=1.3.8
export YALMIP_VERSION=R20230622
for file in lapack-$LAPACK_VERSION".tar.gz" \
            SuiteSparse-$SUITESPARSE_VERSION".tar.gz" \
            arpack-ng-$ARPACK_NG_VERSION".tar.gz" \
            fftw-$FFTW_VERSION".tar.gz" \
            qrupdate-$QRUPDATE_VERSION".tar.gz" \
            octave-$OCTAVE_VERSION".tar.lz" \
            sedumi-$SEDUMI_VERSION".tar.gz" \
            YALMIP-$YALMIP_VERSION".tar.gz" ; 
do 
  cp -f /usr/local/src/octave/$file . ; 
done

# Disable CPU frequency scaling:
 for c in `seq 0 7` ; do
   echo "4500000">/sys/devices/system/cpu/cpu$c/cpufreq/scaling_min_freq ;
   echo "performance">/sys/devices/system/cpu/cpu$c/cpufreq/scaling_governor ;
 done ; 

# Show system information
uname -r
grep -m1 -A7 vendor_id /proc/cpuinfo
sudo cpupower -c all frequency-info
dnf list installed kernel* gcc* atlas* openblas* gsl* blas* lapack* \
    | grep -Ev metadata | awk '{print $1 "\t\t" $2}'

# Build local versions of the lapack and blas libraries
export LOCAL_PREFIX=`pwd`
source ./build-lapack.sh

# Build local versions of the other libraries used by octave
export LAPACK_DIR=$LOCAL_PREFIX/lapack/generic/lapack-$LAPACK_VERSION
export LD_LIBRARY_PATH=$LOCAL_PREFIX"/lib:"$LAPACK_DIR
source ./build-other-libs.sh

# Common octave configure options
export OCTAVE_CONFIG_OPTIONS=" \
       --disable-docs \
       --disable-java \
       --without-fltk \
       --without-qt \
       --without-sndfile \
       --without-portaudio \
       --without-magick \
       --without-glpk \
       --without-hdf5 \
       --with-arpack-includedir=$LOCAL_PREFIX/include \
       --with-arpack-libdir=$LOCAL_PREFIX/lib \
       --with-qrupdate-includedir=$LOCAL_PREFIX/include \
       --with-qrupdate-libdir=$LOCAL_PREFIX/lib \
       --with-amd-includedir=$LOCAL_PREFIX/include \
       --with-amd-libdir=$LOCAL_PREFIX/lib \
       --with-camd-includedir=$LOCAL_PREFIX/include \
       --with-camd-libdir=$LOCAL_PREFIX/lib \
       --with-colamd-includedir=$LOCAL_PREFIX/include \
       --with-colamd-libdir=$LOCAL_PREFIX/lib \
       --with-ccolamd-includedir=$LOCAL_PREFIX/include \
       --with-ccolamd-libdir=$LOCAL_PREFIX/lib \
       --with-cholmod-includedir=$LOCAL_PREFIX/include \
       --with-cholmod-libdir=$LOCAL_PREFIX/lib \
       --with-cxsparse-includedir=$LOCAL_PREFIX/include \
       --with-cxsparse-libdir=$LOCAL_PREFIX/lib \
       --with-umfpack-includedir=$LOCAL_PREFIX/include \
       --with-umfpack-libdir=$LOCAL_PREFIX/lib \
       --with-fftw3-includedir=$LOCAL_PREFIX/include \
       --with-fftw3-libdir=$LOCAL_PREFIX/lib \
       --with-fftw3f-includedir=$LOCAL_PREFIX/include \
       --with-fftw3f-libdir=$LOCAL_PREFIX/lib"

# Unpack Octave
rm -Rf octave-$OCTAVE_VERSION
tar -xf octave-$OCTAVE_VERSION".tar.lz"
# Patch
cat > octave-$OCTAVE_VERSION".patch.uue" << 'EOF'
begin-base64 644 octave-9.4.0.patch
LS0tIG9jdGF2ZS05LjQuMC9saWJpbnRlcnAvY29yZWZjbi9sb2FkLXNhdmUu
Y2MJMjAyNS0wMi0wNiAwNDowMTowNS4wMDAwMDAwMDAgKzExMDAKKysrIG9j
dGF2ZS05LjQuMC5uZXcvbGliaW50ZXJwL2NvcmVmY24vbG9hZC1zYXZlLmNj
CTIwMjUtMDMtMDQgMTY6Mjk6MTMuODc4NTM2MzIwICsxMTAwCkBAIC0xMjks
OCArMTI5LDggQEAKIHsKICAgY29uc3QgaW50IG1hZ2ljX2xlbiA9IDEwOwog
ICBjaGFyIG1hZ2ljW21hZ2ljX2xlbisxXTsKLSAgaXMucmVhZCAobWFnaWMs
IG1hZ2ljX2xlbik7CiAgIG1hZ2ljW21hZ2ljX2xlbl0gPSAnXDAnOworICBp
cy5yZWFkIChtYWdpYywgbWFnaWNfbGVuKTsKIAogICBpZiAoc3RybmNtcCAo
bWFnaWMsICJPY3RhdmUtMS1MIiwgbWFnaWNfbGVuKSA9PSAwKQogICAgIHN3
YXAgPSBtYWNoX2luZm86OndvcmRzX2JpZ19lbmRpYW4gKCk7Ci0tLSBvY3Rh
dmUtOS40LjAvc2NyaXB0cy9zZXQvdW5pcXVlLm0JMjAyNS0wMi0wNiAwNDow
MTowNS4wMDAwMDAwMDAgKzExMDAKKysrIG9jdGF2ZS05LjQuMC5uZXcvc2Ny
aXB0cy9zZXQvdW5pcXVlLm0JMjAyNS0wMy0wNCAxNjoyOToxMy44Nzk1NDYx
OTYgKzExMDAKQEAgLTg0LDkgKzg0LDYgQEAKICMjIG91dHB1dHMgQHZhcntp
fSwgQHZhcntqfSB3aWxsIGZvbGxvdyB0aGUgc2hhcGUgb2YgdGhlIGlucHV0
IEB2YXJ7eH0gcmF0aGVyCiAjIyB0aGFuIGFsd2F5cyBiZWluZyBjb2x1bW4g
dmVjdG9ycy4KICMjCi0jIyBUaGUgdGhpcmQgb3V0cHV0LCBAdmFye2p9LCBo
YXMgbm90IGJlZW4gaW1wbGVtZW50ZWQgeWV0IHdoZW4gdGhlIHNvcnQKLSMj
IG9yZGVyIGlzIEBxY29kZXsic3RhYmxlIn0uCi0jIwogIyMgQHNlZWFsc297
dW5pcXVldG9sLCB1bmlvbiwgaW50ZXJzZWN0LCBzZXRkaWZmLCBzZXR4b3Is
IGlzbWVtYmVyfQogIyMgQGVuZCBkZWZ0eXBlZm4KIApAQCAtMjMwLDM2ICsy
MjcsODYgQEAKICAgICBlbmRpZgogICBlbmRpZgogCi0gICMjIENhbGN1bGF0
ZSBqIG91dHB1dCAoM3JkIG91dHB1dCkKLSAgaWYgKG5hcmdvdXQgPiAyKQot
ICAgIGogPSBpOyAgIyBjaGVhcCB3YXkgdG8gY29weSBkaW1lbnNpb25zCi0g
ICAgaihpKSA9IGN1bXN1bSAoWzE7ICEgbWF0Y2goOildKTsKLSAgICBpZiAo
ISBvcHRzb3J0ZWQpCi0gICAgICB3YXJuaW5nICgidW5pcXVlOiB0aGlyZCBv
dXRwdXQgSiBpcyBub3QgeWV0IGltcGxlbWVudGVkIik7Ci0gICAgICBqID0g
W107Ci0gICAgZW5kaWYKLQotICAgIGlmIChvcHRsZWdhY3kgJiYgaXNyb3d2
ZWMpCi0gICAgICBqID0gai4nOwotICAgIGVuZGlmCi0gIGVuZGlmCi0KICAg
IyMgQ2FsY3VsYXRlIGkgb3V0cHV0ICgybmQgb3V0cHV0KQogICBpZiAobmFy
Z291dCA+IDEpCisKICAgICBpZiAob3B0c29ydGVkKQorCiAgICAgICBpZHgg
PSBmaW5kIChtYXRjaCk7CisKICAgICAgIGlmICghIG9wdGxlZ2FjeSAmJiBv
cHRmaXJzdCkKICAgICAgICAgaWR4ICs9IDE7ICAgIyBpbi1wbGFjZSBpcyBm
YXN0ZXIgdGhhbiBvdGhlciBmb3JtcyBvZiBpbmNyZW1lbnQKICAgICAgIGVu
ZGlmCisKKyAgICAgIGlmIChuYXJnb3V0ID4gMikKKyAgICAgICAgaiA9IGk7
ICAjIGNoZWFwIHdheSB0byBjb3B5IGRpbWVuc2lvbnMKKyAgICAgICAgaihp
KSA9IGN1bXN1bSAoISBbZmFsc2U7IG1hdGNoKDopXSk7CisgICAgICBlbmRp
ZgorCiAgICAgICBpKGlkeCkgPSBbXTsKKwogICAgIGVsc2UKLSAgICAgIGko
W2ZhbHNlOyBtYXRjaCg6KV0pID0gW107Ci0gICAgICAjIyBGSVhNRTogSXMg
dGhlcmUgYSB3YXkgdG8gYXZvaWQgYSBjYWxsIHRvIHNvcnQ/Ci0gICAgICBp
ID0gc29ydCAoaSk7CisKKyAgICAgICMjIEdldCBpbnZlcnNlIG9mIHNvcnQg
aW5kZXggaSBzbyB0aGF0IHNvcnQoeCkoaykgPSB4LgorICAgICAgayA9IGk7
ICAjIGNoZWFwIHdheSB0byBjb3B5IGRpbWVuc2lvbnMKKyAgICAgIGsoaSkg
PSAxOm47CisKKyAgICAgIGlmIChuYXJnb3V0ID4gMikKKworICAgICAgICAj
IyBHZW5lcmF0ZSBsb2dpY2FsIGluZGV4IG9mIHNvcnRlZCB1bmlxdWUgdmFs
dWUgbG9jYXRpb25zLgorICAgICAgICBub21hdGNoID0gISBbZmFsc2U7IG1h
dGNoKDopXTsKKworICAgICAgICAjIyBDYWxjdWxhdGUgaSBvdXRwdXQgYXMg
dGhvc2UgbG9jYXRpb25zIHJlbWFwcGVkIHRvIHVuc29ydGVkIHguCisgICAg
ICAgIGlfb3V0ID0gZmluZCAobm9tYXRjaChrKSk7CisKKyAgICAgICAgIyMg
RmluZCB0aGUgbGluZWFyIGluZGV4ZXMgb2YgdGhlIHVuaXF1ZSBlbGVtZW50
cyBvZiBzb3J0KHgpLgorICAgICAgICB1ID0gZmluZCAobm9tYXRjaCk7CisK
KyAgICAgICAgIyMgRmluZCB1bmlxdWUgaW5kZXhlcyBmb3IgYWxsIGVsZW1l
bnQgbG9jYXRpb25zIC4KKyAgICAgICAgbCA9IHUoY3Vtc3VtIChub21hdGNo
KSk7CisKKyAgICAgICAgIyMgbChrKSBnaXZlcyB1IGVsZW1lbnQgbG9jYXRp
b25zIG1hcHBlZCBiYWNrIHRvIHVuc29ydGVkIHguIEUuZy4sCisgICAgICAg
ICMjIGZvciB4ID0gWzQwLDIwLDQwLDIwLDIwLDMwLDEwXScgIyBkYXRhCisg
ICAgICAgICMjIGkgPSAgIFs3LDIsNCw1LDYsMSwzXScgICAgICAgICAgIyBz
b3J0KHgpIGluZGV4LCB4KGkpID0gc29ydCh4KQorICAgICAgICAjIyBub21h
dGNoID0gWzEsMSwwLDAsMSwxLDBdJyAgICAgICMgbG9naWNhbCBzb3J0ZWQg
aW5kZXggb2YgdW5pcXVlIHgKKyAgICAgICAgIyMgaV9vdXQgPSBbMSwyLDYs
N10nICAgICAgICAgICAgICAjIHVuaXF1ZSBvdXRwdXQgaW5kZXgsIHkgPSB4
KGlfb3V0KQorICAgICAgICAjIyBrID0gWzYsMiw3LDMsNCw1LDFdJyAgICAg
ICAgICAgICMgaW52ZXJzZSBpZHggb2YgaSwgc29ydCh4KShrKSA9IHgKKyAg
ICAgICAgIyMgbCA9IFsxLDIsMiwyLDUsNiw2XScgICAgICAgICAgICAjIHVu
aXF1ZSBlbGVtLiB0byByZXByb2R1Y2Ugc29ydCh4KQorICAgICAgICAjIyBs
KGspID0gWzYsMiw2LDIsMiw1LDFdJyAgICAgICAgICMgdW5pcXVlIGVsZW1l
bnRzIHRvIHJlcHJvZHVjZSAoeCkKKyAgICAgICAgIyMgaShsKGspKSA9ICBb
MSwyLDEsMiwyLDYsN10nICAgICAjIHVuaXF1ZSBlbGVtLiBtYXBwZWQgdG8g
c29ydCh4KWlkeAorICAgICAgICAjIworICAgICAgICAjIyBpX291dCA9PSBp
KGwoaykpJyBicm9hZGNhc3RzIHRvOgorICAgICAgICAjIyAgWyAxICAxICAw
ICAwICAwICAwICAwCisgICAgICAgICMjICAgIDAgIDAgIDEgIDEgIDEgIDAg
IDAKKyAgICAgICAgIyMgICAgMCAgMCAgMCAgMCAgMCAgMSAgMAorICAgICAg
ICAjIyAgICAwICAwICAwICAwICAwICAwICAxIF0KKyAgICAgICAgIyMgUm93
IHZhbHVlIG9mIGVhY2ggY29sdW1uIG1hcHMgaShsKGspKSB0byBpX291dCwg
Z2l2ZXMgaiBmb3IgeShqKT14CisKKyAgICAgICAgIyMgRklYTUU6IDItRCBw
cm9qZWN0aW9uIHRvIGZpbmQgaiBpbmNyZWFzZXMgbGFyZ2VzdCBzdG9yZWQg
ZWxlbWVudAorICAgICAgICAjIyAgICAgICAgZnJvbSBuIHRvIG0geCBuICht
ID0gbnVtZWwgKHkpKSBhbmQgdXNlcyBzbG93ZXIgZmluZAorICAgICAgICAj
IyAgICAgICAgY29kZXBhdGguICBJZGVhbGx5IHdvdWxkIGJlIHJlcGxhY2Vk
IGJ5IGRpcmVjdCBsaW5lYXIgb3IKKyAgICAgICAgIyMgICAgICAgIGxvZ2lj
YWwgaW5kZXhpbmcuCisKKyAgICAgICAgW2osfl0gPSBmaW5kIChpX291dCA9
PSBpKGwoaykpJyk7CisKKyAgICAgICAgIyMgUmVwbGFjZSBmdWxsIHgtPiBz
b3J0KHgpIG91dHB1dCB3aXRoIGR1cGxpY2F0ZXMgcmVtb3ZlZC4KKyAgICAg
ICAgaSA9IGlfb3V0OworICAgICAgZWxzZQorCisgICAgICAgICMjIEZpbmQg
aSBvdXRwdXQgYXMgdW5pcXVlIHZhbHVlIGxvY2F0aW9ucyByZW1hcHBlZCB0
byB1bnNvcnRlZCB4LgorICAgICAgICBpID0gZmluZCAoISBbZmFsc2U7IG1h
dGNoKDopXShrKSk7CisKKyAgICAgIGVuZGlmCisKICAgICBlbmRpZgogCiAg
ICAgaWYgKG9wdGxlZ2FjeSAmJiBpc3Jvd3ZlYykKICAgICAgIGkgPSBpLic7
CisKKyAgICAgIGlmIChuYXJnb3V0ID4gMikKKyAgICAgICAgaiA9IGouJzsK
KyAgICAgIGVuZGlmCisKICAgICBlbmRpZgogICBlbmRpZgogCkBAIC0zMDIs
MTEgKzM0OSwxMCBAQAogJSEgYXNzZXJ0IChqLCBbMTsxOzI7MzszOzM7NF0p
OwogCiAlIXRlc3QKLSUhIFt5LGksfl0gPSB1bmlxdWUgKFs0LDQsMiwyLDIs
MywxXSwgInN0YWJsZSIpOworJSEgW3ksaSxqXSA9IHVuaXF1ZSAoWzQsNCwy
LDIsMiwzLDFdLCAic3RhYmxlIik7CiAlISBhc3NlcnQgKHksIFs0LDIsMywx
XSk7CiAlISBhc3NlcnQgKGksIFsxOzM7Njs3XSk7Ci0lISAjIyBGSVhNRTog
J2onIGlucHV0IG5vdCBjYWxjdWxhdGVkIHdpdGggc3RhYmxlCi0lISAjI2Fz
c2VydCAoaiwgW10pOworJSEgYXNzZXJ0IChqLCBbMTsxOzI7MjsyOzM7NF0p
OwogCiAlIXRlc3QKICUhIFt5LGksal0gPSB1bmlxdWUgKFsxLDEsMiwzLDMs
Myw0XScsICJsYXN0Iik7CkBAIC0zMzUsMTEgKzM4MSwxMCBAQAogCiAlIXRl
c3QKICUhIEEgPSBbNCw1LDY7IDEsMiwzOyA0LDUsNl07Ci0lISBbeSxpLH5d
ID0gdW5pcXVlIChBLCAicm93cyIsICJzdGFibGUiKTsKKyUhIFt5LGksal0g
PSB1bmlxdWUgKEEsICJyb3dzIiwgInN0YWJsZSIpOwogJSEgYXNzZXJ0ICh5
LCBbNCw1LDY7IDEsMiwzXSk7CiAlISBhc3NlcnQgKEEoaSw6KSwgeSk7Ci0l
ISAjIyBGSVhNRTogJ2onIG91dHB1dCBub3QgY2FsY3VsYXRlZCBjb3JyZWN0
bHkgd2l0aCAic3RhYmxlIgotJSEgIyNhc3NlcnQgKHkoaiw6KSwgQSk7Cisl
ISBhc3NlcnQgKHkoaiw6KSwgQSk7CiAKICMjIFRlc3QgImxlZ2FjeSIgb3B0
aW9uCiAlIXRlc3QKQEAgLTM1NSw2ICs0MDAsNTIgQEAKICUhIGFzc2VydCAo
aSwgWzI7IDU7IDQ7IDNdKTsKICUhIGFzc2VydCAoaiwgWzQ7IDE7IDQ7IDM7
IDJdKTsKIAorJSF0ZXN0IDwqNjUxNzY+CislISBhID0gWzMgMiAxIDI7IDIg
MSAyIDFdOworJSEgW28xLCBvMiwgbzNdID0gdW5pcXVlIChhKTsKKyUhIGFz
c2VydCAoe28xLCBvMiwgbzN9LCB7WzE7MjszXSwgWzQ7MjsxXSwgWzM7Mjsy
OzE7MTsyOzI7MV19KTsKKyUhIFtvMSwgbzIsIG8zXSA9IHVuaXF1ZSAoYSwg
InN0YWJsZSIpOworJSEgYXNzZXJ0ICh7bzEsIG8yLCBvM30sIHtbMzsyOzFd
LCBbMTsyOzRdLCBbMTsyOzI7MzszOzI7MjszXX0pCisKKyUhdGVzdCA8KjY1
MTc2PgorJSEgYSA9IFszIDIgMSAyOyAyIDEgMiAxXTsKKyUhIFtvMSwgbzIs
IG8zXSA9IHVuaXF1ZSAoYSgxLDopLCAicm93cyIpOworJSEgYXNzZXJ0ICh7
bzEsIG8yLCBvM30sIHthKDEsOiksIDEsIDF9KTsKKyUhIFtvMSwgbzIsIG8z
XSA9IHVuaXF1ZSAoYSgxLDopLCAicm93cyIsICJzdGFibGUiKTsKKyUhIGFz
c2VydCAoe28xLCBvMiwgbzN9LCB7YSgxLDopLCAxLCAxfSk7CislISBbbzEs
IG8yLCBvM10gPSB1bmlxdWUgKGEsICJyb3dzIik7CislISBhc3NlcnQgKHtv
MSwgbzIsIG8zfSwge1thKDIsOik7IGEoMSw6KV0sIFsyOzFdLCBbMjsxXX0p
OworJSEgW28xLCBvMiwgbzNdID0gdW5pcXVlIChhLCAicm93cyIsICJzdGFi
bGUiKTsKKyUhIGFzc2VydCAoe28xLCBvMiwgbzN9LCB7YSwgWzE7Ml0sIFsx
OzJdfSk7CislISBbbzEsIG8yLCBvM10gPSB1bmlxdWUgKFthO2FdLCAicm93
cyIpOworJSEgYXNzZXJ0ICh7bzEsIG8yLCBvM30sIHtbYSgyLDopOyBhKDEs
OildLCBbMjsxXSwgWzI7MTsyOzFdfSk7CislISBbbzEsIG8yLCBvM10gPSB1
bmlxdWUgKFthO2FdLCAicm93cyIsICJzdGFibGUiKTsKKyUhIGFzc2VydCAo
e28xLCBvMiwgbzN9LCB7YSwgWzE7Ml0sIFsxOzI7MTsyXX0pOworCislIXRl
c3QgPCo2NTE3Nj4KKyUhIGEgPSBnYWxsZXJ5ICgiaW50ZWdlcmRhdGEiLCBb
LTEwMCwgMTAwXSwgNiwgNik7CislISBhID0gW2EoMiw6KTsgYSgxOjUsOik7
IGEoMjo2LDopXTsKKyUhIFtvMSwgbzIsIG8zXSA9IHVuaXF1ZSAoYSk7Cisl
ISBhc3NlcnQgKHtvMSwgbzEobzMpLCBvMiwgbzN9LCB7YSg6KShvMiksIGEo
OiksIC4uLgorJSEgWzI2OzIyOzM0OzQ1OzU3OyA2OzExOzE3OzMzOzI4OzM1
OzE1OzU2OyAyOzU5OyA0OzY2OyAuLi4KKyUhICAxNjs1MDs0OTsyNzsyNDsz
Nzs0NDs0ODszOTszODsxMzsyMzsgNTsxMjs0Njs1NTsgMV0sIC4uLgorJSEg
WzM0OzE0OzM0OzE2OzMwOyA2OzM0OzE2OzMwOyA2OyA3OzMxOzI4OzMxOzEy
OzE4OyA4OzMxOzEyOzE4OyA4OyAyOzI5OyAuLi4KKyUhICAyMjsyOTsgMTsy
MTsxMDsyOTsgMTsyMTsxMDsgOTsgMzsxMTsgMzsyMzsyNzsyNjsgMzsyMzsy
NzsyNjsyNDsgNDszMjsgLi4uCislISAgNDsgMjU7MjA7MTk7IDQ7MjU7MjA7
MTk7MzM7MTM7IDU7MTM7MTU7IDI7MjQ7MTM7MTU7IDI7MjQ7MTddfSk7Cisl
ISBbbzEsIG8yLCBvM10gPSB1bmlxdWUgKGEsICJzdGFibGUiKTsKKyUhIGFz
c2VydCAoe28xLCBvMShvMyksIG8yLCBvM30sIHthKDopKG8yKSwgYSg6KSwg
Li4uCislISBbIDE7IDI7IDQ7IDU7IDY7MTE7MTI7MTM7MTU7MTY7MTc7MjI7
MjM7MjQ7MjY7Mjc7Mjg7IC4uLgorJSEgIDMzOzM0OzM1OzM3OzM4OzM5OzQ0
OzQ1OzQ2OzQ4OzQ5OzUwOzU1OzU2OzU3OzU5OzY2XSwgLi4uCislISBbIDE7
IDI7IDE7IDM7IDQ7IDU7IDE7IDM7IDQ7IDU7IDY7IDc7IDg7IDc7IDk7MTA7
MTE7IDc7IDk7MTA7MTE7MTI7MTM7IC4uLgorJSEgIDE0OzEzOzE1OzE2OzE3
OzEzOzE1OzE2OzE3OzE4OzE5OzIwOzE5OzIxOzIyOzIzOzE5OzIxOzIyOzIz
OzI0OzI1OzI2Oy4uLgorJSEgIDI1OzI3OzI4OzI5OzI1OzI3OzI4OzI5OzMw
OzMxOzMyOzMxOzMzOzEyOzI0OzMxOzMzOzEyOzI0OzM0XX0pOworJSEgW28x
LCBvMiwgbzNdID0gdW5pcXVlIChhLCAicm93cyIpOworJSEgYXNzZXJ0ICh7
bzEsIG8xKG8zLDopLCBvMiwgbzN9LCB7YShvMiw6KSwgYSwgLi4uCislISBb
NjsxMTsyOzQ7NTsxXSwgWzY7Mzs2OzQ7NTsxOzY7NDs1OzE7Ml19KTsKKyUh
IFtvMSwgbzIsIG8zXSA9IHVuaXF1ZSAoYSwgInJvd3MiLCAic3RhYmxlIik7
CislISBhc3NlcnQgKHtvMSwgbzEobzMsOiksIG8yLCBvM30sIHthKG8yLDop
LCBhLCAuLi4KKyUhIFsxOzI7NDs1OzY7MTFdLCBbMTsyOzE7Mzs0OzU7MTsz
OzQ7NTs2XX0pOworCiAjIyBUZXN0IGlucHV0IHZhbGlkYXRpb24KICUhZXJy
b3IgPEludmFsaWQgY2FsbD4gdW5pcXVlICgpCiAlIWVycm9yIDxYIG11c3Qg
YmUgYW4gYXJyYXkgb3IgY2VsbCBhcnJheSBvZiBzdHJpbmdzPiB1bmlxdWUg
KHsxfSkKQEAgLTM3Niw2ICs0NjcsNCBAQAogJSFlcnJvciA8aW52YWxpZCBv
cHRpb24+IHVuaXF1ZSAoeyJhIiwgImIiLCAiYyJ9LCAicm93cyIsICJVbmtu
b3duT3B0aW9uMiIpCiAlIWVycm9yIDxpbnZhbGlkIG9wdGlvbj4gdW5pcXVl
ICh7ImEiLCAiYiIsICJjIn0sICJVbmtub3duT3B0aW9uMSIsICJsYXN0IikK
ICUhd2FybmluZyA8InJvd3MiIGlzIGlnbm9yZWQgZm9yIGNlbGwgYXJyYXlz
PiB1bmlxdWUgKHsiMSJ9LCAicm93cyIpOwotJSF3YXJuaW5nIDx0aGlyZCBv
dXRwdXQgSiBpcyBub3QgeWV0IGltcGxlbWVudGVkPgotJSEgW3ksaSxqXSA9
IHVuaXF1ZSAoWzIsMV0sICJzdGFibGUiKTsKLSUhIGFzc2VydCAoaiwgW10p
OworCg==
====
EOF
uudecode octave-$OCTAVE_VERSION.patch.uue > octave-$OCTAVE_VERSION.patch
pushd octave-$OCTAVE_VERSION
patch -p1 < ../octave-$OCTAVE_VERSION.patch
popd

# Build the benchmark versions
OCTAVE_DIR=$LOCAL_PREFIX/octave-$OCTAVE_VERSION ;
for BUILD in dbg shared shared-lto shared-pgo shared-lto-pgo ;
do
    #
    echo "Building" $BUILD
    #
    OCTAVE_INSTALL_DIR=$LOCAL_PREFIX/octave-$BUILD
    OCTAVE_BIN_DIR=$OCTAVE_INSTALL_DIR/bin
    OCTAVE_SHARE_DIR=$OCTAVE_INSTALL_DIR/share/octave
    OCTAVE_PACKAGE_DIR=$OCTAVE_SHARE_DIR/packages 
    OCTAVE_PACKAGES=$OCTAVE_SHARE_DIR/octave_packages
    #
    rm -Rf build-$BUILD
    #
    mkdir -p build-$BUILD
    #
    pushd build-$BUILD
    #
    source ../build-$BUILD.sh
    #
    make install
    # 
    $OCTAVE_BIN_DIR/octave-cli --eval "__octave_config_info__"
    #
    popd
    #
done

# Benchmark the builds with the generic lapack library
cat > iir_benchmark.m << 'EOF'
% Define a filter
fc=0.10;U=2;V=2;M=20;Q=8;R=3;tol=1e-6;
x0=[ 0.0089234, ...
     2.0000000, -2.0000000,  ...
     0.5000000, -0.5000000,  ...
    -0.5000000, -0.5000000,  0.5000000,  0.5000000,  0.5000000, ...
     0.5000000,  0.5000000,  0.5000000,  0.5000000,  0.8000000, ...
     0.6700726,  0.7205564,  0.8963898,  1.1980053,  1.3738387, ...
     1.4243225,  2.7644677,  2.8149515,  2.9907849,  1.9896753, ...
    -0.9698147, -0.8442244,  0.4511337,  0.4242641, ...
     1.8917946,  1.7780303,  1.2325954,  0.7853982 ]';
% Run
nplot=4000;
w=(0:(nplot-1))'*pi/nplot;
id=tic();
for n=1:100
  [A,gradA,hessA]=iirA(w,x0,U,V,M,Q,R,tol);
  [T,gradT,hessT]=iirT(w,x0,U,V,M,Q,R,tol);
  [P,gradP]=iirP(w,x0,U,V,M,Q,R,tol);
endfor
toc(id)
EOF
cp -f ../src/{fixResultNaN,iirA,iirP,iirT}.m .

for BUILD in dbg shared shared-lto shared-pgo shared-lto-pgo ;
do
    #
    echo "Testing " $BUILD
    #
    OCTAVE_BIN_DIR=$LOCAL_PREFIX/octave-$BUILD/bin
    for k in `seq 1 10`; do \
        LD_PRELOAD=$LAPACK_DIR"/liblapack.so:"$LAPACK_DIR"/libblas.so" \
                              $OCTAVE_BIN_DIR/octave-cli iir_benchmark.m
    done | awk -v build_var=$BUILD '{elapsed=elapsed+$4;}; \
      END {printf("iir_benchmark %s elapsed=%g\n",build_var,elapsed/10);}'
    #
done

# Now do library benchmarking
source ./library-benchmark.sh
