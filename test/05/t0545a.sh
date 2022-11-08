#!/bin/sh

prog=directFIRnonsymmetric_kyp_highpass_test.m

depends="test/directFIRnonsymmetric_kyp_highpass_test.m test_common.m \
print_polynomial.m"

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
h = [ -0.0045908275,  0.0367896502, -0.0155533359, -0.0293787980, ... 
      -0.0162485668,  0.0277214878,  0.0611466942,  0.0217232900, ... 
      -0.1115916948, -0.2636536063,  0.6222600498, -0.2923729228, ... 
      -0.1264700540,  0.0268370784,  0.0839678484,  0.0416173280, ... 
      -0.0269697475, -0.0480532582, -0.0142181689,  0.0132303792, ... 
       0.0415093602,  0.0065370125, -0.0258447527, -0.0203407477, ... 
       0.0024828035,  0.0177709158,  0.0121564144, -0.0045310521, ... 
      -0.0179752523, -0.0013547919,  0.0133122648 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_highpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

