#!/bin/sh

prog=tarczynski_polyphase_allpass_test.m
depends="tarczynski_polyphase_allpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m WISEJ_PA.m"
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
Da0 = [   1.0000000000,  -0.0702820939,  -0.8478194174,   0.0508837846, ... 
          0.6054618425,   0.2605233987,  -0.2453761217,  -0.4331206576, ... 
          0.2988704607,   0.3188911810,  -0.0913711939,  -0.0240607257 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da0_coef.m"; fail; fi

cat > test_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,   0.4289365448,  -1.0067188852,  -0.3026135247, ... 
          0.6945003629,   0.5329886293,  -0.1762656788,  -0.5592654600, ... 
          0.1119955543,   0.5093592892,   0.0113821409,  -0.0802175025 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db0_coef.m"; fail; fi

cat > test_flat_Da0_coef.m << 'EOF'
Da0 = [   1.0000000000,  -0.0002131484,   0.0001173191,  -0.0000929508, ... 
          0.0000821848,  -0.0000768234,   0.0000730616,  -0.0000695878, ... 
          0.0000660512,  -0.0000641649,   0.0000694074,  -0.0001410123 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_flat_Da0_coef.m"; fail; fi

cat > test_flat_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,   0.4963318849,  -0.1198759180,   0.0562533645, ... 
         -0.0320256567,   0.0197795125,  -0.0126413012,   0.0081397750, ... 
         -0.0051805041,   0.0032046752,  -0.0019025324,   0.0011976340 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_flat_Db0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

strn="tarczynski_polyphase_allpass_test"

diff -Bb test_Da0_coef.m $strn"_Da0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da0_coef.m"; fail; fi

diff -Bb test_Db0_coef.m $strn"_Db0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Db0_coef.m"; fail; fi

diff -Bb test_flat_Da0_coef.m $strn"_flat_delay_Da0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_flat_Da0_coef.m"; fail; fi

diff -Bb test_flat_Db0_coef.m $strn"_flat_delay_Db0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_flat_Db0_coef.m"; fail; fi


#
# this much worked
#
pass

