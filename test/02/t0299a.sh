#!/bin/sh

prog=directFIRsymmetric_slb_bandpass_test.m
depends="test_common.m \
directFIRsymmetric_slb_bandpass_test.m \
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
cat > test_hM1.ok << 'EOF'
hM1 = [  -0.0058181010,   0.0017787857,  -0.0047084625,  -0.0143846688, ... 
         -0.0077550125,   0.0219788564,   0.0432578789,   0.0247317110, ... 
         -0.0077853817,  -0.0010276677,   0.0304650309,   0.0009925325, ... 
         -0.1110651112,  -0.1806101683,  -0.0725659905,   0.1536437055, ... 
          0.2719559562 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1.ok"; fail; fi

cat > test_hM2.ok << 'EOF'
hM2 = [  -0.0044085406,  -0.0001985314,  -0.0035263346,   0.0001582304, ... 
          0.0085606792,   0.0190598655,   0.0468750000,   0.0101866570, ... 
         -0.0078125000,   0.0067368888,   0.0312500000,  -0.0258705081, ... 
         -0.1245935961,  -0.1694092996,  -0.0517101158,   0.1593366974, ... 
          0.2669649483 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM2.ok"; fail; fi

#
# run and see if the results match. Suppress m-file warnings
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog >test.out 
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM1.ok directFIRsymmetric_slb_bandpass_test_hM1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1.ok"; fail; fi

diff -Bb test_hM2.ok directFIRsymmetric_slb_bandpass_test_hM2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM2.ok"; fail; fi

#
# this much worked
#
pass

