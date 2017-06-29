#!/bin/sh

prog=polyphase_allpass_socp_slb_flat_delay_test.m

depends="polyphase_allpass_socp_slb_flat_delay_test.m test_common.m \
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
Da1 = [   1.0000000000,   0.0000000000,  -0.0124595911,  -0.0000000000, ... 
          0.0058711516,   0.0000000000,  -0.0035359582,  -0.0000000000, ... 
          0.0023544691,   0.0000000000,  -0.0016881797,  -0.0000000000, ... 
          0.0012551890,   0.0000000000,  -0.0009219425,  -0.0000000000, ... 
          0.0005568385,   0.0000000000,  -0.0002856279,  -0.0000000000, ... 
          0.0000004558,   0.0000000000,  -0.0001635960 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m.ok"; fail; fi
cat > test_Db1_coef.m.ok << 'EOF'
Db1 = [   1.0000000000,   0.0000000000,   0.4841852737,   0.0000000000, ... 
         -0.1203448092,  -0.0000000000,   0.0572996623,   0.0000000000, ... 
         -0.0330158562,  -0.0000000000,   0.0206100182,   0.0000000000, ... 
         -0.0133245377,  -0.0000000000,   0.0087223870,   0.0000000000, ... 
         -0.0057815254,  -0.0000000000,   0.0037161533,   0.0000000000, ... 
         -0.0022954704,  -0.0000000000,   0.0019208385 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
diff -Bb test_Da1_coef.m.ok polyphase_allpass_socp_slb_flat_delay_test_Da1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_Da1_coef.m"; fail; fi
diff -Bb test_Db1_coef.m.ok polyphase_allpass_socp_slb_flat_delay_test_Db1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_Db1_coef.m"; fail; fi

#
# this much worked
#
pass

