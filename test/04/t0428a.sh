#!/bin/sh

prog=zolotarev_vlcek_unbehauen_test.m

depends="zolotarev_vlcek_unbehauen_test.m zolotarev_vlcek_unbehauen.m \
test_common.m print_polynomial.m zolotarev_chen_parks.m \
elliptic_F.m elliptic_E.m jacobi_Eta.m jacobi_Theta.m jacobi_Zeta.m \
jacobi_theta1.m jacobi_theta1k.m jacobi_theta2.m jacobi_theta2k.m \
jacobi_theta3.m jacobi_theta3k.m jacobi_theta4.m jacobi_theta4k.m \
carlson_RJ.m carlson_RD.m carlson_RC.m carlson_RF.m"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
echo $here
for file in $depends;do \
  cp -R src/$file $tmp; \
  if [ $? -ne 0 ]; then echo "Failed cp "$file; fail; fi \
done
cd $tmp
if [ $? -ne 0 ]; then echo "Failed cd"; fail; fi

#
# the output should look like this
#
cat > test_h_5_9.ok << 'EOF'
h_5_9 = [  -0.0706112766,  -0.0186664318,   0.0245626380,   0.0473489619, ... 
            0.0145183505,  -0.0435459441,  -0.0574964296,  -0.0024707373, ... 
            0.0628159098,   0.0592760711,  -0.0155840308,  -0.0772272514, ... 
           -0.0512947508,   0.0352853317,   0.0825710640,   0.0352853317, ... 
           -0.0512947508,  -0.0772272514,  -0.0155840308,   0.0592760711, ... 
            0.0628159098,  -0.0024707373,  -0.0574964296,  -0.0435459441, ... 
            0.0145183505,   0.0473489619,   0.0245626380,  -0.0186664318, ... 
           -0.0706112766 ];
EOF
if [ $? -ne 0 ]; then echo "Failed cat test_h_5_9.ok"; fail; fi

cat > test_h_5_15.ok << 'EOF'
h_5_15 = [  -0.0531541670,  -0.0187425982,  -0.0029739577,   0.0184629603, ... 
             0.0320251981,   0.0269417014,   0.0032905110,  -0.0262222288, ... 
            -0.0430236724,  -0.0344479972,  -0.0029979527,   0.0335763747, ... 
             0.0524256527,   0.0401078205,   0.0020985347,  -0.0394119509, ... 
            -0.0587615915,  -0.0430273447,  -0.0007539338,   0.0427632634, ... 
             0.0609976080,   0.0427632634,  -0.0007539338,  -0.0430273447, ... 
            -0.0587615915,  -0.0394119509,   0.0020985347,   0.0401078205, ... 
             0.0524256527,   0.0335763747,  -0.0029979527,  -0.0344479972, ... 
            -0.0430236724,  -0.0262222288,   0.0032905110,   0.0269417014, ... 
             0.0320251981,   0.0184629603,  -0.0029739577,  -0.0187425982, ... 
            -0.0531541670 ];
EOF
if [ $? -ne 0 ]; then echo "Failed cat test_h_5_15.ok"; fail; fi

cat > test_fir.ok << 'EOF'
h_5_16 = [  -0.0511139634,  -0.0181699969,  -0.0047689715,   0.0146112277, ... 
             0.0290498931,   0.0286295890,   0.0109847724,  -0.0159431005, ... 
            -0.0373125072,  -0.0396282827,  -0.0192090819,   0.0144323779, ... 
             0.0429580305,   0.0493776137,   0.0282868726,  -0.0100731831, ... 
            -0.0448304532,  -0.0561035401,  -0.0366163118,   0.0036149461, ... 
             0.0425481166,   0.0585046989,   0.0425481166,   0.0036149461, ... 
            -0.0366163118,  -0.0561035401,  -0.0448304532,  -0.0100731831, ... 
             0.0282868726,   0.0493776137,   0.0429580305,   0.0144323779, ... 
            -0.0192090819,  -0.0396282827,  -0.0373125072,  -0.0159431005, ... 
             0.0109847724,   0.0286295890,   0.0290498931,   0.0146112277, ... 
            -0.0047689715,  -0.0181699969,  -0.0511139634 ];
EOF
if [ $? -ne 0 ]; then echo "Failed cat test_fir.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_5_9.ok zolotarev_vlcek_unbehauen_test_h_5_9_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_5_9.ok"; fail; fi

diff -Bb test_h_5_15.ok zolotarev_vlcek_unbehauen_test_h_5_15_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_5_15.ok"; fail; fi

diff -Bb test_fir.ok zolotarev_vlcek_unbehauen_test_fir_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_fir.ok"; fail; fi

#
# this much worked
#
pass

