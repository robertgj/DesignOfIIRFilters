#!/bin/sh

prog=zolotarev_vlcek_unbehauen_test.m

depends="test/zolotarev_vlcek_unbehauen_test.m zolotarev_vlcek_unbehauen.m \
test_common.m print_polynomial.m zolotarev_chen_parks.m \
elliptic_F.m elliptic_E.m jacobi_Eta.m jacobi_Theta.m jacobi_Zeta.m \
jacobi_theta1.m jacobi_theta1k.m jacobi_theta2.m jacobi_theta2k.m \
jacobi_theta3.m jacobi_theta3k.m jacobi_theta4.m jacobi_theta4k.m \
jacobi_theta2p.m jacobi_theta4p.m jacobi_theta4kp.m \
carlson_RJ.m carlson_RD.m carlson_RC.m carlson_RF.m \
chebyshevP.m chebyshevT.m chebyshevP_backward_recurrence.m \
chebyshevT_backward_recurrence.m chebyshevT_expand.m qroots.oct \
"

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
h_5_15 = [  -0.0531541684,  -0.0187425987,  -0.0029739578,   0.0184629608, ... 
             0.0320251989,   0.0269417021,   0.0032905111,  -0.0262222295, ... 
            -0.0430236735,  -0.0344479981,  -0.0029979528,   0.0335763755, ... 
             0.0524256541,   0.0401078216,   0.0020985347,  -0.0394119519, ... 
            -0.0587615930,  -0.0430273457,  -0.0007539335,   0.0427632649, ... 
             0.0609976102,   0.0427632649,  -0.0007539335,  -0.0430273457, ... 
            -0.0587615930,  -0.0394119519,   0.0020985347,   0.0401078216, ... 
             0.0524256541,   0.0335763755,  -0.0029979528,  -0.0344479981, ... 
            -0.0430236735,  -0.0262222295,   0.0032905111,   0.0269417021, ... 
             0.0320251989,   0.0184629608,  -0.0029739578,  -0.0187425987, ... 
            -0.0531541684 ];
EOF
if [ $? -ne 0 ]; then echo "Failed cat test_h_5_15.ok"; fail; fi

cat > test_fir.ok << 'EOF'
h_6_17 = [   0.0295797662,   0.0123578798,   0.0011255068,  -0.0142207618, ... 
            -0.0229948939,  -0.0169353965,   0.0027813101,   0.0244417779, ... 
             0.0326289454,   0.0191172985,  -0.0098456126,  -0.0359475478, ... 
            -0.0404719137,  -0.0177401179,   0.0193576127,   0.0466303771, ... 
             0.0446158675,   0.0125842442,  -0.0296518673,  -0.0542174707, ... 
            -0.0439450649,  -0.0045524365,   0.0385342685,   0.1003921567, ... 
             0.0385342685,  -0.0045524365,  -0.0439450649,  -0.0542174707, ... 
            -0.0296518673,   0.0125842442,   0.0446158675,   0.0466303771, ... 
             0.0193576127,  -0.0177401179,  -0.0404719137,  -0.0359475478, ... 
            -0.0098456126,   0.0191172985,   0.0326289454,   0.0244417779, ... 
             0.0027813101,  -0.0169353965,  -0.0229948939,  -0.0142207618, ... 
             0.0011255068,   0.0123578798,   0.0295797662 ];
EOF
if [ $? -ne 0 ]; then echo "Failed cat test_fir.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
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

