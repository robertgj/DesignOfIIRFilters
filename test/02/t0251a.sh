#!/bin/sh

prog=tarczynski_frm_halfband_test.m

depends="test/tarczynski_frm_halfband_test.m \
test_common.m delayz.m print_polynomial.m frm_lowpass_vectors.m"
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
r0 = [   1.0000000000,   0.4603571282,  -0.0723156819,   0.0059281768, ... 
         0.0051021439,  -0.0122447597 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.r0.ok"; fail; fi

cat > test.aa0.ok << 'EOF'
aa0 = [  -0.0023671226,   0.0034040738,   0.0053495668,  -0.0042315326, ... 
         -0.0088249174,   0.0057467011,   0.0124517853,   0.0024368378, ... 
         -0.0263276099,  -0.0151788875,   0.0355216500,   0.0369295060, ... 
         -0.0493681674,  -0.0817264559,   0.0513933765,   0.3117080103, ... 
          0.4495329566,   0.3117080103,   0.0513933765,  -0.0817264559, ... 
         -0.0493681674,   0.0369295060,   0.0355216500,  -0.0151788875, ... 
         -0.0263276099,   0.0024368378,   0.0124517853,   0.0057467011, ... 
         -0.0088249174,  -0.0042315326,   0.0053495668,   0.0034040738, ... 
         -0.0023671226 ]';
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

