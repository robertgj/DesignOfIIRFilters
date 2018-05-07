#!/bin/sh

prog=polyphase_allpass_socp_slb_flat_delay_test.m

depends="polyphase_allpass_socp_slb_flat_delay_test.m test_common.m \
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
Ua1=0,Va1=1,Ma1=0,Qa1=10,Ra1=2
a1 = [   1.0000000000, ...
         0.4604654729, ...
         0.4748791938,   0.4321665676,   0.4417527290,   0.4582484966, ... 
         0.4527882642, ...
         2.7853746568,   2.2479166026,   1.7321501491,   0.5829265024, ... 
         1.1613004079 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

cat > test_b1_coef.m.ok << 'EOF'
Ub1=0,Vb1=1,Mb1=0,Qb1=10,Rb1=2
b1 = [   1.0000000000, ...
        -0.8714973320, ...
         0.5900319276,   0.5482209524,   0.5314597200,   0.5207059843, ... 
         0.5241830976, ...
         2.5631673158,   1.9980441666,   1.4318119438,   0.2866893177, ... 
         0.8604234502 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m.ok"; fail; fi

cat > test_Da1_coef.m.ok << 'EOF'
Da1 = [   1.0000000000,   0.0000000000,  -0.0125373230,  -0.0000000000, ... 
          0.0058953883,   0.0000000000,  -0.0035502154,  -0.0000000000, ... 
          0.0023595058,   0.0000000000,  -0.0016926225,  -0.0000000000, ... 
          0.0012619472,   0.0000000000,  -0.0009258388,  -0.0000000000, ... 
          0.0005579063,   0.0000000000,  -0.0002853715,  -0.0000000000, ... 
         -0.0000000157,  -0.0000000000,  -0.0001629358 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m.ok"; fail; fi

cat > test_Db1_coef.m.ok << 'EOF'
Db1 = [   1.0000000000,   0.0000000000,   0.4841057725,   0.0000000000, ... 
         -0.1203567388,  -0.0000000000,   0.0573037848,   0.0000000000, ... 
         -0.0330219192,  -0.0000000000,   0.0206103408,   0.0000000000, ... 
         -0.0133204241,  -0.0000000000,   0.0087214164,   0.0000000000, ... 
         -0.0057822259,  -0.0000000000,   0.0037162334,   0.0000000000, ... 
         -0.0022953675,  -0.0000000000,   0.0019187581 ]';
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

