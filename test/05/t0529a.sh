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
h = [   0.0037003075,  -0.0139635415,  -0.0097986860,   0.0004987320, ... 
       -0.0127283354,  -0.0557605701,  -0.0584796973,   0.0477973339, ... 
        0.1952966872,   0.2034955883,  -0.0008344679,  -0.2425379834, ... 
       -0.2754363218,  -0.0802564440,   0.1165697442,   0.1330561349, ... 
        0.0374750865,   0.0029193289,   0.0544251360,   0.0725605117, ... 
        0.0019391604,  -0.0697692788,  -0.0597866745,  -0.0107056723, ... 
       -0.0045529764,  -0.0337637105,  -0.0309544802,   0.0146400473, ... 
        0.0442669342,   0.0275176368,   0.0022109282,   0.0049292424, ... 
        0.0182798712,   0.0095740523,  -0.0143976438,  -0.0226426256, ... 
       -0.0103941261,   0.0000634928,  -0.0023552286,  -0.0062380139, ... 
       -0.0008297617,   0.0070334651,   0.0074332816,   0.0026444888, ... 
       -0.0001809059,   0.0006265174,   0.0012401491,  -0.0004133112, ... 
       -0.0016560765,  -0.0012725994,  -0.0004847494 ]';
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
