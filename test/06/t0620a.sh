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
h = [ -0.0005736345,  0.0161437264,  0.0340720168,  0.0368754421, ... 
       0.0093761524, -0.0365316705, -0.0571112305, -0.0058457922, ... 
       0.1213243627,  0.2661212861,  0.3400945420,  0.2903562057, ... 
       0.1443546141, -0.0077455042, -0.0813213368, -0.0585997741, ... 
       0.0080225766,  0.0488128116,  0.0350370746, -0.0073823662, ... 
      -0.0332412856, -0.0226321155,  0.0066223749,  0.0235434252, ... 
       0.0152561803, -0.0051529676, -0.0166363405, -0.0111820132, ... 
       0.0021352985,  0.0098704267,  0.0110955851 ];
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

