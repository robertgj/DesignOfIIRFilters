#!/bin/sh

prog=tarczynski_hilbert_test.m

depends="tarczynski_hilbert_test.m test_common.m print_polynomial.m"
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
cat > test.ok.N << 'EOF'
N = [  -0.0579063991,  -0.0707490525,  -0.0092677810,  -0.0274919718, ... 
       -0.1104277026,  -0.4894105730,   0.8948745630,   1.0527570805, ... 
       -0.8678508170,  -0.4990735123,   0.1861313381,   0.0311088704 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.N"; fail; fi

cat > test.ok.D << 'EOF'
D = [   1.0000000000,  -1.4110993644,   0.4589810713,  -0.0092017575, ... 
        0.0011255865,   0.0014507700,  -0.0018420748 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.D"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok.N tarczynski_hilbert_test_N_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.N"; fail; fi

diff -Bb test.ok.D tarczynski_hilbert_test_D_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.D"; fail; fi


#
# this much worked
#
pass

