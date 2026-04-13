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
h12 = [  0.0024292730,  0.0076815267,  0.0129779491,  0.0119736435, ... 
        -0.0006944702, -0.0227021461, -0.0409977271, -0.0369238401, ... 
         0.0022533962,  0.0731335932,  0.1550534530,  0.2194142837, ... 
         0.2434202100,  0.2198604655,  0.1584730963,  0.0802477260, ... 
         0.0089095606, -0.0370088639, -0.0498189846, -0.0347143115, ... 
        -0.0067971727,  0.0165819058,  0.0245642780,  0.0173049501, ... 
         0.0034333732, -0.0072386246, -0.0100891952, -0.0069000287, ... 
        -0.0023526477,  0.0002533894,  0.0006135497 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_12_coef.ok"; fail; fi

cat > test_d_15_coef.ok << 'EOF'
h15 = [  0.0018077114,  0.0019195985, -0.0009992713, -0.0060057719, ... 
        -0.0077649971, -0.0007487859,  0.0131527872,  0.0216128949, ... 
         0.0101575030, -0.0217837894, -0.0512814547, -0.0419259537, ... 
         0.0289178047,  0.1457729683,  0.2561923900,  0.3015024646, ... 
         0.2561923900,  0.1457729683,  0.0289178047, -0.0419259537, ... 
        -0.0512814547, -0.0217837894,  0.0101575030,  0.0216128949, ... 
         0.0131527872, -0.0007487859, -0.0077649971, -0.0060057719, ... 
        -0.0009992713,  0.0019195985,  0.0018077114 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_15_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="yalmip_kyp_lowpass_test"

diff -Bb test_d_10_coef.ok $nstr"_d_10_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d_10_coef.ok"; fail; fi

diff -Bb test_d_12_coef.ok $nstr"_d_12_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d_12_coef.ok"; fail; fi

diff -Bb test_d_15_coef.ok $nstr"_d_15_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d_15_coef.ok"; fail; fi

#
# this much worked
#
pass

