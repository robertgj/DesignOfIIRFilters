#!/bin/sh

prog=parallel_allpass_socp_slb_bandpass_hilbert_R2_test.m

depends="test/parallel_allpass_socp_slb_bandpass_hilbert_R2_test.m \
../tarczynski_parallel_allpass_bandpass_hilbert_R2_test_Da0_coef.m \
../tarczynski_parallel_allpass_bandpass_hilbert_R2_test_Db0_coef.m \
../tarczynski_parallel_allpass_bandpass_hilbert_R2_test_Naa_coef.m \
../tarczynski_parallel_allpass_bandpass_hilbert_R2_test_Daa_coef.m \
test_common.m \
parallel_allpassAsq.m \
parallel_allpassT.m \
parallel_allpassP.m \
parallel_allpass_slb.m \
parallel_allpass_slb_constraints_are_empty.m \
parallel_allpass_slb_exchange_constraints.m \
parallel_allpass_slb_set_empty_constraints.m \
parallel_allpass_slb_show_constraints.m \
parallel_allpass_slb_update_constraints.m \
parallel_allpass_socp_mmse.m \
delayz.m allpassP.m allpassT.m tf2a.m a2tf.m tf2pa.m aConstraints.m \
print_polynomial.m print_allpass_pole.m local_max.m \
qroots.oct spectralfactor.oct"

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
Va1=0,Qa1=4,Ra1=2
a1 = [   0.5425945343,   0.6465678934, ...
         2.3267859725,   1.5395605602 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

cat > test_b1_coef.m.ok << 'EOF'
% All-pass single-vector representation
Vb1=0,Qb1=6,Rb1=2
b1 = [   0.5790878411,   0.7781283376,   0.8654912964, ...
         1.9365265850,   3.0937864560,   1.1613836600 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1

nstr=parallel_allpass_socp_slb_bandpass_hilbert_R2_test

diff -Bb test_a1_coef.m.ok $nstr"_a1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi

diff -Bb test_b1_coef.m.ok $nstr"_b1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_b1_coef.m"; fail; fi

#
# this much worked
#
pass

