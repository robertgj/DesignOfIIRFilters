#!/bin/sh

prog=polyphase_allpass_socp_slb_flat_delay_test.m

depends="polyphase_allpass_socp_slb_flat_delay_test.m test_common.m \
parallel_allpassAsq.m parallel_allpassT.m parallel_allpassP.m \
parallel_allpass_slb.m \
parallel_allpass_slb_constraints_are_empty.m \
parallel_allpass_slb_exchange_constraints.m \
parallel_allpass_slb_set_empty_constraints.m \
parallel_allpass_slb_show_constraints.m \
parallel_allpass_slb_update_constraints.m \
parallel_allpass_socp_mmse.m allpassP.m allpassT.m tf2a.m a2tf.m \
aConstraints.m print_polynomial.m print_allpass_pole.m \
local_max.m qroots.m qzsolve.oct SeDuMi_1_3/"

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
cat > test_a1_coef.m.ok << 'EOF'
% All-pass single-vector representation
Va1=1,Qa1=10,Ra1=2
a1 = [   0.4279252223, ...
         0.2294166642,   0.4198673199,   0.4261598363,   0.4278185239, ... 
         0.4581543454, ...
         2.1425010399,   1.9372771548,   1.2450358286,   0.6126571496, ... 
         2.7070543106 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

cat > test_b1_coef.m.ok << 'EOF'
% All-pass single-vector representation
Vb1=1,Qb1=10,Rb1=2
b1 = [  -0.8685981885, ...
         0.5152568765,   0.5181208063,   0.5276418938,   0.5465350513, ... 
         0.5878600706, ...
         0.2862845424,   0.8563643864,   1.4231801692,   1.9924741306, ... 
         2.5605779952 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out

diff -Bb test_a1_coef.m.ok polyphase_allpass_socp_slb_flat_delay_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi

diff -Bb test_b1_coef.m.ok polyphase_allpass_socp_slb_flat_delay_test_b1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_b1_coef.m"; fail; fi

#
# this much worked
#
pass

