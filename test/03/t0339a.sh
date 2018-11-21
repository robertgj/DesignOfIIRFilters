#!/bin/sh

prog=iir_socp_slb_lowpass_test.m

depends="iir_socp_slb_lowpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m Aerror.m Perror.m Terror.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
local_max.m local_peak.m tf2x.m zp2x.m x2tf.m xConstraints.m WISEJ_ND.m \
tf2Abcd.m qroots.m qzsolve.oct SeDuMi_1_3/"
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
Ud1=3,Vd1=1,Md1=12,Qd1=14,Rd1=1
d1 = [   0.0047782971, ...
        -0.9176752996,  -0.0494802706,   0.5113416923, ...
         0.7248591378, ...
         0.8466618026,   0.8835778262,   0.9504282625,   0.9712734048, ... 
         1.0007879362,   1.3720415007, ...
         2.2660442840,   2.7221759917,   0.9971074882,   1.4648200266, ... 
         1.2769944520,   0.3580341166, ...
         0.0971209687,   0.3185122897,   0.4918799235,   0.5504955556, ... 
         0.7448260204,   0.9131629353,   0.9476321059, ...
         1.5791547913,   1.4722151619,   0.3284860699,   1.2098273776, ... 
         0.7301887478,   1.0504051731,   1.0096357685 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.d1.ok iir_socp_slb_lowpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
