#!/bin/sh

prog=tarczynski_parallel_allpass_bandpass_hilbert_test.m
depends="tarczynski_parallel_allpass_bandpass_hilbert_test.m \
test_common.m print_polynomial.m print_pole_zero.m"
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
Da0 = [   1.0000000000,  -1.3420348529,   0.9476408004,   0.8924339392, ... 
         -1.9566456567,   1.7230582345,  -0.3125109409,  -0.6221973493, ... 
          0.7605942655,  -0.3624502969,   0.0926731060 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da0_coef.m"; fail; fi
cat > test_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,  -1.9568937354,   1.2936834023,   1.1283899984, ... 
         -2.6900919871,   2.1584733783,  -0.3119350555,  -0.8689577257, ... 
          0.9367692460,  -0.4306409818,   0.1000235909 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_Da0_coef.m \
     tarczynski_parallel_allpass_bandpass_hilbert_test_Da0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da0_coef.m"; fail; fi
diff -Bb test_Db0_coef.m \
     tarczynski_parallel_allpass_bandpass_hilbert_test_Db0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Db0_coef.m"; fail; fi


#
# this much worked
#
pass

