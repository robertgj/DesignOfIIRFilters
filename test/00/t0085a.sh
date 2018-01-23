#!/bin/sh

prog=polyphase_allpass_socp_slb_test.m

depends="polyphase_allpass_socp_slb_test.m test_common.m \
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
Ua1=0,Va1=3,Ma1=0,Qa1=8,Ra1=2
a1 = [   1.0000000000, ...
         0.7605838790,  -0.8944448277,  -0.2207996981, ...
         0.6579360069,   0.6475269651,   0.3935521971,   0.6303776931, ...
         1.0847332105,   0.0826717242,   1.7918482207,   3.1415961415 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

cat > test_b1_coef.m.ok << 'EOF'
Ub1=0,Vb1=3,Mb1=0,Qb1=8,Rb1=2
b1 = [   1.0000000000, ...
         0.7579375945,  -0.9667432767,  -0.7992315137, ...
         0.6584263959,   0.6453220737,   0.4043529698,   0.5420114632, ...
         1.0862284061,   0.0647744091,   1.8101405493,   3.1405818765 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m.ok"; fail; fi

cat > test_Da1_coef.m.ok << 'EOF'
Da1 = [   1.0000000000,   0.0000000000,  -0.1173452052,  -0.0000000000, ... 
         -1.1337610482,  -0.0000000000,   0.3842210444,   0.0000000000, ... 
          0.2334961099,   0.0000000000,  -0.2826363302,  -0.0000000000, ... 
          0.0625194594,   0.0000000000,   0.0647032927,   0.0000000000, ... 
          0.0014105665,   0.0000000000,   0.0016532705,   0.0000000000, ... 
         -0.0069149807,  -0.0000000000,  -0.0016779868 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m.ok"; fail; fi

cat > test_Db1_coef.m.ok << 'EOF'
Db1 = [   1.0000000000,   0.0000000000,   0.3824140658,   0.0000000000, ... 
         -1.3170186346,  -0.0000000000,  -0.1057171834,  -0.0000000000, ... 
          0.5210095488,   0.0000000000,  -0.2528840800,  -0.0000000000, ... 
         -0.0632846069,  -0.0000000000,   0.1182274028,   0.0000000000, ... 
          0.0180691572,   0.0000000000,   0.0018603564,   0.0000000000, ... 
         -0.0067088174,  -0.0000000000,  -0.0050783536 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db1_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out

diff -Bb test_a1_coef.m.ok polyphase_allpass_socp_slb_test_a1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_a1_coef.m"; fail; fi

diff -Bb test_b1_coef.m.ok polyphase_allpass_socp_slb_test_b1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_b1_coef.m"; fail; fi

diff -Bb test_Da1_coef.m.ok polyphase_allpass_socp_slb_test_Da1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_Da1_coef.m"; fail; fi

diff -Bb test_Db1_coef.m.ok polyphase_allpass_socp_slb_test_Db1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test_Db1_coef.m"; fail; fi

#
# this much worked
#
pass

