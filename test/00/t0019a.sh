#!/bin/sh

prog=iir_sqp_slb_bandpass_test.m

depends="iir_sqp_slb_bandpass_test.m \
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
d1 = [   0.0119781334, ...
        -0.9501854759,   0.9700299850, ...
         0.9804478987,   0.9805466967,   0.9820770988,   0.9824927194, ... 
         0.9838266649,   0.9929262261,   0.9947340877,   1.3537452074, ... 
         1.4193911791, ...
         2.6756962667,   2.1929278437,   2.4486798999,   1.9388563897, ... 
         1.7375703254,   0.2813703050,   1.5933065259,   0.8426117409, ... 
         1.0914178045, ...
         0.5675646316,   0.6204192829,   0.6463715109,   0.7112138524, ... 
         0.7464164827, ...
         1.9315692456,   2.4222482137,   1.3926168065,   2.7966923629, ... 
         1.0540496576 ]';
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
