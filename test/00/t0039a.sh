#!/bin/sh

prog=tarczynski_parallel_allpass_test.m
depends="tarczynski_parallel_allpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m WISEJ_PA.m"
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
cat > test_Da0_coef.m << 'EOF'
Da0 = [   1.0000000000,   0.6972800895,  -0.2975062139,  -0.3126568149, ... 
         -0.1822056467,   0.0540553513,   0.0875337561,  -0.1043233247, ... 
          0.1845966147,   0.0440769846,  -0.1321003444,   0.0451934246 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da0_coef.m"; fail; fi
cat > test_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,   0.1561452139,  -0.3135749197,   0.3178482983, ... 
          0.1300074645,   0.0784806204,  -0.0638102286,  -0.1841984885, ... 
          0.2692567177,  -0.0893424226,  -0.1362442636,   0.1339410075, ... 
         -0.0582210798 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog 2>/dev/null > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_Da0_coef.m tarczynski_parallel_allpass_test_Da0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da0_coef.m"; fail; fi
diff -Bb test_Db0_coef.m tarczynski_parallel_allpass_test_Db0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Db0_coef.m"; fail; fi


#
# this much worked
#
pass

