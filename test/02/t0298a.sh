#!/bin/sh

prog=directFIRsymmetric_slb_lowpass_test.m
depends="test/directFIRsymmetric_slb_lowpass_test.m \
test_common.m \
directFIRsymmetric_slb_exchange_constraints.m \
directFIRsymmetric_slb_update_constraints.m \
directFIRsymmetric_slb_set_empty_constraints.m \
directFIRsymmetric_slb_show_constraints.m \
directFIRsymmetric_slb_constraints_are_empty.m \
directFIRsymmetric_slb.m \
directFIRsymmetric_mmsePW.m \
directFIRsymmetricEsqPW.m \
directFIRsymmetricA.m \
print_polynomial.m local_max.m"

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
cat > test_hM1.ok << 'EOF'
hM1 = [   0.0015415562,   0.0021622752,  -0.0004724047,  -0.0057312301, ... 
         -0.0081256352,  -0.0016428074,   0.0123722369,   0.0218047186, ... 
          0.0115474186,  -0.0202014306,  -0.0510078994,  -0.0433674249, ... 
          0.0270095515,   0.1450930022,   0.2573031209,   0.3034299040 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1.ok"; fail; fi
cat > test_hM2.ok << 'EOF'
hM2 = [   0.0014638109,   0.0018611877,  -0.0007735992,  -0.0055948268, ... 
         -0.0074236881,  -0.0019531250,   0.0125673104,   0.0211037408, ... 
          0.0104390629,  -0.0209433012,  -0.0507579161,  -0.0420798172, ... 
          0.0278874991,   0.1450166801,   0.2561668064,   0.3018056098 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM2.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM1.ok directFIRsymmetric_slb_lowpass_test_hM1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1.ok"; fail; fi

diff -Bb test_hM2.ok directFIRsymmetric_slb_lowpass_test_hM2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM2.ok"; fail; fi

#
# this much worked
#
pass

