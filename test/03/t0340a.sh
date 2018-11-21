#!/bin/sh

prog=fir_socp_slb_lowpass_test.m

depends="fir_socp_slb_lowpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m Aerror.m Perror.m Terror.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
local_max.m local_peak.m tf2x.m zp2x.m x2tf.m xConstraints.m \
qroots.m qzsolve.oct SeDuMi_1_3/"

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
cat > test.d1.ok << 'EOF'
Ud1=2,Vd1=0,Md1=28,Qd1=0,Rd1=1
d1 = [   0.0008814098, ...
       -31.2583882374,  -0.9209082027, ...
         0.7282488159,   0.7386762849,   0.7747979518,   0.8604883761, ... 
         0.8657640769,   0.8771825477,   0.8788958164,   0.8810680514, ... 
         0.8841229804,   0.8913872100,   0.9170061280,   0.9602479571, ... 
         0.9931842272,   1.3205755170, ...
         0.8123431260,   0.1872188103,   0.4522311055,   1.9282611076, ... 
         2.3053316436,   2.9219591147,   1.7671728344,   2.5236864774, ... 
         2.1304788577,   2.7175986436,   1.5831435988,   1.4036410300, ... 
         1.2756663260,   0.3709282130 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.d1.ok fir_socp_slb_lowpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
