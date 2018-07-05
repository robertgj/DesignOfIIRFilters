#!/bin/sh

prog=directFIRsymmetricSqErr_bandpass_test.m
depends="directFIRsymmetricSqErr_bandpass_test.m test_common.m \
directFIRsymmetricA.m directFIRsymmetricEsq.m directFIRsymmetricEsqPW.m \
directFIRsymmetricSqErr_bandpass.m"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
echo $here
for file in $depends;do \
  cp -R src/$file $tmp; \
  if [ $? -ne 0 ]; then echo "Failed cp "$file; fail; fi \
done
cd $tmp
if [ $? -ne 0 ]; then echo "Failed cd"; fail; fi

#
# the output should look like this
#
cat > test.ok << 'EOF'
npoints =    1.0000e+04
nchk=[nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu];
nchk=[ 1001 1002 2000 2001 4001 4002 5000 5001 ];
wa(nchk)*0.5/pi=[  0.05 0.05005 0.09995    0.1    0.2    0.2 0.2499   0.25 ];
Ad(nchk)=[      0      0      0      1      1      0      0      0 ];
Wa(nchk)=[     30      0      0      1      1      0      0     30 ];
tol =    1.0000e-08
EsqPW =    5.1993e-04
Esq =    5.2043e-04
Esq_A =    5.2043e-04
Esq_Q =    5.1993e-04
IER_Q =    0.0000e+00
NFUN_Q =    1.5750e+03
ERR_Q =    1.2347e-09
Esq_V =    5.1996e-04
NFUN_V =    4.2100e+02
Esq_CC =    1.2683e-04
ERR_CC =    8.3049e-05
NR_CC =    2.7089e+04
Esq_GK =    4.8235e-05
ERR_GK =    6.2573e-09
Esq_L =    1.1167e-04
NFUN_L =    9.1580e+03
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok for $prog"; fail; fi

#
# this much worked
#
pass

