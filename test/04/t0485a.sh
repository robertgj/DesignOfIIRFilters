#!/bin/sh

prog=iir_socp_slb_multiband_test.m

depends="test/iir_socp_slb_multiband_test.m \
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
cat > test_x2.ok << 'EOF'
Ux2=2,Vx2=0,Mx2=18,Qx2=20,Rx2=1
x2 = [   0.0533373660, ...
        -0.9993330198,   0.9984733659, ...
         0.9578316121,   0.9653629465,   0.9653783951,   0.9694115281, ... 
         0.9698206971,   0.9792353179,   0.9837266191,   0.9871899535, ... 
         0.9894567427, ...
         0.6593009340,   1.5377604973,   0.4116591914,   1.0514477405, ... 
         0.4506689200,   1.4452802383,   0.6504376098,   1.0904648410, ... 
         0.8388811392, ...
         0.8847520214,   0.9166058149,   0.9326170332,   0.9440161181, ... 
         0.9606551810,   0.9685412998,   0.9840651765,   0.9875508478, ... 
         0.9885862607,   0.9931265341, ...
         1.2355874160,   1.4050087150,   0.5581271747,   0.4800121409, ... 
         0.6347958307,   1.1119602794,   1.4183563328,   0.4687506737, ... 
         0.6317031581,   1.0965158241 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x2.ok"; fail; fi

cat > test_N2.ok << 'EOF'
N2 = [     0.0533373660,    -0.5387348033,     2.7365606849,    -9.2029278588, ... 
          22.7794782127,   -43.6546437952,    66.1729971692,   -79.0108066769, ... 
          70.8332406201,   -38.6061250914,    -8.0978144657,    51.3974506597, ... 
         -75.5522782207,    75.6875885962,   -58.5660840078,    36.1082059305, ... 
         -17.7128159774,     6.7506777585,    -1.8978540031,     0.3537353746, ... 
          -0.0331856508 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N2.ok"; fail; fi

cat > test_D2.ok << 'EOF'
D2 = [     1.0000000000,   -11.1101134071,    63.1540970782,  -242.0930128410, ... 
         698.3155561546, -1605.4120526788,  3044.4360296130, -4867.5169131592, ... 
        6655.0807618193, -7851.1355610396,  8031.7900229900, -7136.9636399156, ... 
        5500.4098098827, -3659.1024361842,  2082.8600616070, -1000.4620504450, ... 
         396.8637494721,  -125.6717797258,    30.0078807006,    -4.8453128754, ... 
           0.4017447099 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_D2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x2.ok iir_socp_slb_multiband_test_x2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x2.ok"; fail; fi

diff -Bb test_N2.ok iir_socp_slb_multiband_test_N2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N2.ok"; fail; fi

diff -Bb test_D2.ok iir_socp_slb_multiband_test_D2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_D2.ok"; fail; fi

#
# this much worked
#
pass

