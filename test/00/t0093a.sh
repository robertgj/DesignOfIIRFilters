#!/bin/sh

prog=parallel_allpass_socp_slb_flat_delay_test.m

depends="parallel_allpass_socp_slb_flat_delay_test.m test_common.m \
parallel_allpassAsq.m parallel_allpassT.m parallel_allpassP.m \
parallel_allpass_slb.m \
parallel_allpass_slb_constraints_are_empty.m \
parallel_allpass_slb_exchange_constraints.m \
parallel_allpass_slb_set_empty_constraints.m \
parallel_allpass_slb_show_constraints.m \
parallel_allpass_slb_update_constraints.m \
parallel_allpass_socp_mmse.m allpassP.m allpassT.m tf2a.m a2tf.m \
aConstraints.m print_polynomial.m print_pole_zero.m local_max.m SeDuMi_1_3/"

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
Ua1=0,Va1=1,Ma1=0,Qa1=10,Ra1=1
a1 = [   1.0000000000, ...
        -0.8034953663, ...
         0.8375718782,   0.7932058803,   0.8003594773,   0.7265233208, ... 
         0.4225281966, ...
         2.7458872457,   1.7760525655,   1.3582602681,   0.3333701243, ... 
         0.2804140565 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

cat > test_b1_coef.m.ok << 'EOF'
Ub1=0,Vb1=2,Mb1=0,Qb1=10,Rb1=1
b1 = [   1.0000000000, ...
        -0.8131699304,   0.7219257581, ...
         0.8437022593,   0.7770559294,   0.7517617981,   0.7384062315, ... 
         0.7545881474, ...
         2.7448248563,   1.7824204559,   1.3704225266,   0.6505903441, ... 
         0.9500918088 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m.ok"; fail; fi

cat > test_Da1_coef.m.ok << 'EOF'
Da1 = [   1.0000000000,   0.1497782461,  -0.2101546884,   0.1266156978, ... 
         -0.3652944550,  -0.0903721480,   0.2042811581,  -0.0511871799, ... 
          0.1016545070,   0.0379383368,  -0.0795339244,   0.0214081972 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m.ok"; fail; fi

cat > test_Db1_coef.m.ok << 'EOF'
Db1 = [   1.0000000000,  -0.3781424605,   0.0909084831,   0.5350105249, ... 
         -0.3553005627,   0.1708777172,   0.1514393203,  -0.2521353248, ... 
          0.1527159259,  -0.0301277077,  -0.0835476970,   0.0732588506, ... 
         -0.0442718836 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out

diff -Bb test_a1_coef.m.ok parallel_allpass_socp_slb_flat_delay_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi

diff -Bb test_b1_coef.m.ok parallel_allpass_socp_slb_flat_delay_test_b1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_b1_coef.m"; fail; fi

diff -Bb test_Da1_coef.m.ok parallel_allpass_socp_slb_flat_delay_test_Da1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_Da1_coef.m"; fail; fi

diff -Bb test_Db1_coef.m.ok parallel_allpass_socp_slb_flat_delay_test_Db1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_Db1_coef.m"; fail; fi

#
# this much worked
#
pass

