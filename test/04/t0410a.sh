#!/bin/sh

prog=directFIRhilbert_bandpass_slb_test.m
depends="test_common.m \
directFIRhilbert_bandpass_slb_test.m \
directFIRhilbert_slb_exchange_constraints.m \
directFIRhilbert_slb_update_constraints.m \
directFIRhilbert_slb_set_empty_constraints.m \
directFIRhilbert_slb_show_constraints.m \
directFIRhilbert_slb_constraints_are_empty.m \
directFIRhilbert_slb.m \
directFIRhilbert_mmsePW.m \
directFIRhilbertA.m \
directFIRhilbertEsqPW.m \
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
hM1 = [   0.4965297597,  -0.0939380428,  -0.1230528005,   0.0042207298, ... 
          0.0692376578,   0.0157255882,  -0.0444950646,  -0.0063642097 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1.ok"; fail; fi

cat > test_hM2.ok << 'EOF'
hM2 = [   0.4239235327,  -0.1596092306,  -0.0550052923,   0.0629162600, ... 
          0.0144604946,  -0.0291468051,  -0.0031738998,   0.0104589390 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM2.ok"; fail; fi

#
# run and see if the results match. Suppress m-file warnings
#
echo "Running octave-cli -q " $prog
echo "warning('off');" >> .octaverc

octave-cli -q $prog >test.out 
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM1.ok directFIRhilbert_bandpass_slb_test_hM1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1.ok"; fail; fi

diff -Bb test_hM2.ok directFIRhilbert_bandpass_slb_test_hM2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM2.ok"; fail; fi

#
# this much worked
#
pass

