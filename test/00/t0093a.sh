#!/bin/sh

prog=parallel_allpass_socp_slb_flat_delay_test.m

depends="parallel_allpass_socp_slb_flat_delay_test.m test_common.m \
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
a1 = [  -0.7970151530, ...
         0.4102283577,   0.7263181953,   0.8025417669,   0.8039358022, ... 
         0.8247796026, ...
         0.2115610603,   0.3356360109,   1.3719339146,   1.6774319777, ... 
         2.7431465318 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

cat > test_b1_coef.m.ok << 'EOF'
% All-pass single-vector representation
Vb1=2,Qb1=10,Rb1=1
b1 = [  -0.8080115349,   0.7202901879, ...
         0.7386131843,   0.7516528725,   0.7544669813,   0.7826614782, ... 
         0.8319912797, ...
         0.6519731139,   1.4015518321,   0.9516793175,   1.6689633383, ... 
         2.7412672076 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1

diff -Bb test_a1_coef.m.ok parallel_allpass_socp_slb_flat_delay_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi

diff -Bb test_b1_coef.m.ok parallel_allpass_socp_slb_flat_delay_test_b1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_b1_coef.m"; fail; fi

#
# this much worked
#
pass

