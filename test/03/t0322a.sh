#!/bin/sh

prog=tarczynski_parallel_allpass_bandpass_test.m
depends="tarczynski_parallel_allpass_bandpass_test.m \
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
Da0 = [   1.0000000000,  -1.8973150269,   1.2642558998,   0.9180982400, ... 
         -2.2325999512,   1.7468966414,  -0.1256228968,  -0.9677806380, ... 
          1.0525981896,  -0.5245983396,   0.1304756216 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da0_coef.m"; fail; fi
cat > test_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,  -1.3313250884,   0.9709608648,   0.7128573966, ... 
         -1.6815516926,   1.4133922361,  -0.1433260786,  -0.7254905194, ... 
          0.8538839663,  -0.4392568120,   0.1374006920 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog 2>/dev/null > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_Da0_coef.m tarczynski_parallel_allpass_bandpass_test_Da0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da0_coef.m"; fail; fi
diff -Bb test_Db0_coef.m tarczynski_parallel_allpass_bandpass_test_Db0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Db0_coef.m"; fail; fi


#
# this much worked
#
pass

