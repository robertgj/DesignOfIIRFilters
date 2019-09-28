#!/bin/sh

prog=johansson_cascade_allpass_bandstop_test.m
depends="johansson_cascade_allpass_bandstop_test.m test_common.m \
directFIRsymmetric_socp_mmse.m \
directFIRsymmetric_slb.m \
directFIRsymmetric_slb_update_constraints.m \
directFIRsymmetric_slb_exchange_constraints.m \
directFIRsymmetric_slb_set_empty_constraints.m \
directFIRsymmetric_slb_constraints_are_empty.m \
directFIRsymmetric_slb_show_constraints.m \
directFIRsymmetricA.m \
directFIRsymmetricEsq.m \
johansson_cascade_allpassAzp.m \
phi2p.m tfp2g.m tf2pa.m local_max.m print_polynomial.m qroots.m \
qzsolve.oct spectralfactor.oct SeDuMi_1_3/"

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
cat > test_f1_coef.ok << 'EOF'
f1 = [  -0.0314881200,  -0.0000085599,   0.2814857078,   0.5000169443, ... 
         0.2814857078,  -0.0000085599,  -0.0314881200 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_f1_coef.ok"; fail; fi

cat > test_bsA0_coef.ok << 'EOF'
bsA0 = [   1.0000000000,  -0.5650807120,   1.6504676367,  -0.4790677580, ... 
           0.7284677906 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_bsA0_coef.ok"; fail; fi

cat > test_bsA1_coef.ok << 'EOF'
bsA1 = [   1.0000000000,  -0.2594846657,   0.6383217013 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_bsA1_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running octave-cli -q " $prog

#octave-cli -q $prog
octave-cli $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="johansson_cascade_allpass_bandstop_test"

diff -Bb test_f1_coef.ok $nstr"_f1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_f1_coef.ok"; fail; fi

diff -Bb test_bsA0_coef.ok $nstr"_bsA0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_bsA0_coef.ok"; fail; fi

diff -Bb test_bsA1_coef.ok $nstr"_bsA1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_bsA1_coef.ok"; fail; fi

#
# this much worked
#
pass

