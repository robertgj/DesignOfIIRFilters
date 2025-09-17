#!/bin/sh

prog=parallel_allpass_socp_slb_bandpass_differentiator_test.m

depends="test/parallel_allpass_socp_slb_bandpass_differentiator_test.m \
../tarczynski_parallel_allpass_bandpass_differentiator_test_Da0_coef.m \
../tarczynski_parallel_allpass_bandpass_differentiator_test_Db0_coef.m \
test_common.m parallel_allpassAsq.m parallel_allpassT.m parallel_allpassP.m \
parallel_allpass_slb.m \
parallel_allpass_slb_constraints_are_empty.m \
parallel_allpass_slb_exchange_constraints.m \
parallel_allpass_slb_set_empty_constraints.m \
parallel_allpass_slb_show_constraints.m \
parallel_allpass_slb_update_constraints.m \
parallel_allpass_socp_mmse.m allpassP.m allpassT.m tf2a.m a2tf.m \
aConstraints.m print_polynomial.m print_allpass_pole.m delayz.m local_max.m \
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
Va1=1,Qa1=14,Ra1=1
a1 = [  -0.2214165258, ...
         0.6947326792,   0.6990690145,   0.7031171514,   0.7345247555, ... 
         0.8209966334,   0.8640035637,   0.9858609789, ...
         1.1510699362,   0.7864326883,   2.6280625464,   3.0589705803, ... 
         0.3778025991,   1.5479624408,   1.5529521146 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

cat > test_b1_coef.m.ok << 'EOF'
% All-pass single-vector representation
Vb1=1,Qb1=14,Rb1=1
b1 = [   0.0837329516, ...
         0.7008300658,   0.7111089742,   0.7364432200,   0.7817497844, ... 
         0.7833765197,   0.8476423341,   0.9701274265, ...
         1.1255941524,   0.7788382672,   2.6026932430,   1.5183174210, ... 
         3.0123100415,   0.3947054461,   1.5512563662 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1

nstr=parallel_allpass_socp_slb_bandpass_differentiator_test

diff -Bb test_a1_coef.m.ok $nstr"_a1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi

diff -Bb test_b1_coef.m.ok $nstr"_b1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_b1_coef.m"; fail; fi

#
# this much worked
#
pass

