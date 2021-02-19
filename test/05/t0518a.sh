#!/bin/sh

prog=yalmip_kyp_lowpass_test.m
depends="yalmip_kyp_lowpass_test.m test_common.m print_polynomial.m \
directFIRnonsymmetricEsqPW.m"

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
cat > test_h_coef.ok << 'EOF'
h = [  0.0008656281,  0.0021696544,  0.0015409094, -0.0044622917, ... 
      -0.0158159316, -0.0238564167, -0.0115295105,  0.0369399475, ... 
       0.1209482871,  0.2146857085,  0.2753128363,  0.2671184150, ... 
       0.1864131493,  0.0680195698, -0.0338776291, -0.0783792857, ... 
      -0.0609991209, -0.0114347624,  0.0303914254,  0.0408361994, ... 
       0.0229705268, -0.0030363605, -0.0182941274, -0.0172426361, ... 
      -0.0067422453,  0.0030663947,  0.0067934959,  0.0053367805, ... 
       0.0023609590,  0.0004446292, -0.0000798085 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok yalmip_kyp_lowpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.ok"; fail; fi

#
# this much worked
#
pass

