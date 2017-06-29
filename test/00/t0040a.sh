#!/bin/sh

prog=tarczynski_polyphase_allpass_test.m
depends="tarczynski_polyphase_allpass_test.m \
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
Da0 = [   1.0000000000,  -0.0002183454,   0.0001224241,  -0.0000949279, ... 
          0.0000837578,  -0.0000780025,   0.0000739672,  -0.0000704120, ... 
          0.0000668630,  -0.0000645049,   0.0000697120,  -0.0001413494 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da0_coef.m"; fail; fi
cat > test_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,   0.4963270767,  -0.1198736055,   0.0562547868, ... 
         -0.0320261129,   0.0197798413,  -0.0126414494,   0.0081398844, ... 
         -0.0051807503,   0.0032049858,  -0.0019026784,   0.0011975275 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog 2>/dev/null > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_Da0_coef.m tarczynski_polyphase_allpass_test_Da0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da0_coef.m"; fail; fi
diff -Bb test_Db0_coef.m tarczynski_polyphase_allpass_test_Db0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Db0_coef.m"; fail; fi


#
# this much worked
#
pass

