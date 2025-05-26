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
Da0 = [   1.0000000000,   0.8758082387,  -0.5282923338,  -0.4837646775, ... 
         -0.2064318084,  -0.7311944007,  -0.0240184126,   0.4881584176, ... 
          0.1027243825,  -0.0365096089,  -0.1167959904,   0.0327642596, ... 
          0.1897932398,  -0.3232947946,  -0.1910532378,   0.3095473853, ... 
         -0.0488342961,   0.0096321204,   0.3746065890,   0.0506042621, ... 
         -0.1541145443 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_A1kpcls.ok"; fail; fi

cat > test_Db0.ok << 'EOF'
Db0 = [   1.0000000000,   0.7040519911,  -0.7032037809,  -0.1756156768, ... 
          0.3355189787,  -0.6205575097,  -0.3330384015,   0.1166764149, ... 
         -0.0849703942,  -0.0208988401,  -0.1079263052,  -0.0291344780, ... 
          0.1764690525,  -0.2024426261,   0.1021596899,   0.5459474095, ... 
         -0.1135367851,  -0.1414567645,   0.3167276693,  -0.0052858650, ... 
         -0.2000830424 ]';
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

