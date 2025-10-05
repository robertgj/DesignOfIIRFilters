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
parallel_allpass_socp_mmse.m allpassP.m allpassT.m tf2a.m a2tf.m delayz.m \
aConstraints.m print_polynomial.m print_allpass_pole.m local_max.m \
qroots.oct"

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
Va1=1,Qa1=6,Ra1=1
a1 = [  -0.1957255775, ...
         0.3660996406,   0.4382914106,   0.8563602027, ...
         0.3103249042,   1.0350792047,   2.1436977603 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

cat > test_b1_coef.m.ok << 'EOF'
% All-pass single-vector representation
Vb1=0,Qb1=8,Rb1=1
b1 = [   0.4481998350,   0.4991831071,   0.7516801902,   0.8070295102, ...
         0.3738552189,   1.1127171524,   1.7947584587,   1.9452225510 ]';
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

