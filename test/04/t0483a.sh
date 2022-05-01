#!/bin/sh

prog=tarczynski_parallel_allpass_multiband_test.m

depends="tarczynski_parallel_allpass_multiband_test.m \
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
Da0 = [   1.0000000000,   0.4237012608,   0.8009094251,   1.6322347150, ... 
          0.6495571943,   0.9059887394,   1.3460460430,   0.7865038626, ... 
          0.6317493372,   1.0637684390,   0.5345600029,   0.1852939452, ... 
          0.3816111375 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1kpcls.ok"; fail; fi

cat > test_Db0.ok << 'EOF'
Db0 = [   1.0000000000,   0.5827425694,   0.8830522535,   1.4719516548, ... 
          0.4110171429,   0.5097393482,   0.8840224311,   0.5283336616, ... 
          0.5376419443,   0.9907022053,   0.5653311240,   0.2449986578, ... 
          0.3670366323 ]';
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

