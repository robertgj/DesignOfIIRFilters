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
h12 = [  0.0024292544,  0.0076814827,  0.0129778955,  0.0119736234, ... 
        -0.0006944150, -0.0227020194, -0.0409975987, -0.0369238114, ... 
         0.0022532638,  0.0731333295,  0.1550531637,  0.2194140744, ... 
         0.2434201111,  0.2198604183,  0.1584730150,  0.0802475720, ... 
         0.0089093745, -0.0370089988, -0.0498190089, -0.0347142319, ... 
        -0.0067970519,  0.0165819952,  0.0245642967,  0.0173049056, ... 
         0.0034333035, -0.0072386797, -0.0100892145, -0.0069000146, ... 
        -0.0023526179,  0.0002534162,  0.0006135639 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_12_coef.ok"; fail; fi

cat > test_d_15_coef.ok << 'EOF'
h15 = [  0.0018076436,  0.0019195143, -0.0009993634, -0.0060057772, ... 
        -0.0077648822, -0.0007486215,  0.0131528562,  0.0216127665, ... 
         0.0101572326, -0.0217839993, -0.0512814097, -0.0419256503, ... 
         0.0289181493,  0.1457730803,  0.2561921781,  0.3015020981, ... 
         0.2561921781,  0.1457730803,  0.0289181493, -0.0419256503, ... 
        -0.0512814097, -0.0217839993,  0.0101572326,  0.0216127665, ... 
         0.0131528562, -0.0007486215, -0.0077648822, -0.0060057772, ... 
        -0.0009993634,  0.0019195143,  0.0018076436 ];
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

