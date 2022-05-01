#!/bin/sh

prog=tarczynski_frm_halfband_test.m

depends="tarczynski_frm_halfband_test.m \
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
r0 = [   1.0000000000,   0.4651426120,  -0.0746801205,   0.0126088083, ... 
         0.0030207562,  -0.0101070854 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.r0.ok"; fail; fi

cat > test.aa0.ok << 'EOF'
aa0 = [  -0.0026226206,   0.0038633874,   0.0051225652,  -0.0048478006, ... 
         -0.0081973284,   0.0056008866,   0.0126611876,   0.0024155445, ... 
         -0.0272891783,  -0.0137592485,   0.0359522072,   0.0356572688, ... 
         -0.0486649143,  -0.0823695843,   0.0521867610,   0.3122453156, ... 
          0.4474131936,   0.3122453156,   0.0521867610,  -0.0823695843, ... 
         -0.0486649143,   0.0356572688,   0.0359522072,  -0.0137592485, ... 
         -0.0272891783,   0.0024155445,   0.0126611876,   0.0056008866, ... 
         -0.0081973284,  -0.0048478006,   0.0051225652,   0.0038633874, ... 
         -0.0026226206 ]';
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

