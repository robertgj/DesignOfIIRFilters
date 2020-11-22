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
d1 = [   0.0005349307, ...
         0.4396985628,   0.8273229776,   0.8337456659,   0.8357956681, ... 
         0.8413492801,   0.8534071162,   0.8651147149,   0.8929382032, ... 
         0.9930043757,   0.9932216479,   0.9941127005,   0.9942149953, ... 
         0.9953435095,   0.9967666525,   0.9978968456,   0.9983675151, ... 
         1.0000694884,   1.0019249676,   1.0039625179,   1.0064741263, ... 
         1.0088629604,   1.0129514396,   1.0168521237,   1.0250636751, ... 
         1.0532632651,   1.2287585442,   1.2420477029,   1.2484609509, ... 
         1.4053524283,   1.4388765057, ...
         0.0039751975,   0.0751721233,   0.2259376537,   0.3769656642, ... 
         0.5231038485,   0.6652736425,   0.8090533281,   0.9523167241, ... 
         1.4143690109,   1.5078944113,   1.6061841623,   1.3309040950, ... 
         1.7070209466,   1.8095208927,   1.2709360976,   1.9131526475, ... 
         2.0177580671,   2.1232779789,   2.2298226695,   2.3376548124, ... 
         2.4473128131,   2.5594622866,   2.6758981045,   2.8021438685, ... 
         2.9464240227,   3.1415897067,   3.1415926383,   3.1415926323, ... 
         0.6633542776,   0.2188940879 ]';
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
