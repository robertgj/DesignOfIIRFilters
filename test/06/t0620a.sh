#!/bin/sh

prog=directFIRnonsymmetric_kyp_finsler_lowpass_test.m

depends="test/directFIRnonsymmetric_kyp_finsler_lowpass_test.m test_common.m \
delayz.m print_polynomial.m konopacki.m directFIRnonsymmetricEsqPW.m"

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
h = [ -0.0002899669,  0.0166251393,  0.0343370607,  0.0363846702, ... 
       0.0080503052, -0.0381570521, -0.0580883437, -0.0056099354, ... 
       0.1224009039,  0.2669455390,  0.3398612129,  0.2892889238, ... 
       0.1435459025, -0.0074082342, -0.0800548957, -0.0575720705, ... 
       0.0077961603,  0.0474591481,  0.0337140878, -0.0075802835, ... 
      -0.0322806743, -0.0215305807,  0.0068115316,  0.0226407365, ... 
       0.0140773122, -0.0056358173, -0.0160754503, -0.0100487687, ... 
       0.0031423810,  0.0104762269,  0.0109585092 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_finsler_lowpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

