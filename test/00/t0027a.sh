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
N0 = [  -0.0579061747,  -0.0707480534,  -0.0092701111,  -0.0274946021, ... 
        -0.1104261025,  -0.4894105426,   0.8948724639,   1.0527502772, ... 
        -0.8678397393,  -0.4990617933,   0.1861237790,   0.0311055441 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.N0"; fail; fi

cat > test.ok.D0 << 'EOF'
D0 = [   1.0000000000,  -1.4110846073,   0.4589647466,  -0.0091993520, ... 
         0.0011260510,   0.0014504788,  -0.0018421827 ]';
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

