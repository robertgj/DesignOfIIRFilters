#!/bin/sh

prog=parallel_allpass_socp_slb_lowpass_differentiator_test.m

depends="test/parallel_allpass_socp_slb_lowpass_differentiator_test.m \
../tarczynski_parallel_allpass_lowpass_differentiator_test_Da0_coef.m \
../tarczynski_parallel_allpass_lowpass_differentiator_test_Db0_coef.m \
test_common.m parallel_allpassAsq.m parallel_allpassT.m parallel_allpassP.m \
parallel_allpass_slb.m \
parallel_allpass_slb_constraints_are_empty.m \
parallel_allpass_slb_exchange_constraints.m \
parallel_allpass_slb_set_empty_constraints.m \
parallel_allpass_slb_show_constraints.m \
parallel_allpass_slb_update_constraints.m \
parallel_allpass_socp_mmse.m allpassP.m allpassT.m tf2a.m a2tf.m \
aConstraints.m print_polynomial.m print_allpass_pole.m delayz.m \
local_max.m qroots.oct"

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
a1 = [  -0.6776866450, ...
         0.6884630309,   0.7056399926,   0.7068094778,   0.7223051527, ... 
         0.7457359568, ...
         1.9903060586,   1.4941314939,   2.6097372883,   0.9684881252, ... 
         0.4478669155 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

cat > test_b1_coef.m.ok << 'EOF'
% All-pass single-vector representation
Vb1=0,Qb1=12,Rb1=1
b1 = [   0.7132934704,   0.7158744107,   0.7165826689,   0.7235568917, ... 
         0.7570830604,   0.8057983831, ...
         1.2592490195,   2.8725249584,   0.7199155194,   1.7880783198, ... 
         0.1491269214,   2.3396062493 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1

nstr=parallel_allpass_socp_slb_lowpass_differentiator_test

diff -Bb test_a1_coef.m.ok $nstr"_a1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi

diff -Bb test_b1_coef.m.ok $nstr"_b1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_b1_coef.m"; fail; fi

#
# this much worked
#
pass

