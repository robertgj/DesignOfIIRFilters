#!/bin/sh

prog=parallel_allpass_socp_slb_bandpass_test.m

depends="test/parallel_allpass_socp_slb_bandpass_test.m \
../tarczynski_parallel_allpass_bandpass_test_Da0_coef.m \
../tarczynski_parallel_allpass_bandpass_test_Db0_coef.m \
test_common.m delayz.m \
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
Va1=0,Qa1=10,Ra1=1
a1 = [   0.1346311181,   0.7781980689,   0.7858582525,   0.8017668940, ... 
         0.8133175559, ...
         3.1415665646,   0.3795750586,   1.0279472755,   1.2262964810, ... 
         1.4601711342 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

cat > test_b1_coef.m.ok << 'EOF'
% All-pass single-vector representation
Vb1=0,Qb1=10,Rb1=1
b1 = [   0.2128488043,   0.7561914061,   0.7622725166,   0.7898385786, ... 
         0.8157167637, ...
         2.3857960009,   0.6907691908,   0.8374118873,   0.5001650181, ... 
         1.5175332432 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1

diff -Bb test_a1_coef.m.ok parallel_allpass_socp_slb_bandpass_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi

diff -Bb test_b1_coef.m.ok parallel_allpass_socp_slb_bandpass_test_b1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_b1_coef.m"; fail; fi

#
# this much worked
#
pass

