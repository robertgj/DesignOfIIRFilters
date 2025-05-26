#!/bin/sh

prog=tarczynski_polyphase_allpass_test.m
depends="test/tarczynski_polyphase_allpass_test.m \
test_common.m delayz.m print_polynomial.m print_pole_zero.m WISEJ_PA.m"
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
cat > test_Da0_coef.m << 'EOF'
Da0 = [   1.0000000000,  -0.6077580421,  -1.1973464343,   0.3635696539, ... 
          0.7649640589,   0.2473018937,  -0.6354721242,  -0.4095405268, ... 
          0.5359879368,   0.1737793877,  -0.1711238654,  -0.0221255924 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da0_coef.m"; fail; fi

cat > test_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,  -0.1085644824,  -1.6245094034,  -0.0980443898, ... 
          1.0202437767,   0.5596637148,  -0.5737364624,  -0.7303044797, ... 
          0.4090402867,   0.4555241638,  -0.1532967802,  -0.0962870009 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db0_coef.m"; fail; fi

cat > test_flat_Da0_coef.m << 'EOF'
Da0 = [   1.0000000000,  -0.0002064336,   0.0001217340,  -0.0000918745, ... 
          0.0000830685,  -0.0000783932,   0.0000755672,  -0.0000703639, ... 
          0.0000664611,  -0.0000660794,   0.0000693561,  -0.0001417023 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_flat_Da0_coef.m"; fail; fi

cat > test_flat_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,   0.4963403886,  -0.1198711984,   0.0562585213, ... 
         -0.0320248509,   0.0197817114,  -0.0126418045,   0.0081426631, ... 
         -0.0051820763,   0.0032068996,  -0.0019023142,   0.0011986006 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_flat_Db0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="tarczynski_polyphase_allpass_test"

diff -Bb test_Da0_coef.m $nstr"_Da0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da0_coef.m"; fail; fi

diff -Bb test_Db0_coef.m $nstr"_Db0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Db0_coef.m"; fail; fi

diff -Bb test_flat_Da0_coef.m $nstr"_flat_delay_Da0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_flat_Da0_coef.m"; fail; fi

diff -Bb test_flat_Db0_coef.m $nstr"_flat_delay_Db0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_flat_Db0_coef.m"; fail; fi


#
# this much worked
#
pass

