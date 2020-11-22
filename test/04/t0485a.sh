#!/bin/sh

prog=iir_socp_slb_multiband_test.m

depends="iir_socp_slb_multiband_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m \
phi2p.m tfp2g.m local_max.m tf2x.m zp2x.m x2tf.m xConstraints.m qroots.m \
qzsolve.oct"

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
cat > test_N0.ok << 'EOF'
N0 = [     0.0608523342,    -0.6393664814,     3.3796643716,   -11.8301777276, ... 
          30.4881101866,   -60.8703916479,    96.2825858908,  -120.4930776413, ... 
         114.7692288791,   -70.8456781349,    -0.0000000000,    70.8456781349, ... 
        -114.7692288791,   120.4930776413,   -96.2825858908,    60.8703916479, ... 
         -30.4881101866,    11.8301777276,    -3.3796643716,     0.6393664814, ... 
          -0.0608523342 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N0.ok"; fail; fi

cat > test_D0.ok << 'EOF'
D0 = [     1.0000000000,   -11.3860922202,    66.2493079459,  -259.7310550500, ... 
         765.7256358395, -1798.2570785208,  3481.8051722963, -5681.1726362310, ... 
        7923.5634087775, -9530.9691153797,  9936.8009607961, -8994.0773768160, ... 
        7056.8165209945, -4776.3823004065,  2764.4562358455, -1349.1506480418, ... 
         543.3305188422,  -174.5186465688,    42.2284399996,    -6.9025735871, ... 
           0.5787133671 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_D0.ok"; fail; fi

cat > test_x1.ok << 'EOF'
Ux1=2,Vx1=0,Mx1=18,Qx1=20,Rx1=1
x1 = [   0.0548096340, ...
        -0.9998255551,   0.9998746732, ...
         0.9992931030,   0.9995165132,   0.9995765713,   0.9996007855, ... 
         0.9997193048,   0.9997835163,   0.9998031134,   0.9998921594, ... 
         1.0007620165, ...
         0.6358430968,   1.0680775917,   1.0922840532,   0.4605553431, ... 
         1.4802266754,   0.6473490798,   0.8290481930,   1.4249686719, ... 
         0.4419922954, ...
         0.8987391971,   0.9470306472,   0.9579908294,   0.9760327547, ... 
         0.9783069712,   0.9860579206,   0.9951413403,   0.9960146006, ... 
         0.9973218183,   0.9980163636, ...
         1.2176572519,   0.5574798956,   1.3900415879,   1.1110224648, ... 
         0.4784099218,   0.6232628828,   1.4138766159,   0.4693335885, ... 
         1.0986855897,   0.6306833797 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x1.ok"; fail; fi

cat > test_x2.ok << 'EOF'
Ux2=2,Vx2=0,Mx2=18,Qx2=20,Rx2=1
x2 = [   0.0548096340, ...
        -0.9998255551,   0.9998746732, ...
         0.9992931030,   0.9995165132,   0.9995765713,   0.9996007855, ... 
         0.9997193048,   0.9997835163,   0.9998031134,   0.9998921594, ... 
         1.0007620165, ...
         0.6358430968,   1.0680775917,   1.0922840532,   0.4605553431, ... 
         1.4802266754,   0.6473490798,   0.8290481930,   1.4249686719, ... 
         0.4419922954, ...
         0.8987391971,   0.9470306472,   0.9579908294,   0.9760327547, ... 
         0.9783069712,   0.9860579206,   0.9951413403,   0.9960146006, ... 
         0.9973218183,   0.9980163636, ...
         1.2176572519,   0.5574798956,   1.3900415879,   1.1110224648, ... 
         0.4784099218,   0.6232628828,   1.4138766159,   0.4693335885, ... 
         1.0986855897,   0.6306833797 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_N0.ok iir_socp_slb_multiband_test_N0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N0.ok"; fail; fi

diff -Bb test_D0.ok iir_socp_slb_multiband_test_D0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_D0.ok"; fail; fi

diff -Bb test_x1.ok iir_socp_slb_multiband_test_x1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x1.ok"; fail; fi

diff -Bb test_x2.ok iir_socp_slb_multiband_test_x2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x2.ok"; fail; fi

#
# this much worked
#
pass

