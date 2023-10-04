#!/bin/sh

prog=yalmip_kyp_lowpass_test.m
depends="test/yalmip_kyp_lowpass_test.m test_common.m delayz.m print_polynomial.m \
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
h10 = [  0.0024629409,  0.0043299063,  0.0008282373, -0.0115481441, ... 
        -0.0278864843, -0.0325179405, -0.0066048486,  0.0572758926, ... 
         0.1445170633,  0.2220942579,  0.2561794255,  0.2318957749, ... 
         0.1611645154,  0.0739876834,  0.0009749025, -0.0403275948, ... 
        -0.0484701847, -0.0329188013, -0.0072304664,  0.0156129560, ... 
         0.0262868789,  0.0218829195,  0.0071201577, -0.0082811653, ... 
        -0.0156301553, -0.0126116904, -0.0037676802,  0.0039725804, ... 
         0.0065852969,  0.0047851743,  0.0018073130 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_10_coef.ok"; fail; fi

cat > test_d_12_coef.ok << 'EOF'
h12 = [  0.0024292561,  0.0076814875,  0.0129779019,  0.0119736253, ... 
        -0.0006944250, -0.0227020425, -0.0409976238, -0.0369238187, ... 
         0.0022532897,  0.0731333868,  0.1550532320,  0.2194141278, ... 
         0.2434201377,  0.2198604285,  0.1584730311,  0.0802476084, ... 
         0.0089094241, -0.0370089594, -0.0498190008, -0.0347142572, ... 
        -0.0067970921,  0.0165819653,  0.0245642920,  0.0173049235, ... 
         0.0034333290, -0.0072386614, -0.0100892096, -0.0069000200, ... 
        -0.0023526267,  0.0002534095,  0.0006135609 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_12_coef.ok"; fail; fi

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

diff -Bb test_d_12_coef.ok yalmip_kyp_lowpass_test_d_12_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d_12_coef.ok"; fail; fi

diff -Bb test_d_15_coef.ok yalmip_kyp_lowpass_test_d_15_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d_15_coef.ok"; fail; fi

#
# this much worked
#
pass

