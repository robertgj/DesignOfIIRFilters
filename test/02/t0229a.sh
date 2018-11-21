#!/bin/sh

prog=deczky1_sqp_test.m

depends="deczky1_sqp_test.m \
test_common.m deczky1_slb.m deczky1_slb_constraints_are_empty.m \
deczky1_slb_exchange_constraints.m deczky1_slb_set_empty_constraints.m \
deczky1_slb_show_constraints.m deczky1_slb_update_constraints.m \
deczky1_slb_update_constraints_test.m deczky1_sqp_mmse.m \
Aerror.m Terror.m iirA.m iirE.m iirT.m iirP.m iirdelAdelw.m \
invSVD.m armijo_kim.m fixResultNaN.m sqp_bfgs.m updateWchol.m local_max.m \
updateWbfgs.m xConstraints.m x2tf.m print_polynomial.m print_pole_zero.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m"

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
cat > test.ok << 'EOF'
Ud1=2,Vd1=0,Md1=10,Qd1=6,Rd1=1
d1 = [   0.0158549175, ...
        -0.7524408723,  -0.7522264185, ...
         0.8707924349,   0.9244389481,   0.9839834529,   1.7176283718, ... 
         1.8190543824, ...
         2.4574841228,   2.0646852911,   1.9008551856,   1.0662118497, ... 
         0.3579620244, ...
         0.2826141480,   0.5965646189,   0.9346222714, ...
         0.8006442784,   1.6829878503,   1.7323761247 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok deczky1_sqp_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass
