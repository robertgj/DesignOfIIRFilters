#!/bin/sh

prog=iir_sqp_slb_bandpass_test.m

depends="test/iir_sqp_slb_bandpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_sqp_mmse.m \
iir_slb_show_constraints.m iir_slb_update_constraints.m \
iir_slb_exchange_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m \
armijo_kim.m cl2bp.m fixResultNaN.m iirA.m iirE.m iirP.m \
iirT.m invSVD.m local_max.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
sqp_bfgs.m updateWchol.m updateWbfgs.m x2tf.m xConstraints.m"

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
Ud1=2,Vd1=0,Md1=18,Qd1=10,Rd1=2
d1 = [   0.0119805617, ...
        -0.9500704127,   0.9700553801, ...
         0.9804074763,   0.9805448416,   0.9820834963,   0.9824826950, ... 
         0.9838547103,   0.9929437807,   0.9947499706,   1.3537141914, ... 
         1.4193941558, ...
         2.6756908392,   2.1928941245,   2.4486621678,   1.9388252506, ... 
         1.7375472144,   0.2813668504,   1.5933041120,   0.8426161790, ... 
         1.0914550596, ...
         0.5675249624,   0.6203412790,   0.6463481919,   0.7111225951, ... 
         0.7464109073, ...
         1.9317355259,   2.4223733286,   1.3926805875,   2.7967686161, ... 
         1.0540910895 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_sqp_slb_bandpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
