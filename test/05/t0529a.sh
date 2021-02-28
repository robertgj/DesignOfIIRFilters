#!/bin/sh

prog=directFIRnonsymmetric_socp_slb_bandpass_hilbert_test.m

depends="directFIRnonsymmetric_socp_slb_bandpass_hilbert_test.m \
test_common.m print_polynomial.m local_max.m \
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
h = [   0.0100345242,  -0.0318165138,  -0.0169400819,   0.0008544093, ... 
       -0.0175552382,  -0.0715265564,  -0.0720440209,   0.0536931025, ... 
        0.2120267019,   0.2099930800,  -0.0019031387,  -0.2277762440, ... 
       -0.2433647499,  -0.0652431273,   0.0936268118,   0.0988178920, ... 
        0.0254884815,   0.0023420826,   0.0348815879,   0.0422273785, ... 
        0.0002487239,  -0.0335010400,  -0.0246153897,  -0.0040319147, ... 
       -0.0050187889,  -0.0161129636,  -0.0110357299,   0.0052289033, ... 
        0.0136623799,   0.0051973394,   0.0025393227 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.m \
     directFIRnonsymmetric_socp_slb_bandpass_hilbert_test_h_coef.m

if [ $? -ne 0 ]; then echo "Failed diff -Bb" test_h_coef.m; fail; fi

#
# this much worked
#
pass
