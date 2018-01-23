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
         0.4600321735, ...
         0.4743036590,   0.4319841531,   0.4423946933,   0.4580834204, ... 
         0.4532523295, ...
         2.7859318175,   2.2497000570,   1.7330244846,   0.5819507470, ... 
         1.1604656552 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

cat > test_b1_coef.m.ok << 'EOF'
Ub1=0,Vb1=1,Mb1=0,Qb1=10,Rb1=2
b1 = [   1.0000000000, ...
        -0.8715678319, ...
         0.5900831984,   0.5482249993,   0.5313390411,   0.5208871291, ... 
         0.5241810015, ...
         2.5632082071,   1.9979625061,   1.4318792830,   0.2868855261, ... 
         0.8607782190 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m.ok"; fail; fi

cat > test_Da1_coef.m.ok << 'EOF'
Da1 = [   1.0000000000,   0.0000000000,  -0.0123370773,  -0.0000000000, ... 
          0.0058070467,   0.0000000000,  -0.0035035099,  -0.0000000000, ... 
          0.0023307277,   0.0000000000,  -0.0016696782,  -0.0000000000, ... 
          0.0012446515,   0.0000000000,  -0.0009198018,  -0.0000000000, ... 
          0.0005579213,   0.0000000000,  -0.0002734695,  -0.0000000000, ... 
         -0.0000014544,  -0.0000000000,  -0.0001629393 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m.ok"; fail; fi

cat > test_Db1_coef.m.ok << 'EOF'
Db1 = [   1.0000000000,   0.0000000000,   0.4843097455,   0.0000000000, ... 
         -0.1203510951,  -0.0000000000,   0.0572889206,   0.0000000000, ... 
         -0.0330127249,  -0.0000000000,   0.0206093040,   0.0000000000, ... 
         -0.0133204928,  -0.0000000000,   0.0087157326,   0.0000000000, ... 
         -0.0057772752,  -0.0000000000,   0.0037279652,   0.0000000000, ... 
         -0.0022924957,  -0.0000000000,   0.0019197232 ]';
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

