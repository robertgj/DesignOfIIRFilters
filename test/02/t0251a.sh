#!/bin/sh

prog=tarczynski_frm_halfband_test.m

depends="test/tarczynski_frm_halfband_test.m \
test_common.m print_polynomial.m frm_lowpass_vectors.m"
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
cat > test.r0.ok << 'EOF'
r0 = [   1.0000000000,   0.4657388788,  -0.0777652360,   0.0127912771, ... 
         0.0009047874,  -0.0113641029 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.r0.ok"; fail; fi

cat > test.aa0.ok << 'EOF'
aa0 = [  -0.0028509955,   0.0059539963,   0.0051671440,  -0.0031192378, ... 
         -0.0100959594,   0.0052955495,   0.0122624638,   0.0031647359, ... 
         -0.0298358269,  -0.0148174009,   0.0329956412,   0.0378441781, ... 
         -0.0498590281,  -0.0822403719,   0.0492034981,   0.3157329237, ... 
          0.4482781878,   0.3157329237,   0.0492034981,  -0.0822403719, ... 
         -0.0498590281,   0.0378441781,   0.0329956412,  -0.0148174009, ... 
         -0.0298358269,   0.0031647359,   0.0122624638,   0.0052955495, ... 
         -0.0100959594,  -0.0031192378,   0.0051671440,   0.0059539963, ... 
         -0.0028509955 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.aa0.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.r0.ok tarczynski_frm_halfband_test_r0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.r0.ok"; fail; fi
diff -Bb test.aa0.ok tarczynski_frm_halfband_test_aa0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.aa0.ok"; fail; fi


#
# this much worked
#
pass

