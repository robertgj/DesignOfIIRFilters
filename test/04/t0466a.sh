#!/bin/sh

prog=mcclellanFIRsymmetric_flat_bandpass_test.m

depends="mcclellanFIRsymmetric_flat_bandpass_test.m test_common.m \
print_polynomial.m mcclellanFIRsymmetric.m local_max.m lagrange_interp.m \
xfr2tf.m directFIRsymmetricA.m"

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
for file in $depends;do \
  cp -R src/$file $tmp; \
  if [ $? -ne 0 ]; then echo "Failed cp "$file; fail; fi \
done
cd $tmp
if [ $? -ne 0 ]; then echo "Failed cd"; fail; fi

#
# the output should look like this
#
cat > test_hM.ok << 'EOF'
hM = [     1.70555584,     3.17821682,    -5.09701343,   -19.07316638, ... 
          -4.76049523,    47.75504982,    57.98434573,   -53.19114156, ... 
        -167.68691503,   -41.82256908,   272.22952127,   296.56112747, ... 
        -214.69078694,  -642.37351794,  -167.60342750,   821.69750188, ... 
         853.07954884,  -502.92454392, -1496.85361123,  -422.07303994, ... 
        1551.08341809,  1569.37603234,  -695.67269651, -2152.30662247 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

cat > test_hA.ok << 'EOF'
hA = [  0.006662327500, -0.004055269899, -0.008683546807, -0.002873321599, ... 
        0.008005029674,  0.007713691662, -0.004255694702, -0.009847048614, ... 
       -0.001812617050,  0.004798782809,  0.001027331693,  0.000266976513, ... 
        0.008495033147,  0.004817900540, -0.018885705210, -0.025569566382, ... 
        0.013381986383,  0.051133914935,  0.017876953299, -0.058493690708, ... 
       -0.064941412550,  0.029188820612,  0.098830498685,  0.031751715332, ... 
       -0.091124032213, -0.093779841405,  0.037083123198,  0.119938222140 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hA.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok mcclellanFIRsymmetric_flat_bandpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

diff -Bb test_hA.ok mcclellanFIRsymmetric_flat_bandpass_test_hA_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hA.ok"; fail; fi

#
# this much worked
#
pass

