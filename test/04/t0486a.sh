#!/bin/sh

prog=iir_sqp_slb_multiband_test.m

depends="iir_sqp_slb_multiband_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_sqp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
sqp_bfgs.m armijo_kim.m updateWbfgs.m invSVD.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m qroots.m \
phi2p.m tfp2g.m local_max.m tf2x.m zp2x.m x2tf.m xConstraints.m \
qzsolve.oct SeDuMi_1_3/"

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
cat > test_x1.ok << 'EOF'
Ux1=2,Vx1=0,Mx1=18,Qx1=20,Rx1=1
x1 = [   0.0270761141, ...
        -0.3111932442,   0.5563149057, ...
         0.8190751414,   0.9581985819,   0.9679293963,   0.9836120255, ... 
         0.9935406017,   0.9964552593,   0.9986785065,   0.9987926354, ... 
         0.9998776565, ...
         1.7260023783,   0.3240242320,   0.8143136008,   1.0624362288, ... 
         1.4412850320,   0.6536462853,   0.4588422702,   1.0927026242, ... 
         0.6347213332, ...
         0.9168136705,   0.9177526469,   0.9553168021,   0.9571119432, ... 
         0.9819956723,   0.9894632843,   0.9901038515,   0.9970509857, ... 
         0.9974565191,   0.9999000000, ...
         1.3381294390,   1.2170228730,   0.5703090760,   0.5082086229, ... 
         1.1148179859,   0.6242185009,   1.4026849360,   0.4733787531, ... 
         1.0993174320,   0.6317613984 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x1.ok iir_sqp_slb_multiband_test_x1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x1.ok"; fail; fi

#
# this much worked
#
pass

