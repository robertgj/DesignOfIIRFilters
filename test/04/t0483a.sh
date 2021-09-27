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
Da0 = [   1.0000000000,   0.0486992284,   0.2912438656,   0.8053720430, ... 
          0.0686369568,   0.1589876704,   0.3625985094,   0.2675128980, ... 
          0.3649903015,   0.2899808347,   0.1092616581,   0.2354951322, ... 
         -0.0555049908 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1kpcls.ok"; fail; fi

cat > test_Db0.ok << 'EOF'
Db0 = [   1.0000000000,   0.3327606778,   0.5873350122,   0.9401923907, ... 
          0.2779952423,   0.4145883840,   0.5944338060,   0.4559472481, ... 
          0.4475545001,   0.2941653950,   0.0803302311,   0.1272939087, ... 
         -0.1286326403 ]';
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

