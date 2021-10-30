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
Da0 = [   1.0000000000,  -1.3412921211,   0.9463621563,   0.8935366601, ... 
         -1.9564292475,   1.7224050654,  -0.3124222408,  -0.6211089430, ... 
          0.7593804917,  -0.3617306623,   0.0925143018 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da0_coef.m"; fail; fi

cat > test_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,  -1.9561812074,   1.2919814472,   1.1299281281, ... 
         -2.6898941225,   2.1573517316,  -0.3118182868,  -0.8675026448, ... 
          0.9351685166,  -0.4298356711,   0.0998802036 ]';
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

