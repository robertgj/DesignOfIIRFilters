#!/bin/sh

prog=polyphase_allpass_socp_slb_flat_delay_test.m

depends="test/polyphase_allpass_socp_slb_flat_delay_test.m test_common.m \
../tarczynski_polyphase_allpass_test_flat_delay_Da0_coef.m \
../tarczynski_polyphase_allpass_test_flat_delay_Db0_coef.m \
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
Va1=1,Qa1=10,Ra1=2
a1 = [   0.4567240451, ...
         0.4326811653,   0.4434641748,   0.4534400361,   0.4561181547, ... 
         0.4747875334, ...
         2.2494738283,   1.7307949677,   1.1555301826,   0.5770068388, ... 
         2.7857564069 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

cat > test_b1_coef.m.ok << 'EOF'
% All-pass single-vector representation
Vb1=1,Qb1=10,Rb1=2
b1 = [  -0.8715182529, ...
         0.5218318604,   0.5242867636,   0.5309752009,   0.5479954486, ... 
         0.5900353111, ...
         0.2878406799,   0.8623187562,   1.4325385026,   1.9978225050, ... 
         2.5631138182 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1

diff -Bb test_a1_coef.m.ok polyphase_allpass_socp_slb_flat_delay_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi

diff -Bb test_b1_coef.m.ok polyphase_allpass_socp_slb_flat_delay_test_b1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_b1_coef.m"; fail; fi

#
# this much worked
#
pass

