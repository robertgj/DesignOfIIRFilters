#!/bin/sh

prog=directFIRnonsymmetric_socp_slb_bandpass_hilbert_test.m

depends="directFIRnonsymmetric_socp_slb_bandpass_hilbert_test.m test_common.m \
print_polynomial.m local_max.m lagrange_interp.m xfr2tf.m \
hofstetterFIRsymmetric.m \
directFIRnonsymmetricAsq.m \
directFIRnonsymmetricEsq.m \
directFIRnonsymmetricP.m \
directFIRnonsymmetricT.m \
directFIRnonsymmetric_slb.m \
directFIRnonsymmetric_slb_constraints_are_empty.m \
directFIRnonsymmetric_slb_exchange_constraints.m \
directFIRnonsymmetric_slb_set_empty_constraints.m \
directFIRnonsymmetric_slb_show_constraints.m \
directFIRnonsymmetric_slb_update_constraints.m \
directFIRnonsymmetric_socp_mmse.m"

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
cat > test_h_coef.m << 'EOF'
h = [   0.0012253973,  -0.0172382195,  -0.0105171097,   0.0023909624, ... 
       -0.0097302492,  -0.0526861349,  -0.0547612659,   0.0526186224, ... 
        0.1983569709,   0.2011579274,  -0.0067389821,  -0.2473219034, ... 
       -0.2784222454,  -0.0852582002,   0.1091054604,   0.1298666659, ... 
        0.0429413662,   0.0115586234,   0.0592531487,   0.0755791708, ... 
        0.0100845156,  -0.0587927908,  -0.0575883450,  -0.0204505611, ... 
       -0.0161599301,  -0.0389281927,  -0.0345354274,   0.0049410517, ... 
        0.0342672213,   0.0292534742,   0.0145494971,   0.0150318234, ... 
        0.0207169869,   0.0129819350,  -0.0038888482,  -0.0140265800, ... 
       -0.0141745335,  -0.0117530549,  -0.0101548092,  -0.0080085107, ... 
       -0.0049008333,  -0.0017291819,   0.0027315494,   0.0077641460, ... 
        0.0090150307,   0.0054095422,   0.0021376393,   0.0028396294, ... 
        0.0035731980,   0.0001936416,  -0.0045336113,  -0.0050698387, ... 
       -0.0021671670,  -0.0006612615,  -0.0016384392,  -0.0018245697, ... 
        0.0001902054,   0.0019424740,   0.0017172204,   0.0004895388, ... 
        0.0003415923 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.m \
     directFIRnonsymmetric_socp_slb_bandpass_hilbert_test_h_coef.m

if [ $? -ne 0 ]; then echo "Failed diff -Bb" test_h_coef.m; fail; fi

#
# this much worked
#
pass
