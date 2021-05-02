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
d1 = [   0.0292195665, ...
         0.9687500000,   0.9687500000, ...
         0.1217059870,   0.8488046369,   0.8501522754,   0.9687500000, ... 
         0.9687500000,   0.9687500000,   0.9687500000,   0.9687500000, ... 
         0.9687500000,   0.9687500000,   0.9687500000,   0.9687500000, ... 
         0.9687500000,   0.9687500000, ...
         3.1378251544,   0.8046399564,   1.0578648938,   0.2977785926, ... 
         0.2323299356,   1.6669856284,   1.8625828746,   1.5871342287, ... 
         2.0500989035,   2.2452930025,   2.8392130199,   2.4397721098, ... 
         2.6397519568,   3.0396456409 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_sqp_slb_fir_bandpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

