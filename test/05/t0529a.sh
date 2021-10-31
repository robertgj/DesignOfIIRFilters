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
h = [   0.0035324444,  -0.0139319228,  -0.0094095914,   0.0005149648, ... 
       -0.0130492773,  -0.0559859751,  -0.0581356581,   0.0485629272, ... 
        0.1956228757,   0.2030320169,  -0.0010246770,  -0.2422353720, ... 
       -0.2755442515,  -0.0813542493,   0.1152702456,   0.1330345501, ... 
        0.0381148192,   0.0029135455,   0.0541067766,   0.0733941728, ... 
        0.0039369788,  -0.0684442066,  -0.0606532570,  -0.0121474951, ... 
       -0.0046318830,  -0.0335045767,  -0.0317864266,   0.0128213468, ... 
        0.0437733231,   0.0287316552,   0.0031810564,   0.0050190016, ... 
        0.0184321224,   0.0105749516,  -0.0133427761,  -0.0228629870, ... 
       -0.0114642320,  -0.0003250787,  -0.0023759376,  -0.0066059635, ... 
       -0.0017847168,   0.0064154097,   0.0079254383,   0.0032096424, ... 
        0.0000385525,   0.0007584860,   0.0014249791,  -0.0001012961, ... 
       -0.0013577718,  -0.0015152917,  -0.0007674169 ]';
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
