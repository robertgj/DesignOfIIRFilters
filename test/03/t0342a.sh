#!/bin/sh

prog=tarczynski_parallel_allpass_bandpass_hilbert_test.m
depends="tarczynski_parallel_allpass_bandpass_hilbert_test.m \
test_common.m print_polynomial.m print_pole_zero.m"
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
Da0 = [   1.0000000000,   0.3123079354,  -0.2317108438,   0.9181260586, ... 
          0.2492627390,  -0.1604453376,  -0.1449740884,   0.1991309068, ... 
          0.1424266816,  -0.7047805558,   0.0597938923,   0.1479724997, ... 
         -0.2887348192 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Da0_coef.m"; fail; fi
cat > test_Db0_coef.m << 'EOF'
Db0 = [   1.0000000000,  -0.2759072714,  -0.8959725116,   1.0579968251, ... 
          0.3672877136,  -0.4415731334,  -0.3552580282,   0.4705275516, ... 
          0.4602430859,  -0.8255136289,   0.0910399914,   0.3135264585, ... 
         -0.2785177818 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Db0_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog 2>/dev/null > test.out
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

