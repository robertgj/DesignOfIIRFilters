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
Ud1=0,Vd1=0,Md1=60,Qd1=0,Rd1=1
d1 = [   0.0005324559, ...
         0.4397616766,   0.8273378250,   0.8337259742,   0.8357796520, ... 
         0.8413596063,   0.8534180769,   0.8651179066,   0.8929405815, ... 
         0.9929876825,   0.9932067147,   0.9940588880,   0.9942160251, ... 
         0.9952692283,   0.9966996456,   0.9978939723,   0.9982000478, ... 
         1.0001639773,   1.0017963087,   1.0038536454,   1.0062443170, ... 
         1.0095443342,   1.0124051427,   1.0174757734,   1.0229432596, ... 
         1.0487497079,   1.1962531891,   1.2574105079,   1.2773085708, ... 
         1.4055079108,   1.4391638242, ...
         0.0000818472,   0.0751903261,   0.2259629977,   0.3769608154, ... 
         0.5230983818,   0.6652825081,   0.8090692055,   0.9523254793, ... 
         1.4143884367,   1.5079418104,   1.6062519515,   1.3308898599, ... 
         1.7070993964,   1.8095646589,   1.2709278169,   1.9131942655, ... 
         2.0177484818,   2.1233526394,   2.2300350925,   2.3378971001, ... 
         2.4473058062,   2.5592274347,   2.6758130293,   2.8012576017, ... 
         2.9468981260,   3.1413019855,   3.1415853689,   3.1415925370, ... 
         0.6633283451,   0.2188657165 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.d1.ok iir_sqp_slb_fir_lowpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
