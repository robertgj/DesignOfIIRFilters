#!/bin/sh

prog=iir_sqp_slb_fir_lowpass_test.m

depends="iir_sqp_slb_fir_lowpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_sqp_mmse.m iir_slb_set_empty_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
armijo_kim.m cl2bp.m fixResultNaN.m iirA.m iirE.m iirT.m iirP.m invSVD.m \
local_max.m showResponseBands.m showResponse.m \
showResponsePassBands.m showZPplot.m sqp_bfgs.m tf2x.m zp2x.m updateWchol.m \
updateWbfgs.m x2tf.m xConstraints.m qroots.m qzsolve.oct"

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
cat > test.d1.ok << 'EOF'
Ud1=2,Vd1=0,Md1=58,Qd1=0,Rd1=1
d1 = [   0.0001397686, ...
       -10.0000000000,   0.8410551527, ...
         0.8416186146,   0.8429225220,   0.8438400127,   0.8471015904, ... 
         0.8544156713,   0.8640911262,   0.8919021564,   0.9267400382, ... 
         0.9584817964,   0.9629550365,   0.9637428354,   0.9653320754, ... 
         0.9688767655,   0.9714067940,   0.9746760677,   0.9754510500, ... 
         0.9764333854,   0.9768241681,   0.9771821221,   0.9773687381, ... 
         0.9774957831,   0.9776098914,   0.9777082638,   0.9779405081, ... 
         0.9787619846,   0.9820624179,   0.9929389612,   1.4228316088, ... 
         1.4637861971, ...
         0.1386293975,   0.2736781343,   0.4117986201,   0.5488722875, ... 
         0.6817592021,   0.8171389046,   0.9553579983,   3.1393146713, ... 
         3.1414485928,   3.1414932794,   3.1415290401,   2.7257870163, ... 
         3.1414668022,   2.5972081873,   2.4774990863,   2.3626833957, ... 
         2.2509919238,   2.1410356335,   2.0325881927,   1.9252793474, ... 
         1.8191331511,   1.7141995001,   1.6108724738,   1.5100974388, ... 
         1.4141206921,   1.3288846982,   1.2685029512,   0.6706268269, ... 
         0.2211990004 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.d1.ok iir_sqp_slb_fir_lowpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
