#!/bin/sh

prog=directFIRnonsymmetric_kyp_union_bandpass_test.m

depends="test/directFIRnonsymmetric_kyp_union_bandpass_test.m test_common.m delayz.m \
print_polynomial.m qroots.oct"

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
h = [  0.0013633229,  0.0022300156, -0.0002843620,  0.0045952866, ... 
       0.0090358013, -0.0062595406, -0.0210642878, -0.0048345909, ... 
       0.0091138128, -0.0074738177,  0.0115356818,  0.0775115371, ... 
       0.0372415597, -0.1392938633, -0.1730141965,  0.0786322155, ... 
       0.2684908890,  0.0823700629, -0.2041895746, -0.1762180150, ... 
       0.0520910812,  0.1176283794,  0.0212599674, -0.0136408034, ... 
       0.0139092080, -0.0134762035, -0.0501832460, -0.0147425539, ... 
       0.0308639150,  0.0199046364, -0.0024684167,  0.0019080465, ... 
       0.0023096157, -0.0108231031, -0.0097945095,  0.0032384450, ... 
       0.0055890162,  0.0005688596,  0.0007303145,  0.0018934414, ... 
      -0.0012919282 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_union_bandpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

