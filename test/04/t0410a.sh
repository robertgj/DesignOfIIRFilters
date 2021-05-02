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
hM1 = [   0.0057429552,   0.0446936351,  -0.0153998324,  -0.0693183665, ... 
         -0.0045099006,   0.1230534484,   0.0942725241,  -0.4963204752 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1.ok"; fail; fi

cat > test_hM2.ok << 'EOF'
hM2 = [  -0.0104589390,   0.0031738998,   0.0291468051,  -0.0144604946, ... 
         -0.0629162600,   0.0550052923,   0.1596092306,  -0.4239235327 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM2.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM1.ok directFIRhilbert_bandpass_slb_test_hM1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1.ok"; fail; fi

diff -Bb test_hM2.ok directFIRhilbert_bandpass_slb_test_hM2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM2.ok"; fail; fi

#
# this much worked
#
pass

