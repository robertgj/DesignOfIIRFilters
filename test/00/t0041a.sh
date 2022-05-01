#!/bin/sh

prog=polyphase_allpass_socp_mmse_test.m
depends="polyphase_allpass_socp_mmse_test.m test_common.m \
parallel_allpass_socp_mmse.m parallel_allpass_mmse_error.m \
parallel_allpass_delay_slb_set_empty_constraints.m \
parallel_allpassAsq.m parallel_allpassT.m parallel_allpassP.m \
allpassT.m allpassP.m aConstraints.m \
print_polynomial.m print_pole_zero.m a2tf.m tf2a.m \
qroots.m qzsolve.oct"

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
cat > test_Da1_coef.m << 'EOF'
Da1 = [   1.0000000000,   0.0000000000,  -0.0000711042,  -0.0000000000, ... 
          0.0001053095,   0.0000000000,  -0.0002405346,  -0.0000000000, ... 
          0.0006536382,   0.0000000000,  -0.0004217230,  -0.0000000000, ... 
          0.0002447810,   0.0000000000,  -0.0001399720,  -0.0000000000, ... 
          0.0001071378,   0.0000000000,  -0.0000823009,  -0.0000000000, ... 
          0.0000793956,   0.0000000000,  -0.0001501091 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da1_coef.m"; fail; fi
cat > test_Db1_coef.m << 'EOF'
Db1 = [   1.0000000000,   0.0000000000,   0.4967404969,   0.0000000000, ... 
         -0.1200232380,  -0.0000000000,   0.0565082002,   0.0000000000, ... 
         -0.0326313314,  -0.0000000000,   0.0199320894,   0.0000000000, ... 
         -0.0126768304,  -0.0000000000,   0.0081504379,   0.0000000000, ... 
         -0.0052258307,  -0.0000000000,   0.0032642012,   0.0000000000, ... 
         -0.0019754090,  -0.0000000000,   0.0012586005 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_Da1_coef.m polyphase_allpass_socp_mmse_test_Da1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da1_coef.m"; fail; fi
diff -Bb test_Db1_coef.m polyphase_allpass_socp_mmse_test_Db1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Db1_coef.m"; fail; fi

#
# this much worked
#
pass

