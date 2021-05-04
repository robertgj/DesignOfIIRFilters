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
h = [   0.0037647543,  -0.0138972761,  -0.0098459210,   0.0003845520, ... 
       -0.0128495798,  -0.0556914183,  -0.0582631451,   0.0477851400, ... 
        0.1952893092,   0.2033521490,  -0.0010539910,  -0.2426462080, ... 
       -0.2755292687,  -0.0798333251,   0.1170739965,   0.1330726047, ... 
        0.0371922873,   0.0025191455,   0.0544422312,   0.0726448429, ... 
        0.0015504832,  -0.0699469156,  -0.0597355301,  -0.0104282171, ... 
       -0.0044029851,  -0.0340324905,  -0.0306767101,   0.0150223161, ... 
        0.0443724586,   0.0273226903,   0.0017875558,   0.0049856256, ... 
        0.0182734342,   0.0092281285,  -0.0146037050,  -0.0226821514, ... 
       -0.0100581155,   0.0003143913,  -0.0024567413,  -0.0061431909, ... 
       -0.0008039076,   0.0070643417,   0.0073818629,   0.0024174642, ... 
       -0.0001641188,   0.0006044200,   0.0012272615,  -0.0003587288, ... 
       -0.0016512946,  -0.0012343809,  -0.0004417564 ]';
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
