#!/bin/sh

prog=directFIRnonsymmetric_kyp_union_double_bandpass_test.m

depends="test/directFIRnonsymmetric_kyp_union_double_bandpass_test.m \
test_common.m delayz.m print_polynomial.m"

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
h = [  0.0018088129, -0.0005644017, -0.0042202266, -0.0019642761, ... 
      -0.0142528443,  0.0196273600,  0.0148855944, -0.0076759554, ... 
       0.0031585995, -0.0139680485,  0.0003407463, -0.0263455542, ... 
       0.0066789470, -0.0281535959,  0.0743812868,  0.1474408094, ... 
      -0.1690011610, -0.0418364085, -0.1062561199, -0.0479753724, ... 
       0.3961296066, -0.0506779858, -0.1101679246, -0.0514657403, ... 
      -0.2107403021,  0.1924977961,  0.1038472941, -0.0474329605, ... 
       0.0083495607, -0.0345404905, -0.0006140319, -0.0230581790, ... 
       0.0046233406, -0.0210907900,  0.0354595837,  0.0497068393, ... 
      -0.0406462473, -0.0079624307, -0.0043193281, -0.0019158787, ... 
       0.0011412831,  0.0010375580,  0.0027916478,  0.0029770507, ... 
       0.0123698291, -0.0121434706, -0.0072648536,  0.0046576928, ... 
      -0.0002034042 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok \
         directFIRnonsymmetric_kyp_union_double_bandpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

