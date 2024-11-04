#!/bin/bash

# Assume these packages are installed:
#  dnf install atlas blas lapack gsl gsl-devel openblas openblas-threads

# Assume these archive files are present:
export LAPACK_VERSION=3.12.0
export SUITESPARSE_VERSION=7.8.3
export ARPACK_NG_VERSION=3.9.1
export FFTW_VERSION=3.3.10
export QRUPDATE_VERSION=1.1.2
export OCTAVE_VERSION=9.2.0
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
begin-base64 644 octave-9.2.0.patch
LS0tIG9jdGF2ZS05LjIuMC5vcmlnL2xpYmludGVycC9jb3JlZmNuL2xvYWQt
c2F2ZS5jYwkyMDI0LTA2LTAyIDAxOjA1OjA4LjAwMDAwMDAwMCArMTAwMAor
Kysgb2N0YXZlLTkuMi4wL2xpYmludGVycC9jb3JlZmNuL2xvYWQtc2F2ZS5j
YwkyMDI0LTA2LTEzIDIzOjM5OjAxLjIyNzEwNzYzMSArMTAwMApAQCAtMTI5
LDggKzEyOSw4IEBACiB7CiAgIGNvbnN0IGludCBtYWdpY19sZW4gPSAxMDsK
ICAgY2hhciBtYWdpY1ttYWdpY19sZW4rMV07Ci0gIGlzLnJlYWQgKG1hZ2lj
LCBtYWdpY19sZW4pOwogICBtYWdpY1ttYWdpY19sZW5dID0gJ1wwJzsKKyAg
aXMucmVhZCAobWFnaWMsIG1hZ2ljX2xlbik7CiAKICAgaWYgKHN0cm5jbXAg
KG1hZ2ljLCAiT2N0YXZlLTEtTCIsIG1hZ2ljX2xlbikgPT0gMCkKICAgICBz
d2FwID0gbWFjaF9pbmZvOjp3b3Jkc19iaWdfZW5kaWFuICgpOwotLS0gb2N0
YXZlLTkuMi4wLm9yaWcvc2NyaXB0cy9zZXQvdW5pcXVlLm0JMjAyNC0wNi0w
MiAwMTowNTowOC4wMDAwMDAwMDAgKzEwMDAKKysrIG9jdGF2ZS05LjIuMC9z
Y3JpcHRzL3NldC91bmlxdWUubQkyMDI0LTA2LTEzIDIzOjM5OjAxLjIyOTEw
NzYxNSArMTAwMApAQCAtODQsOSArODQsNiBAQAogIyMgb3V0cHV0cyBAdmFy
e2l9LCBAdmFye2p9IHdpbGwgZm9sbG93IHRoZSBzaGFwZSBvZiB0aGUgaW5w
dXQgQHZhcnt4fSByYXRoZXIKICMjIHRoYW4gYWx3YXlzIGJlaW5nIGNvbHVt
biB2ZWN0b3JzLgogIyMKLSMjIFRoZSB0aGlyZCBvdXRwdXQsIEB2YXJ7an0s
IGhhcyBub3QgYmVlbiBpbXBsZW1lbnRlZCB5ZXQgd2hlbiB0aGUgc29ydAot
IyMgb3JkZXIgaXMgQHFjb2RleyJzdGFibGUifS4KLSMjCiAjIyBAc2VlYWxz
b3t1bmlxdWV0b2wsIHVuaW9uLCBpbnRlcnNlY3QsIHNldGRpZmYsIHNldHhv
ciwgaXNtZW1iZXJ9CiAjIyBAZW5kIGRlZnR5cGVmbgogCkBAIC0yMzAsMzYg
KzIyNyw4NiBAQAogICAgIGVuZGlmCiAgIGVuZGlmCiAKLSAgIyMgQ2FsY3Vs
YXRlIGogb3V0cHV0ICgzcmQgb3V0cHV0KQotICBpZiAobmFyZ291dCA+IDIp
Ci0gICAgaiA9IGk7ICAjIGNoZWFwIHdheSB0byBjb3B5IGRpbWVuc2lvbnMK
LSAgICBqKGkpID0gY3Vtc3VtIChbMTsgISBtYXRjaCg6KV0pOwotICAgIGlm
ICghIG9wdHNvcnRlZCkKLSAgICAgIHdhcm5pbmcgKCJ1bmlxdWU6IHRoaXJk
IG91dHB1dCBKIGlzIG5vdCB5ZXQgaW1wbGVtZW50ZWQiKTsKLSAgICAgIGog
PSBbXTsKLSAgICBlbmRpZgotCi0gICAgaWYgKG9wdGxlZ2FjeSAmJiBpc3Jv
d3ZlYykKLSAgICAgIGogPSBqLic7Ci0gICAgZW5kaWYKLSAgZW5kaWYKLQog
ICAjIyBDYWxjdWxhdGUgaSBvdXRwdXQgKDJuZCBvdXRwdXQpCiAgIGlmIChu
YXJnb3V0ID4gMSkKKwogICAgIGlmIChvcHRzb3J0ZWQpCisKICAgICAgIGlk
eCA9IGZpbmQgKG1hdGNoKTsKKwogICAgICAgaWYgKCEgb3B0bGVnYWN5ICYm
IG9wdGZpcnN0KQogICAgICAgICBpZHggKz0gMTsgICAjIGluLXBsYWNlIGlz
IGZhc3RlciB0aGFuIG90aGVyIGZvcm1zIG9mIGluY3JlbWVudAogICAgICAg
ZW5kaWYKKworICAgICAgaWYgKG5hcmdvdXQgPiAyKQorICAgICAgICBqID0g
aTsgICMgY2hlYXAgd2F5IHRvIGNvcHkgZGltZW5zaW9ucworICAgICAgICBq
KGkpID0gY3Vtc3VtICghIFtmYWxzZTsgbWF0Y2goOildKTsKKyAgICAgIGVu
ZGlmCisKICAgICAgIGkoaWR4KSA9IFtdOworCiAgICAgZWxzZQotICAgICAg
aShbZmFsc2U7IG1hdGNoKDopXSkgPSBbXTsKLSAgICAgICMjIEZJWE1FOiBJ
cyB0aGVyZSBhIHdheSB0byBhdm9pZCBhIGNhbGwgdG8gc29ydD8KLSAgICAg
IGkgPSBzb3J0IChpKTsKKworICAgICAgIyMgR2V0IGludmVyc2Ugb2Ygc29y
dCBpbmRleCBpIHNvIHRoYXQgc29ydCh4KShrKSA9IHguCisgICAgICBrID0g
aTsgICMgY2hlYXAgd2F5IHRvIGNvcHkgZGltZW5zaW9ucworICAgICAgayhp
KSA9IDE6bjsKKworICAgICAgaWYgKG5hcmdvdXQgPiAyKQorCisgICAgICAg
ICMjIEdlbmVyYXRlIGxvZ2ljYWwgaW5kZXggb2Ygc29ydGVkIHVuaXF1ZSB2
YWx1ZSBsb2NhdGlvbnMuCisgICAgICAgIG5vbWF0Y2ggPSAhIFtmYWxzZTsg
bWF0Y2goOildOworCisgICAgICAgICMjIENhbGN1bGF0ZSBpIG91dHB1dCBh
cyB0aG9zZSBsb2NhdGlvbnMgcmVtYXBwZWQgdG8gdW5zb3J0ZWQgeC4KKyAg
ICAgICAgaV9vdXQgPSBmaW5kIChub21hdGNoKGspKTsKKworICAgICAgICAj
IyBGaW5kIHRoZSBsaW5lYXIgaW5kZXhlcyBvZiB0aGUgdW5pcXVlIGVsZW1l
bnRzIG9mIHNvcnQoeCkuCisgICAgICAgIHUgPSBmaW5kIChub21hdGNoKTsK
KworICAgICAgICAjIyBGaW5kIHVuaXF1ZSBpbmRleGVzIGZvciBhbGwgZWxl
bWVudCBsb2NhdGlvbnMgLgorICAgICAgICBsID0gdShjdW1zdW0gKG5vbWF0
Y2gpKTsKKworICAgICAgICAjIyBsKGspIGdpdmVzIHUgZWxlbWVudCBsb2Nh
dGlvbnMgbWFwcGVkIGJhY2sgdG8gdW5zb3J0ZWQgeC4gRS5nLiwKKyAgICAg
ICAgIyMgZm9yIHggPSBbNDAsMjAsNDAsMjAsMjAsMzAsMTBdJyAjIGRhdGEK
KyAgICAgICAgIyMgaSA9ICAgWzcsMiw0LDUsNiwxLDNdJyAgICAgICAgICAj
IHNvcnQoeCkgaW5kZXgsIHgoaSkgPSBzb3J0KHgpCisgICAgICAgICMjIG5v
bWF0Y2ggPSBbMSwxLDAsMCwxLDEsMF0nICAgICAgIyBsb2dpY2FsIHNvcnRl
ZCBpbmRleCBvZiB1bmlxdWUgeAorICAgICAgICAjIyBpX291dCA9IFsxLDIs
Niw3XScgICAgICAgICAgICAgICMgdW5pcXVlIG91dHB1dCBpbmRleCwgeSA9
IHgoaV9vdXQpCisgICAgICAgICMjIGsgPSBbNiwyLDcsMyw0LDUsMV0nICAg
ICAgICAgICAgIyBpbnZlcnNlIGlkeCBvZiBpLCBzb3J0KHgpKGspID0geAor
ICAgICAgICAjIyBsID0gWzEsMiwyLDIsNSw2LDZdJyAgICAgICAgICAgICMg
dW5pcXVlIGVsZW0uIHRvIHJlcHJvZHVjZSBzb3J0KHgpCisgICAgICAgICMj
IGwoaykgPSBbNiwyLDYsMiwyLDUsMV0nICAgICAgICAgIyB1bmlxdWUgZWxl
bWVudHMgdG8gcmVwcm9kdWNlICh4KQorICAgICAgICAjIyBpKGwoaykpID0g
IFsxLDIsMSwyLDIsNiw3XScgICAgICMgdW5pcXVlIGVsZW0uIG1hcHBlZCB0
byBzb3J0KHgpaWR4CisgICAgICAgICMjCisgICAgICAgICMjIGlfb3V0ID09
IGkobChrKSknIGJyb2FkY2FzdHMgdG86CisgICAgICAgICMjICBbIDEgIDEg
IDAgIDAgIDAgIDAgIDAKKyAgICAgICAgIyMgICAgMCAgMCAgMSAgMSAgMSAg
MCAgMAorICAgICAgICAjIyAgICAwICAwICAwICAwICAwICAxICAwCisgICAg
ICAgICMjICAgIDAgIDAgIDAgIDAgIDAgIDAgIDEgXQorICAgICAgICAjIyBS
b3cgdmFsdWUgb2YgZWFjaCBjb2x1bW4gbWFwcyBpKGwoaykpIHRvIGlfb3V0
LCBnaXZlcyBqIGZvciB5KGopPXgKKworICAgICAgICAjIyBGSVhNRTogMi1E
IHByb2plY3Rpb24gdG8gZmluZCBqIGluY3JlYXNlcyBsYXJnZXN0IHN0b3Jl
ZCBlbGVtZW50CisgICAgICAgICMjICAgICAgICBmcm9tIG4gdG8gbSB4IG4g
KG0gPSBudW1lbCAoeSkpIGFuZCB1c2VzIHNsb3dlciBmaW5kCisgICAgICAg
ICMjICAgICAgICBjb2RlcGF0aC4gIElkZWFsbHkgd291bGQgYmUgcmVwbGFj
ZWQgYnkgZGlyZWN0IGxpbmVhciBvcgorICAgICAgICAjIyAgICAgICAgbG9n
aWNhbCBpbmRleGluZy4KKworICAgICAgICBbaix+XSA9IGZpbmQgKGlfb3V0
ID09IGkobChrKSknKTsKKworICAgICAgICAjIyBSZXBsYWNlIGZ1bGwgeC0+
IHNvcnQoeCkgb3V0cHV0IHdpdGggZHVwbGljYXRlcyByZW1vdmVkLgorICAg
ICAgICBpID0gaV9vdXQ7CisgICAgICBlbHNlCisKKyAgICAgICAgIyMgRmlu
ZCBpIG91dHB1dCBhcyB1bmlxdWUgdmFsdWUgbG9jYXRpb25zIHJlbWFwcGVk
IHRvIHVuc29ydGVkIHguCisgICAgICAgIGkgPSBmaW5kICghIFtmYWxzZTsg
bWF0Y2goOildKGspKTsKKworICAgICAgZW5kaWYKKwogICAgIGVuZGlmCiAK
ICAgICBpZiAob3B0bGVnYWN5ICYmIGlzcm93dmVjKQogICAgICAgaSA9IGku
JzsKKworICAgICAgaWYgKG5hcmdvdXQgPiAyKQorICAgICAgICBqID0gai4n
OworICAgICAgZW5kaWYKKwogICAgIGVuZGlmCiAgIGVuZGlmCiAKQEAgLTMw
MiwxMSArMzQ5LDEwIEBACiAlISBhc3NlcnQgKGosIFsxOzE7MjszOzM7Mzs0
XSk7CiAKICUhdGVzdAotJSEgW3ksaSx+XSA9IHVuaXF1ZSAoWzQsNCwyLDIs
MiwzLDFdLCAic3RhYmxlIik7CislISBbeSxpLGpdID0gdW5pcXVlIChbNCw0
LDIsMiwyLDMsMV0sICJzdGFibGUiKTsKICUhIGFzc2VydCAoeSwgWzQsMiwz
LDFdKTsKICUhIGFzc2VydCAoaSwgWzE7Mzs2OzddKTsKLSUhICMjIEZJWE1F
OiAnaicgaW5wdXQgbm90IGNhbGN1bGF0ZWQgd2l0aCBzdGFibGUKLSUhICMj
YXNzZXJ0IChqLCBbXSk7CislISBhc3NlcnQgKGosIFsxOzE7MjsyOzI7Mzs0
XSk7CiAKICUhdGVzdAogJSEgW3ksaSxqXSA9IHVuaXF1ZSAoWzEsMSwyLDMs
MywzLDRdJywgImxhc3QiKTsKQEAgLTMzNSwxMSArMzgxLDEwIEBACiAKICUh
dGVzdAogJSEgQSA9IFs0LDUsNjsgMSwyLDM7IDQsNSw2XTsKLSUhIFt5LGks
fl0gPSB1bmlxdWUgKEEsICJyb3dzIiwgInN0YWJsZSIpOworJSEgW3ksaSxq
XSA9IHVuaXF1ZSAoQSwgInJvd3MiLCAic3RhYmxlIik7CiAlISBhc3NlcnQg
KHksIFs0LDUsNjsgMSwyLDNdKTsKICUhIGFzc2VydCAoQShpLDopLCB5KTsK
LSUhICMjIEZJWE1FOiAnaicgb3V0cHV0IG5vdCBjYWxjdWxhdGVkIGNvcnJl
Y3RseSB3aXRoICJzdGFibGUiCi0lISAjI2Fzc2VydCAoeShqLDopLCBBKTsK
KyUhIGFzc2VydCAoeShqLDopLCBBKTsKIAogIyMgVGVzdCAibGVnYWN5IiBv
cHRpb24KICUhdGVzdApAQCAtMzU1LDYgKzQwMCw1MiBAQAogJSEgYXNzZXJ0
IChpLCBbMjsgNTsgNDsgM10pOwogJSEgYXNzZXJ0IChqLCBbNDsgMTsgNDsg
MzsgMl0pOwogCislIXRlc3QgPCo2NTE3Nj4KKyUhIGEgPSBbMyAyIDEgMjsg
MiAxIDIgMV07CislISBbbzEsIG8yLCBvM10gPSB1bmlxdWUgKGEpOworJSEg
YXNzZXJ0ICh7bzEsIG8yLCBvM30sIHtbMTsyOzNdLCBbNDsyOzFdLCBbMzsy
OzI7MTsxOzI7MjsxXX0pOworJSEgW28xLCBvMiwgbzNdID0gdW5pcXVlIChh
LCAic3RhYmxlIik7CislISBhc3NlcnQgKHtvMSwgbzIsIG8zfSwge1szOzI7
MV0sIFsxOzI7NF0sIFsxOzI7MjszOzM7MjsyOzNdfSkKKworJSF0ZXN0IDwq
NjUxNzY+CislISBhID0gWzMgMiAxIDI7IDIgMSAyIDFdOworJSEgW28xLCBv
MiwgbzNdID0gdW5pcXVlIChhKDEsOiksICJyb3dzIik7CislISBhc3NlcnQg
KHtvMSwgbzIsIG8zfSwge2EoMSw6KSwgMSwgMX0pOworJSEgW28xLCBvMiwg
bzNdID0gdW5pcXVlIChhKDEsOiksICJyb3dzIiwgInN0YWJsZSIpOworJSEg
YXNzZXJ0ICh7bzEsIG8yLCBvM30sIHthKDEsOiksIDEsIDF9KTsKKyUhIFtv
MSwgbzIsIG8zXSA9IHVuaXF1ZSAoYSwgInJvd3MiKTsKKyUhIGFzc2VydCAo
e28xLCBvMiwgbzN9LCB7W2EoMiw6KTsgYSgxLDopXSwgWzI7MV0sIFsyOzFd
fSk7CislISBbbzEsIG8yLCBvM10gPSB1bmlxdWUgKGEsICJyb3dzIiwgInN0
YWJsZSIpOworJSEgYXNzZXJ0ICh7bzEsIG8yLCBvM30sIHthLCBbMTsyXSwg
WzE7Ml19KTsKKyUhIFtvMSwgbzIsIG8zXSA9IHVuaXF1ZSAoW2E7YV0sICJy
b3dzIik7CislISBhc3NlcnQgKHtvMSwgbzIsIG8zfSwge1thKDIsOik7IGEo
MSw6KV0sIFsyOzFdLCBbMjsxOzI7MV19KTsKKyUhIFtvMSwgbzIsIG8zXSA9
IHVuaXF1ZSAoW2E7YV0sICJyb3dzIiwgInN0YWJsZSIpOworJSEgYXNzZXJ0
ICh7bzEsIG8yLCBvM30sIHthLCBbMTsyXSwgWzE7MjsxOzJdfSk7CisKKyUh
dGVzdCA8KjY1MTc2PgorJSEgYSA9IGdhbGxlcnkgKCJpbnRlZ2VyZGF0YSIs
IFstMTAwLCAxMDBdLCA2LCA2KTsKKyUhIGEgPSBbYSgyLDopOyBhKDE6NSw6
KTsgYSgyOjYsOildOworJSEgW28xLCBvMiwgbzNdID0gdW5pcXVlIChhKTsK
KyUhIGFzc2VydCAoe28xLCBvMShvMyksIG8yLCBvM30sIHthKDopKG8yKSwg
YSg6KSwgLi4uCislISBbMjY7MjI7MzQ7NDU7NTc7IDY7MTE7MTc7MzM7Mjg7
MzU7MTU7NTY7IDI7NTk7IDQ7NjY7IC4uLgorJSEgIDE2OzUwOzQ5OzI3OzI0
OzM3OzQ0OzQ4OzM5OzM4OzEzOzIzOyA1OzEyOzQ2OzU1OyAxXSwgLi4uCisl
ISBbMzQ7MTQ7MzQ7MTY7MzA7IDY7MzQ7MTY7MzA7IDY7IDc7MzE7Mjg7MzE7
MTI7MTg7IDg7MzE7MTI7MTg7IDg7IDI7Mjk7IC4uLgorJSEgIDIyOzI5OyAx
OzIxOzEwOzI5OyAxOzIxOzEwOyA5OyAzOzExOyAzOzIzOzI3OzI2OyAzOzIz
OzI3OzI2OzI0OyA0OzMyOyAuLi4KKyUhICA0OyAyNTsyMDsxOTsgNDsyNTsy
MDsxOTszMzsxMzsgNTsxMzsxNTsgMjsyNDsxMzsxNTsgMjsyNDsxN119KTsK
KyUhIFtvMSwgbzIsIG8zXSA9IHVuaXF1ZSAoYSwgInN0YWJsZSIpOworJSEg
YXNzZXJ0ICh7bzEsIG8xKG8zKSwgbzIsIG8zfSwge2EoOikobzIpLCBhKDop
LCAuLi4KKyUhIFsgMTsgMjsgNDsgNTsgNjsxMTsxMjsxMzsxNTsxNjsxNzsy
MjsyMzsyNDsyNjsyNzsyODsgLi4uCislISAgMzM7MzQ7MzU7Mzc7Mzg7Mzk7
NDQ7NDU7NDY7NDg7NDk7NTA7NTU7NTY7NTc7NTk7NjZdLCAuLi4KKyUhIFsg
MTsgMjsgMTsgMzsgNDsgNTsgMTsgMzsgNDsgNTsgNjsgNzsgODsgNzsgOTsx
MDsxMTsgNzsgOTsxMDsxMTsxMjsxMzsgLi4uCislISAgMTQ7MTM7MTU7MTY7
MTc7MTM7MTU7MTY7MTc7MTg7MTk7MjA7MTk7MjE7MjI7MjM7MTk7MjE7MjI7
MjM7MjQ7MjU7MjY7Li4uCislISAgMjU7Mjc7Mjg7Mjk7MjU7Mjc7Mjg7Mjk7
MzA7MzE7MzI7MzE7MzM7MTI7MjQ7MzE7MzM7MTI7MjQ7MzRdfSk7CislISBb
bzEsIG8yLCBvM10gPSB1bmlxdWUgKGEsICJyb3dzIik7CislISBhc3NlcnQg
KHtvMSwgbzEobzMsOiksIG8yLCBvM30sIHthKG8yLDopLCBhLCAuLi4KKyUh
IFs2OzExOzI7NDs1OzFdLCBbNjszOzY7NDs1OzE7Njs0OzU7MTsyXX0pOwor
JSEgW28xLCBvMiwgbzNdID0gdW5pcXVlIChhLCAicm93cyIsICJzdGFibGUi
KTsKKyUhIGFzc2VydCAoe28xLCBvMShvMyw6KSwgbzIsIG8zfSwge2EobzIs
OiksIGEsIC4uLgorJSEgWzE7Mjs0OzU7NjsxMV0sIFsxOzI7MTszOzQ7NTsx
OzM7NDs1OzZdfSk7CisKICMjIFRlc3QgaW5wdXQgdmFsaWRhdGlvbgogJSFl
cnJvciA8SW52YWxpZCBjYWxsPiB1bmlxdWUgKCkKICUhZXJyb3IgPFggbXVz
dCBiZSBhbiBhcnJheSBvciBjZWxsIGFycmF5IG9mIHN0cmluZ3M+IHVuaXF1
ZSAoezF9KQpAQCAtMzc2LDYgKzQ2Nyw0IEBACiAlIWVycm9yIDxpbnZhbGlk
IG9wdGlvbj4gdW5pcXVlICh7ImEiLCAiYiIsICJjIn0sICJyb3dzIiwgIlVu
a25vd25PcHRpb24yIikKICUhZXJyb3IgPGludmFsaWQgb3B0aW9uPiB1bmlx
dWUgKHsiYSIsICJiIiwgImMifSwgIlVua25vd25PcHRpb24xIiwgImxhc3Qi
KQogJSF3YXJuaW5nIDwicm93cyIgaXMgaWdub3JlZCBmb3IgY2VsbCBhcnJh
eXM+IHVuaXF1ZSAoeyIxIn0sICJyb3dzIik7Ci0lIXdhcm5pbmcgPHRoaXJk
IG91dHB1dCBKIGlzIG5vdCB5ZXQgaW1wbGVtZW50ZWQ+Ci0lISBbeSxpLGpd
ID0gdW5pcXVlIChbMiwxXSwgInN0YWJsZSIpOwotJSEgYXNzZXJ0IChqLCBb
XSk7CisK
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
