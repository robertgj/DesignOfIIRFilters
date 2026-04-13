#!/bin/sh

prog=yalmip_kyp_lowpass_Esq_s_test.m
depends="test/yalmip_kyp_lowpass_Esq_s_test.m test_common.m \
delayz.m print_polynomial.m"

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
cat > test_d_10.ok << 'EOF'
h10 = [  0.0015222429,  0.0056117157,  0.0079483383,  0.0024441381, ... 
        -0.0135896375, -0.0303616964, -0.0247709687,  0.0258232433, ... 
         0.1218930222,  0.2299756752,  0.2956218392,  0.2771913332, ... 
         0.1770637218,  0.0445647539, -0.0546123516, -0.0809174883, ... 
        -0.0435116689,  0.0128673306,  0.0438842984,  0.0350849603, ... 
         0.0041984136, -0.0202401296, -0.0227639364, -0.0086322877, ... 
         0.0064031495,  0.0113093080,  0.0065048782, -0.0006480779, ... 
        -0.0042536888, -0.0037733715, -0.0015054268 ];
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_N_3.ok"; fail;
fi

cat > test_d_12.ok << 'EOF'
h12 = [ -0.0024788546, -0.0031425885,  0.0004066941,  0.0084149467, ... 
         0.0140523850,  0.0068138815, -0.0160400665, -0.0392076632, ... 
        -0.0328601683,  0.0268450199,  0.1335051388,  0.2439481909, ... 
         0.3002576302,  0.2678435206,  0.1611544664,  0.0357535419, ... 
        -0.0483580240, -0.0644608423, -0.0302347676,  0.0128294148, ... 
         0.0320531269,  0.0224194457,  0.0010199869, -0.0126250000, ... 
        -0.0117392121, -0.0027790663,  0.0044318585,  0.0055940690, ... 
         0.0029362509,  0.0003506081, -0.0008668155 ];
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_N_5.ok"; fail;
fi

cat > test_d_15.ok << 'EOF'
h15 = [  0.0013068478,  0.0005795883, -0.0025436097, -0.0070309308, ... 
        -0.0078971971, -0.0003519904,  0.0130394809,  0.0200655921, ... 
         0.0073572480, -0.0243980684, -0.0521193056, -0.0407477794, ... 
         0.0305643516,  0.1457747334,  0.2537463818,  0.2979056983, ... 
         0.2537463818,  0.1457747334,  0.0305643516, -0.0407477794, ... 
        -0.0521193056, -0.0243980684,  0.0073572480,  0.0200655921, ... 
         0.0130394809, -0.0003519904, -0.0078971971, -0.0070309308, ... 
        -0.0025436097,  0.0005795883,  0.0013068478 ];
EOF
if [ $? -ne 0 ]; then
    echo "Failed output cat test_N_7.ok"; fail;
fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="yalmip_kyp_lowpass_Esq_s_test"

diff -Bb test_d_10.ok $nstr"_d_10_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d_10.ok"; fail; fi

diff -Bb test_d_12.ok $nstr"_d_12_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d_12.ok"; fail; fi

diff -Bb test_d_15.ok $nstr"_d_15_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d_15.ok"; fail; fi

#
# this much worked
#
pass
