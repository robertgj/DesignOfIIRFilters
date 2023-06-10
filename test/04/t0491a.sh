#!/bin/sh

prog=decimator_R2_interpolated_test.m

depends="test/decimator_R2_interpolated_test.m test_common.m delayz.m \
print_polynomial.m print_pole_zero.m armijo_kim.m fixResultNaN.m \
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
cat > test_d1_coef.ok << 'EOF'
Ud1=0,Vd1=0,Md1=12,Qd1=6,Rd1=2
d1 = [   0.0127982332, ...
         0.9408972503,   0.9760751074,   0.9797669670,   0.9800475084, ... 
         0.9897057372,   1.5100713988, ...
         1.5971047670,   2.9344277382,   2.5501369913,   2.2232754462, ... 
         1.1715733537,   0.2814683748, ...
         0.4949040752,   0.5993584283,   0.7055873425, ...
         0.3808663772,   1.1669938404,   1.7213905906 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d1_coef.m "; fail; fi

cat > test_b_coef.ok << 'EOF'
b = [  -0.0123510030,  -0.0226223862,   0.0106253797,   0.1158827378, ... 
        0.2483715491,   0.3099785029,   0.2483715491,   0.1158827378, ... 
        0.0106253797,  -0.0226223862,  -0.0123510030 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_d1_coef.ok decimator_R2_interpolated_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d1_coef.m"; fail; fi

diff -Bb test_b_coef.ok decimator_R2_interpolated_test_b_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_b_coef.m"; fail; fi

#
# this much worked
#
pass

