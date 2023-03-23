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
Da0 = [   1.0000000000,   0.4821279733,  -0.1348204061,   1.3982173433, ... 
          0.9106664533,  -0.4341945427,   1.1944471436,   0.8709563054, ... 
         -0.4569884866,   0.7013303472,   0.5230443931,  -0.3676069899, ... 
          0.1489228801,   0.2010803193,  -0.1722400837 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1kpcls.ok"; fail; fi

cat > test_Db0.ok << 'EOF'
Db0 = [   1.0000000000,   0.6554576967,  -0.0023951459,   1.1736913498, ... 
          0.7238709592,  -0.4303798950,   1.0472859473,   0.8090040741, ... 
         -0.3824070546,   0.6502917742,   0.5945357638,  -0.1535663163, ... 
          0.2529805442,   0.2589030818,  -0.1162678932 ]';
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

