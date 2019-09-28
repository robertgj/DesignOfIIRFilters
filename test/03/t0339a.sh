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
cat > test.d1.ok << 'EOF'
Ud1=3,Vd1=1,Md1=12,Qd1=14,Rd1=1
d1 = [   0.0052599341, ...
        -0.9195230980,   0.1360429822,   0.3303374447, ...
         0.7398694298, ...
         0.7238265937,   0.8084025101,   0.8947029017,   0.9274547502, ... 
         0.9970524800,   1.3257084036, ...
         0.8041180466,   2.3087615722,   2.7487759965,   1.4429287154, ... 
         1.2757134013,   0.3631212845, ...
         0.1260003571,   0.3322965305,   0.4940407260,   0.5647492599, ... 
         0.7859405455,   0.8223009465,   0.9353884104, ...
         1.8444374078,   1.4725162301,   0.1999076910,   1.2347650724, ... 
         0.6565344469,   0.8674663050,   1.1134398371 ]';
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
