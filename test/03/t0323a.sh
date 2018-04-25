#!/bin/sh

prog=parallel_allpass_socp_slb_bandpass_test.m

depends="parallel_allpass_socp_slb_bandpass_test.m test_common.m \
parallel_allpassAsq.m parallel_allpassT.m parallel_allpassP.m \
parallel_allpass_slb.m \
parallel_allpass_slb_constraints_are_empty.m \
parallel_allpass_slb_exchange_constraints.m \
parallel_allpass_slb_set_empty_constraints.m \
parallel_allpass_slb_show_constraints.m \
parallel_allpass_slb_update_constraints.m \
parallel_allpass_socp_mmse.m allpassP.m allpassT.m tf2a.m a2tf.m \
aConstraints.m print_polynomial.m print_pole_zero.m local_max.m \
SeDuMi_1_3/"

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
Ua1=0,Va1=0,Ma1=0,Qa1=12,Ra1=1
a1 = [   1.0000000000, ...
         0.6913247065,   0.6293100614,   0.7653755641,   0.8342431769, ... 
         0.7993342245,   0.8163054308, ...
         2.9713289817,   2.3438448109,   0.4187053649,   1.4727564348, ... 
         1.0176889304,   1.2217225519 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi
cat > test_b1_coef.m.ok << 'EOF'
Ub1=0,Vb1=0,Mb1=0,Qb1=12,Rb1=1
b1 = [   1.0000000000, ...
         0.6898310222,   0.6274097002,   0.8339152305,   0.8162064241, ... 
         0.6982590488,   0.7818405854, ...
         2.9707890451,   2.3357367923,   1.5118517886,   0.5435734363, ... 
         0.8071796149,   0.7797773388 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
diff -Bb test_a1_coef.m.ok parallel_allpass_socp_slb_bandpass_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi
diff -Bb test_b1_coef.m.ok parallel_allpass_socp_slb_bandpass_test_b1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_b1_coef.m"; fail; fi

#
# this much worked
#
pass

