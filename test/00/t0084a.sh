#!/bin/sh

prog=parallel_allpass_socp_slb_test.m

depends="parallel_allpass_socp_slb_test.m test_common.m \
parallel_allpassAsq.m parallel_allpassT.m parallel_allpass_slb.m \
parallel_allpass_slb_constraints_are_empty.m \
parallel_allpass_slb_exchange_constraints.m \
parallel_allpass_slb_set_empty_constraints.m \
parallel_allpass_slb_show_constraints.m \
parallel_allpass_slb_update_constraints.m \
parallel_allpass_socp_mmse.m allpassP.m allpassT.m tf2a.m a2tf.m \
aConstraints.m print_polynomial.m local_max.m SeDuMi_1_3/"

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
cat > test_Da1_coef.m.ok << 'EOF'
Da1 = [   1.0000000000,  -2.8330463002,   4.0371210157,  -3.2282596781, ... 
          1.4628447196,  -0.2936225622 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m.ok"; fail; fi
cat > test_Db1_coef.m.ok << 'EOF'
Db1 = [   1.0000000000,  -3.4038084317,   5.9908536454,  -6.2950667259, ... 
          4.1745726517,  -1.6254957473,   0.2961665555 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
diff -Bb test_Da1_coef.m.ok parallel_allpass_socp_slb_test_Da1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_Da1_coef.m"; fail; fi
diff -Bb test_Db1_coef.m.ok parallel_allpass_socp_slb_test_Db1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_Db1_coef.m"; fail; fi

#
# this much worked
#
pass

