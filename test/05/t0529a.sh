#!/bin/sh

prog=directFIRnonsymmetric_socp_slb_bandpass_hilbert_test.m

depends="test/directFIRnonsymmetric_socp_slb_bandpass_hilbert_test.m test_common.m \
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
directFIRnonsymmetric_socp_mmse.m \
print_polynomial.m local_max.m lagrange_interp.m xfr2tf.m qroots.oct \
"

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
h = [   0.0039453635,  -0.0136185958,  -0.0096497272,   0.0001549866, ... 
       -0.0133814752,  -0.0560385681,  -0.0585483181,   0.0480599739, ... 
        0.1963028500,   0.2041356256,  -0.0017685707,  -0.2445554505, ... 
       -0.2758389897,  -0.0777040606,   0.1187650188,   0.1318652324, ... 
        0.0346976632,   0.0026743283,   0.0569172027,   0.0734009662, ... 
       -0.0005984894,  -0.0716781090,  -0.0582539053,  -0.0083046136, ... 
       -0.0050612333,  -0.0360015759,  -0.0304401251,   0.0173056157, ... 
        0.0448046238,   0.0248979055,   0.0003394306,   0.0066495506, ... 
        0.0204766062,   0.0086889143,  -0.0166939589,  -0.0228156877, ... 
       -0.0084925153,   0.0008379466,  -0.0038137492,  -0.0071196862, ... 
        0.0002353302,   0.0083315815,   0.0072991196,   0.0016228723, ... 
       -0.0003629489,   0.0009605138,   0.0010239773,  -0.0008107291, ... 
       -0.0017063160,  -0.0009387865,  -0.0001970149 ]';
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
