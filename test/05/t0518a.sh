#!/bin/sh

prog=yalmip_kyp_lowpass_test.m
depends="test/yalmip_kyp_lowpass_test.m test_common.m print_polynomial.m \
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
cat > test_d_10_coef.ok << 'EOF'
h10 = [  0.0024629329,  0.0043298849,  0.0008282007, -0.0115481860, ... 
        -0.0278865073, -0.0325179158, -0.0066047652,  0.0572760082, ... 
         0.1445171527,  0.2220942693,  0.2561793607,  0.2318957022, ... 
         0.1611645243,  0.0739878111,  0.0009750918, -0.0403274607, ... 
        -0.0484701940, -0.0329189429, -0.0072306383,  0.0156128676, ... 
         0.0262869165,  0.0218830346,  0.0071202619, -0.0082811305, ... 
        -0.0156301865, -0.0126117446, -0.0037677179,  0.0039725700, ... 
         0.0065853023,  0.0047851810,  0.0018073154 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_10_coef.ok"; fail; fi

cat > test_d_15_coef.ok << 'EOF'
h15 = [  0.0018153433,  0.0019311888, -0.0009875510, -0.0060034887, ... 
        -0.0077765174, -0.0007662546,  0.0131460113,  0.0216284180, ... 
         0.0101884843, -0.0217611568, -0.0512896160, -0.0419648941, ... 
         0.0288737914,  0.1457559911,  0.2562134522,  0.3015414547, ... 
         0.2562134522,  0.1457559911,  0.0288737914, -0.0419648941, ... 
        -0.0512896160, -0.0217611568,  0.0101884843,  0.0216284180, ... 
         0.0131460113, -0.0007662546, -0.0077765174, -0.0060034887, ... 
        -0.0009875510,  0.0019311888,  0.0018153433 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_15_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_d_10_coef.ok yalmip_kyp_lowpass_test_d_10_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d_10_coef.ok"; fail; fi

diff -Bb test_d_15_coef.ok yalmip_kyp_lowpass_test_d_15_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d_15_coef.ok"; fail; fi

#
# this much worked
#
pass

