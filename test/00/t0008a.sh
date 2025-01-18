#!/bin/sh

prog=iir_sqp_mmse_test.m

depends="test/iir_sqp_mmse_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_sqp_mmse.m iir_slb_update_constraints.m iir_slb_show_constraints.m \
armijo_kim.m cl2bp.m fixResultNaN.m \
iirA.m iirE.m iirT.m iirP.m invSVD.m local_max.m showResponseBands.m \
showResponse.m showResponsePassBands.m showZPplot.m sqp_bfgs.m \
tf2x.m zp2x.m updateWchol.m updateWbfgs.m x2tf.m xConstraints.m xInitHd.m \
iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m \
qroots.m qzsolve.oct"

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
cat > test_x1_coef.ok << 'EOF'
x1 = [   0.0051942723,   0.7830640507,   1.0307870056,   1.0080509921, ... 
        -1.2670081156,   2.2711624905,   1.0077766135,   1.0393909784, ... 
         1.0355118961,   0.0000000000,   2.1396493184,   1.6539202954, ... 
         3.1387573443,   1.4763366469,   4.4865684185,   2.5408834412, ... 
         3.6472117986,   0.9671487847,   0.6474184243,   0.9524750878, ... 
         0.6184238882,   1.0946452099,   1.5169498133,   2.7338226638, ... 
         2.1709110779 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x1_coef.ok iir_sqp_mmse_test_x1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x1_coef.ok"; fail; fi


#
# this much worked
#
pass

