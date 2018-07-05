#!/bin/sh

prog=tarczynski_deczky1_test.m

depends="tarczynski_deczky1_test.m \
test_common.m print_polynomial.m WISEJ_ND.m tf2Abcd.m"

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
cat > test.ok.N << 'EOF'
N = [   0.0095380838,   0.0109608619,  -0.0258454676,   0.0045745905, ... 
        0.0146566325,   0.0073654540,  -0.0548386069,   0.0103495879, ... 
        0.2235388397,   0.4134372875,   0.3933557331,   0.2136223426, ... 
        0.0573090371 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.N"; fail; fi

cat > test.ok.D << 'EOF'
D = [   1.0000000000,  -0.5052405063,   1.2073401895,  -0.7847897993, ... 
        0.5547435463,  -0.2687696722,   0.0798567135 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.D"; fail; fi
#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok.N tarczynski_deczky1_test_N_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.N"; fail; fi

diff -Bb test.ok.D tarczynski_deczky1_test_D_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.D"; fail; fi

#
# this much worked
#
pass
