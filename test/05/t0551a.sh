#!/bin/sh

prog=tarczynski_frm_allpass_test.m

depends="test/tarczynski_frm_allpass_test.m test_common.m print_polynomial.m \
print_pole_zero.m frm_lowpass_vectors.m"

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
cat > test_r1.ok << 'EOF'
r1 = [   1.0000000000,   0.2655106545,   0.4528982259,  -0.1218777129, ... 
        -0.0442251140,   0.0538752787,  -0.0287904188,   0.0239073933, ... 
        -0.0202545449,   0.0024397226,   0.0048490916 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r1.ok"; fail; fi

cat > test_aa1.ok << 'EOF'
aa1 = [  -0.0225910587,  -0.0127581744,   0.0318537188,  -0.0034311292, ... 
         -0.0294551375,   0.0056123986,   0.0162735379,  -0.0197829325, ... 
         -0.0037293868,   0.0597931291,   0.0049630073,  -0.0705863880, ... 
          0.0365011368,   0.0550470293,  -0.0507461960,  -0.0018680959, ... 
          0.0805544723,  -0.0669461879,  -0.1312870209,   0.2906126382, ... 
          0.6456648172,   0.2906126382,  -0.1312870209,  -0.0669461879, ... 
          0.0805544723,  -0.0018680959,  -0.0507461960,   0.0550470293, ... 
          0.0365011368,  -0.0705863880,   0.0049630073,   0.0597931291, ... 
         -0.0037293868,  -0.0197829325,   0.0162735379,   0.0056123986, ... 
         -0.0294551375,  -0.0034311292,   0.0318537188,  -0.0127581744, ... 
         -0.0225910587 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa1.ok"; fail; fi

cat > test_ac1.ok << 'EOF'
ac1 = [  -0.0162040915,   0.0555551944,   0.1746835117,   0.0609049851, ... 
         -0.0223612278,  -0.0045932620,   0.0106785471,  -0.0004966531, ... 
         -0.0075706127,  -0.0375034158,   0.1377984195,   0.4813957491, ... 
          0.1796418413,  -0.0831329390,  -0.0119084141,   0.0598520905, ... 
         -0.0504396119,  -0.0121730256,   0.0653545851,  -0.0671874567, ... 
         -0.0237326262,  -0.0671874567,   0.0653545851,  -0.0121730256, ... 
         -0.0504396119,   0.0598520905,  -0.0119084141,  -0.0831329390, ... 
          0.1796418413,   0.4813957491,   0.1377984195,  -0.0375034158, ... 
         -0.0075706127,  -0.0004966531,   0.0106785471,  -0.0045932620, ... 
         -0.0223612278,   0.0609049851,   0.1746835117,   0.0555551944, ... 
         -0.0162040915 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ac1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_r1.ok tarczynski_frm_allpass_test_r1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_r1.ok"; fail; fi

diff -Bb test_aa1.ok tarczynski_frm_allpass_test_aa1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_aa1.ok"; fail; fi

diff -Bb test_ac1.ok tarczynski_frm_allpass_test_ac1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_ac1.ok"; fail; fi


#
# this much worked
#
pass

