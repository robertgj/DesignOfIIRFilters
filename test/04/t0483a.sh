#!/bin/sh

prog=tarczynski_parallel_allpass_multiband_test.m

depends="test/tarczynski_parallel_allpass_multiband_test.m \
test_common.m delayz.m print_polynomial.m WISEJ_PAB.m qroots.oct \
"

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
Da0 = [   1.0000000000,   1.5245134532,   1.1082515988,   0.9165073312, ... 
          1.0770766170,   0.6790837989,   0.2940428843,   0.2880534847, ... 
         -0.1264791143,  -0.7574751433,  -0.7990383171,  -0.5088418075, ... 
         -0.6151248030,  -0.6757527599,  -0.5202143611,  -0.4859989547, ... 
         -0.4199452832,  -0.1125252513,   0.0748904596,   0.0609344001, ... 
          0.0638260246 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1kpcls.ok"; fail; fi

cat > test_Db0.ok << 'EOF'
Db0 = [   1.0000000000,   1.2598932316,   0.5209146432,   0.4342588483, ... 
          0.8942463255,   0.4288021891,  -0.1668428878,  -0.0383999393, ... 
         -0.0602639609,  -0.3474467505,  -0.2420423340,  -0.0464767749, ... 
         -0.3311043650,  -0.3934683633,  -0.1921075447,  -0.3307907238, ... 
         -0.5120434443,  -0.2926230128,  -0.1040493254,  -0.0877112281, ... 
          0.0020240800 ]';
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

