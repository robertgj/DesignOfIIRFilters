#!/bin/sh

prog=decimator_R2_test.m

depends="decimator_R2_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
Aerror.m Terror.m armijo_kim.m fixResultNaN.m \
iirA.m iirE.m iirP.m iirT.m invSVD.m local_max.m iir_sqp_mmse.m \
iir_slb.m iir_slb_exchange_constraints.m iir_slb_show_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
iir_slb_update_constraints.m showResponseBands.m showResponse.m \
showResponsePassBands.m showZPplot.m sqp_bfgs.m updateWchol.m updateWbfgs.m \
xConstraints.m x2tf.m xInitHd.m"

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
cat > test_d1_coef.m << 'EOF'
Ud1=0,Vd1=0,Md1=12,Qd1=6,Rd1=2
d1 = [   0.0005962688, ...
         1.0159403214,   1.6560472686,   3.1649806940,   1.0632765486, ... 
         1.0638725380,   1.0950421573, ...
         4.6567720413,  -0.3200767700,   3.1352111681,   4.2525209019, ... 
         3.8547531387,   2.8870466990, ...
         0.3361151743,   0.4532804412,   0.5740749194, ...
         0.2819151970,   1.2162607819,   1.7951291657 ]';
EOF

if [ $? -ne 0 ]; then echo "Failed output cat test_d1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_d1_coef.m decimator_R2_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

