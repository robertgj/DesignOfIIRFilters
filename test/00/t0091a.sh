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
Ua1=0,Va1=1,Ma1=0,Qa1=10,Ra1=2
a1 = [   1.0000000000, ...
         0.4600353415, ...
         0.4743865965,   0.4319648069,   0.4424877187,   0.4581009399, ... 
         0.4532797238, ...
         2.7857460215,   2.2497173188,   1.7329785960,   0.5818992061, ... 
         1.1603745559 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

cat > test_b1_coef.m.ok << 'EOF'
Ub1=0,Vb1=1,Mb1=0,Qb1=10,Rb1=2
b1 = [   1.0000000000, ...
        -0.8715396457, ...
         0.5900608304,   0.5481732286,   0.5312886085,   0.5208507971, ... 
         0.5241391118, ...
         2.5631630892,   1.9978839839,   1.4318736201,   0.2868904816, ... 
         0.8607732996 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m.ok"; fail; fi

cat > test_Da1_coef.m.ok << 'EOF'
Da1 = [   1.0000000000,   0.0000000000,  -0.0124216775,  -0.0000000000, ... 
          0.0058388818,   0.0000000000,  -0.0035162988,  -0.0000000000, ... 
          0.0023367803,   0.0000000000,  -0.0016762094,  -0.0000000000, ... 
          0.0012527082,   0.0000000000,  -0.0009242993,  -0.0000000000, ... 
          0.0005594282,   0.0000000000,  -0.0002735410,  -0.0000000000, ... 
         -0.0000012337,  -0.0000000000,  -0.0001630835 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m.ok"; fail; fi

cat > test_Db1_coef.m.ok << 'EOF'
Db1 = [   1.0000000000,   0.0000000000,   0.4842236048,   0.0000000000, ... 
         -0.1203589854,  -0.0000000000,   0.0572994032,   0.0000000000, ... 
         -0.0330185866,  -0.0000000000,   0.0206087668,   0.0000000000, ... 
         -0.0133168628,  -0.0000000000,   0.0087155561,   0.0000000000, ... 
         -0.0057783881,  -0.0000000000,   0.0037286738,   0.0000000000, ... 
         -0.0022918296,  -0.0000000000,   0.0019182145 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out

diff -Bb test_a1_coef.m.ok polyphase_allpass_socp_slb_flat_delay_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi

diff -Bb test_b1_coef.m.ok polyphase_allpass_socp_slb_flat_delay_test_b1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_b1_coef.m"; fail; fi

diff -Bb test_Da1_coef.m.ok polyphase_allpass_socp_slb_flat_delay_test_Da1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_Da1_coef.m"; fail; fi

diff -Bb test_Db1_coef.m.ok polyphase_allpass_socp_slb_flat_delay_test_Db1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_Db1_coef.m"; fail; fi

#
# this much worked
#
pass

