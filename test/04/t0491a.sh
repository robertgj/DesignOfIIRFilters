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
d1 = [   0.0132507544, ...
         0.9248609270,   0.9646116133,   0.9655144426,   0.9714435877, ... 
         0.9872582516,   1.5246726191, ...
         1.5856149100,   2.2100979062,   2.9319355309,   2.5433224842, ... 
         1.1724583669,   0.2731441873, ...
         0.4413542474,   0.5623722793,   0.6698489524, ...
         0.3523574521,   1.1369876110,   1.6695416537 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d1_coef.m "; fail; fi

cat > test_b_coef.ok << 'EOF'
b = [  -0.0122665130,  -0.0224862537,   0.0104672251,   0.1148819738, ... 
        0.2463346485,   0.3074634834,   0.2463346485,   0.1148819738, ... 
        0.0104672251,  -0.0224862537,  -0.0122665130 ];
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

