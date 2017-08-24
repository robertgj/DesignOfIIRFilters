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
         0.8538881778,  -0.6401997564,  -0.1370335876, ...
         0.8149730199,   0.7166295952,   0.6741234071,   0.8649383136, ...
         0.2661978220,   1.0834803798,   2.1086747036,   3.1415926517 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a1_coef.m.ok"; fail; fi

cat > test_b1_coef.m.ok << 'EOF'
Ub1=0,Vb1=3,Mb1=0,Qb1=8,Rb1=2
b1 = [   1.0000000000, ...
         0.8534395575,  -0.9634529655,  -0.4119985000, ...
         0.8144844079,   0.7169803508,   0.6735117368,   0.8163587463, ...
         0.2659594728,   1.0844083498,   2.1062005861,   3.1415927336 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_b1_coef.m.ok"; fail; fi

cat > test_Da1_coef.m.ok << 'EOF'
Da1 = [   1.0000000000,   0.0000000000,   0.1002806038,   0.0000000000, ... 
         -1.3899846110,  -0.0000000000,  -0.0394715364,  -0.0000000000, ... 
          0.5197134066,   0.0000000000,  -0.0222253136,  -0.0000000000, ... 
         -0.1039754307,  -0.0000000000,   0.0354633353,   0.0000000000, ... 
          0.1492384716,   0.0000000000,  -0.0152337687,  -0.0000000000, ... 
         -0.0681594607,  -0.0000000000,  -0.0086869748 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m.ok"; fail; fi

cat > test_Db1_coef.m.ok << 'EOF'
Db1 = [   1.0000000000,   0.0000000000,   0.5999855415,   0.0000000000, ... 
         -1.4644592159,  -0.0000000000,  -0.6846065949,  -0.0000000000, ... 
          0.6409553158,   0.0000000000,   0.1791055957,   0.0000000000, ... 
         -0.1459431612,  -0.0000000000,  -0.0037559640,  -0.0000000000, ... 
          0.1743855715,   0.0000000000,   0.0515728512,   0.0000000000, ... 
         -0.0902872134,  -0.0000000000,  -0.0349245980 ]';
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

