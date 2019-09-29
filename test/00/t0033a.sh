#!/bin/sh

prog=parallel_allpass_socp_mmse_test.m

depends="parallel_allpass_socp_mmse_test.m test_common.m \
parallel_allpass_socp_mmse.m parallel_allpass_mmse_error.m \
parallel_allpass_delay_slb_set_empty_constraints.m \
allpassP.m allpassT.m parallel_allpassAsq.m \
parallel_allpassT.m parallel_allpassP.m a2tf.m tf2a.m \
print_polynomial.m print_allpass_pole.m aConstraints.m \
qroots.m qzsolve.oct SeDuMi_1_3/"

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
cat > test_a1_coef.m << 'EOF'
% All-pass single-vector representation
Va1=1,Qa1=10,Ra1=1
a1 = [  -0.8725346286, ...
         0.5054873493,   0.6898092692,   0.7484363369,   0.9175385670, ... 
         0.9370759613, ...
         0.4079147751,   0.3169851638,   1.2933025702,   1.9987960303, ... 
         2.7577077724 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m"; fail; fi

cat > test_b1_coef.m << 'EOF'
% All-pass single-vector representation
Vb1=2,Qb1=10,Rb1=1
b1 = [  -0.8734715744,   0.6936496296, ...
         0.7013081978,   0.7096002960,   0.7192014918,   0.9162731465, ... 
         0.9374486726, ...
         0.6315610615,   1.2101188949,   0.9165394629,   1.9988786174, ... 
         2.7579923587 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a1_coef.m parallel_allpass_socp_mmse_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a1_coef.m"; fail; fi

diff -Bb test_b1_coef.m parallel_allpass_socp_mmse_test_b1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_b1_coef.m"; fail; fi

#
# this much worked
#
pass

