#!/bin/sh

prog=tarczynski_parallel_allpass_bandpass_hilbert_test.m
depends="test/tarczynski_parallel_allpass_bandpass_hilbert_test.m \
../tarczynski_parallel_allpass_bandpass_test_Da0_coef.m \
../tarczynski_parallel_allpass_bandpass_test_Db0_coef.m \
test_common.m WISEJ_PAB.m delayz.m print_polynomial.m print_pole_zero.m \
qroots.m \
qzsolve.oct"

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
Da0 = [   1.0000000000,  -1.4688447206,   1.3894598505,   0.4309560646, ... 
         -1.6797926460,   1.9625386035,  -0.5350978327,  -0.6011264363, ... 
          1.0680977630,  -0.6177889404,   0.2148210858 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da0_coef.m"; fail; fi

cat > test_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,  -2.1775480564,   1.9009496869,   0.4380913688, ... 
         -2.5116906782,   2.5737828248,  -0.6881583108,  -0.9624476799, ... 
          1.3842253912,  -0.7776303503,   0.2244247347 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

nstr=tarczynski_parallel_allpass_bandpass_hilbert_test

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_Da0_coef.m $nstr"_Da0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da0_coef.m"; fail; fi

diff -Bb test_Db0_coef.m $nstr"_Db0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Db0_coef.m"; fail; fi


#
# this much worked
#
pass

