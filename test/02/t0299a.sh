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
hM1 = [  -0.0004538174,  -0.0114029873,  -0.0194431345,  -0.0069796479, ... 
          0.0215771882,   0.0348545408,   0.0158541332,  -0.0033225166, ... 
          0.0154055974,   0.0414424100,  -0.0021970758,  -0.1162784301, ... 
         -0.1760013118,  -0.0669604509,   0.1451751014,   0.2540400868 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1.ok"; fail; fi

cat > test_hM2.ok << 'EOF'
hM2 = [  -0.0003775024,  -0.0070888855,  -0.0134385735,  -0.0045276788, ... 
          0.0192526548,   0.0317949864,   0.0156250000,  -0.0080902215, ... 
          0.0156250000,   0.0411747057,  -0.0000000000,  -0.1131235824, ... 
         -0.1754905581,  -0.0687003841,   0.1450986063,   0.2571221202 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM2.ok"; fail; fi

#
# run and see if the results match. Suppress m-file warnings
#
echo "Running octave-cli -q " $prog
echo "warning('off');" >> .octaverc

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

