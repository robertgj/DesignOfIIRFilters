#!/bin/sh

prog=tarczynski_hilbert_test.m

depends="test/tarczynski_hilbert_test.m test_common.m print_polynomial.m"
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
cat > test.ok.N0 << 'EOF'
N0 = [  -0.0579070563,  -0.0707497056,  -0.0092649433,  -0.0274905676, ... 
        -0.1104285593,  -0.4894093582,   0.8948761991,   1.0527640851, ... 
        -0.8678627190,  -0.4990853668,   0.1861392669,   0.0311117831 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.N0"; fail; fi

cat > test.ok.D0 << 'EOF'
D0 = [   1.0000000000,  -1.4111138222,   0.4589969708,  -0.0092045528, ... 
         0.0011251253,   0.0014505956,  -0.0018412451 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.D0"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok.N0 tarczynski_hilbert_test_N0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.N0"; fail; fi

diff -Bb test.ok.D0 tarczynski_hilbert_test_D0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.D0"; fail; fi


#
# this much worked
#
pass

