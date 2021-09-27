#!/bin/sh

prog=parallel_allpass_socp_slb_flat_delay_test.m

depends="parallel_allpass_socp_slb_flat_delay_test.m \
../tarczynski_parallel_allpass_test_Da0_coef.m \
../tarczynski_parallel_allpass_test_Db0_coef.m \
test_common.m \
parallel_allpassAsq.m parallel_allpassT.m parallel_allpassP.m \
parallel_allpass_slb.m \
parallel_allpass_slb_constraints_are_empty.m \
parallel_allpass_slb_exchange_constraints.m \
parallel_allpass_slb_set_empty_constraints.m \
parallel_allpass_slb_show_constraints.m \
parallel_allpass_slb_update_constraints.m \
parallel_allpass_socp_mmse.m allpassP.m allpassT.m tf2a.m a2tf.m \
aConstraints.m print_polynomial.m print_allpass_pole.m \
local_max.m qroots.m qzsolve.oct"

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
cat > test_a1_coef.m.ok << 'EOF'
% All-pass single-vector representation
Va1=1,Qa1=10,Ra1=1
a1 = [  -0.7957193472, ...
         0.4078942256,   0.7262799631,   0.8031937366,   0.8050641283, ... 
         0.8216052766, ...
         0.1981107157,   0.3359712172,   1.3754921893,   1.6601277186, ... 
         2.7419344168 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

cat > test_b1_coef.m.ok << 'EOF'
% All-pass single-vector representation
Vb1=2,Qb1=10,Rb1=1
b1 = [  -0.8069688267,   0.7200405036, ...
         0.7386092725,   0.7517872345,   0.7544229311,   0.7831146938, ... 
         0.8290796143, ...
         0.6522221854,   1.4100856827,   0.9520447879,   1.6472186172, ... 
         2.7399044667 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1

diff -Bb test_a1_coef.m.ok parallel_allpass_socp_slb_flat_delay_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi

diff -Bb test_b1_coef.m.ok parallel_allpass_socp_slb_flat_delay_test_b1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_b1_coef.m"; fail; fi

#
# this much worked
#
pass

