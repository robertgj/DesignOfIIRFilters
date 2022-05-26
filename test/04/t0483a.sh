#!/bin/sh

prog=tarczynski_parallel_allpass_multiband_test.m

depends="test/tarczynski_parallel_allpass_multiband_test.m \
test_common.m print_polynomial.m WISEJ_PAB.m"

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
cat > test_Da0.ok << 'EOF'
Da0 = [   1.0000000000,   0.4353474692,  -0.1057921316,   1.3872970878, ... 
          0.8431922022,  -0.3980794252,   1.1805959325,   0.8149288168, ... 
         -0.4276826460,   0.6790052652,   0.5092532754,  -0.3657675421, ... 
          0.1462157475,   0.1960478208,  -0.1726375579 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1kpcls.ok"; fail; fi

cat > test_Db0.ok << 'EOF'
Db0 = [   1.0000000000,   0.6086720976,   0.0190271949,   1.1651770346, ... 
          0.6664429824,  -0.3971543447,   1.0344557516,   0.7575416667, ... 
         -0.3537433577,   0.6308605560,   0.5797657046,  -0.1531624009, ... 
          0.2488552708,   0.2511216716,  -0.1171178541 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A2epsilon0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="tarczynski_parallel_allpass_multiband_test"

diff -Bb test_Da0.ok $nstr"_Da0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Da0.ok"; fail; fi

diff -Bb test_Db0.ok $nstr"_Db0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_Db0.ok"; fail; fi

#
# this much worked
#
pass

