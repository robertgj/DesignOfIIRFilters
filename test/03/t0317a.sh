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
        echo FAILED ${0#$here"/"} $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED ${0#$here"/"} $prog
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
npoints =  10000
nchk=[nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu];
nchk=[ 1001 1002 2000 2001 4001 4002 5000 5001 ];
wa(nchk)*0.5/pi=[  0.05 0.05005 0.09995    0.1    0.2    0.2 0.2499   0.25 ];
Ad(nchk)=[      0      0      0      1      1      0      0      0 ];
Wa(nchk)=[     30      0      0      1      1      0      0     30 ];
tol =  0.000000010000
EsqPW =  0.00051993
Esq =  0.00052043
Esq_A =  0.00052043
Esq_Q =  0.00051993
IER_Q = 0
NFUN_Q =  1575
ERR_Q =  0.0000000012347
Esq_V =  0.00051996
NFUN_V =  421
Esq_CC =  0.00012683
ERR_CC =  0.000083049
NR_CC =  27089
Esq_GK =  0.000048235
ERR_GK =  0.0000000062573
Esq_L =  0.00011167
NFUN_L =  9158
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

