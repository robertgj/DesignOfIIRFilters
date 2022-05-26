#!/bin/sh

prog=decimator_R2_profile_test.m

depends="test/decimator_R2_profile_test.m iir_slb.m iir_sqp_mmse.m \
iir_slb_show_constraints.m iir_slb_update_constraints.m \
iir_slb_exchange_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m armijo_kim.m cl2bp.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m invSVD.m local_max.m \
sqp_bfgs.m updateWchol.m updateWbfgs.m xConstraints.m print_pole_zero.m"

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
Ud1=0,Vd1=0,Md1=12,Qd1=6,Rd1=2
d1 = [   0.0001150457, ...
         0.9962550830,   0.9968233665,   0.9980267573,   0.9985879731, ... 
         1.6380418960,  10.0000000000, ...
         1.6760825033,   2.1131289592,   2.4772038147,   2.9061427648, ... 
         0.3123888981,   3.1415921961, ...
         0.3416111074,   0.4730200260,   0.5903943085, ...
         0.3256957817,   1.2570141409,   1.8588415645 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok decimator_R2_profile_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
