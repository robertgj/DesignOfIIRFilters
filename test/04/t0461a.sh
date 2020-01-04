#!/bin/sh

prog=selesnickFIRsymmetric_lowpass_test.m

depends="selesnickFIRsymmetric_lowpass_test.m test_common.m \
selesnickFIRsymmetric_lowpass.m selesnickFIRsymmetric_lowpass_exchange.m \
lagrange_interp.m print_polynomial.m local_max.m directFIRsymmetricA.m"

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
cat > test_hM.ok << 'EOF'
hM = [  0.000000074414,  0.000000247840,  0.000000351583,  0.000000023517, ... 
       -0.000000838774, -0.000001520928, -0.000000771303,  0.000001669853, ... 
        0.000003690058,  0.000002010482, -0.000003766009, -0.000008366651, ... 
       -0.000004534986,  0.000007819990,  0.000016917948,  0.000008487581, ... 
       -0.000015802731, -0.000031828137, -0.000014058744,  0.000030581061, ... 
        0.000056148224,  0.000020592917, -0.000056762431, -0.000093752611, ... 
       -0.000026260485,  0.000100943479,  0.000148894472,  0.000027133364, ... 
       -0.000172212866, -0.000225732082, -0.000016290190,  0.000282318984, ... 
        0.000327372928, -0.000017303650, -0.000445640626, -0.000454610610, ... 
        0.000089876587,  0.000678715154,  0.000604260164, -0.000223853521, ... 
       -0.000999310741, -0.000767210566,  0.000448606870,  0.001424975612, ... 
        0.000926266817, -0.000800887663, -0.001971128545, -0.001053910279, ... 
        0.001324921530,  0.002648814032,  0.001110036714, -0.002072335930, ... 
       -0.003462348208, -0.001039598987,  0.003102344586,  0.004407145024, ... 
        0.000769761532, -0.004483067012, -0.005468053685, -0.000205547864, ... 
        0.006295660485,  0.006618526942, -0.000778331541, -0.008644568580, ... 
       -0.007820879165,  0.002354664640,  0.011680952725,  0.009027779333, ... 
       -0.004782357340, -0.015656350548, -0.010184972975,  0.008499773914, ... 
        0.021054257386,  0.011235056826, -0.014377849725, -0.028960879894, ... 
       -0.012121968055,  0.024551733154,  0.042388309736,  0.012795723748, ... 
       -0.046257397478, -0.073542501693, -0.013216876844,  0.130212090154, ... 
        0.281849461192,  0.346693494205 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM.ok selesnickFIRsymmetric_lowpass_test_hM_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM.ok"; fail; fi

#
# this much worked
#
pass

