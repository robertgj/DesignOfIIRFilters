#!/bin/sh

prog=tarczynski_parallel_allpass_multiband_test.m

depends="test/tarczynski_parallel_allpass_multiband_test.m \
test_common.m delayz.m print_polynomial.m WISEJ_PA.m \
qroots.oct"

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
Da0 = [   1.0000000000,   1.7458741250,   1.2591794992,   0.8315889878, ... 
          1.2121044016,   0.8183862538,   0.2119381562,   0.3057123467, ... 
         -0.0623759677,  -0.8977134506,  -0.8593085857,  -0.5410613360, ... 
         -0.6744420425,  -0.7007966270,  -0.5782947679,  -0.5464987549, ... 
         -0.4237906010,  -0.1218105033,   0.0631531748,   0.1022217453, ... 
          0.0549001386 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1kpcls.ok"; fail; fi

cat > test_Db0.ok << 'EOF'
Db0 = [   1.0000000000,   1.4810293282,   0.6148833973,   0.2679594656, ... 
          1.0426733249,   0.5914153935,  -0.3164096104,  -0.0769050967, ... 
          0.0294698661,  -0.4350227948,  -0.2453167181,  -0.0501839462, ... 
         -0.3822096876,  -0.3829298224,  -0.2174795844,  -0.3919847791, ... 
         -0.5229878749,  -0.3143248593,  -0.1437574988,  -0.0580746382, ... 
         -0.0069348923 ]';
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

