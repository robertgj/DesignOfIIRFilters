#!/bin/sh

prog=iir_sqp_slb_fir_bandpass_test.m

depends="iir_sqp_slb_fir_bandpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iirA.m iirE.m iirT.m iirP.m local_max.m iir_sqp_mmse.m iir_slb.m \
armijo_kim.m fixResultNaN.m goldensection.m quadratic.m \
sqp_bfgs.m updateWchol.m updateWbfgs.m invSVD.m xConstraints.m \
iir_slb_exchange_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m showResponseBands.m tf2x.m zp2x.m x2tf.m \
showResponse.m showResponsePassBands.m showZPplot.m qroots.m qzsolve.oct"

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
cat > test.ok << 'EOF'
Ud1=2,Vd1=0,Md1=28,Qd1=0,Rd1=1
d1 = [   0.0287196418, ...
        -0.9687500000,   0.9687500000, ...
         0.8612499796,   0.8651494929,   0.9687500000,   0.9687500000, ... 
         0.9687500000,   0.9687500000,   0.9687500000,   0.9687500000, ... 
         0.9687500000,   0.9687500000,   0.9687500000,   0.9687500000, ... 
         0.9687500000,   0.9687500000, ...
         1.0813685813,   0.8282557029,   2.5618557866,   1.6561413397, ... 
         1.8098006229,   2.3669504118,   2.7492769727,   1.9843015816, ... 
         2.9442300896,   0.0001786075,   0.0003344440,   1.5840783704, ... 
         2.1708426446,   0.2894420633 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_sqp_slb_fir_bandpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

