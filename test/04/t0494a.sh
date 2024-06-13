#!/bin/sh

prog=iir_sqp_slb_fir_lowpass_test.m

depends="test/iir_sqp_slb_fir_lowpass_test.m \
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
Ud1=2,Vd1=0,Md1=38,Qd1=0,Rd1=1
d1 = [   0.0044374731, ...
        -0.8568011795,   0.7803145429, ...
         0.4723683473,   0.7837807926,   0.7882843785,   0.8081306197, ... 
         0.8384330559,   0.8880563210,   0.9011961476,   0.9159016555, ... 
         0.9231978737,   0.9294654194,   0.9336230619,   0.9400080481, ... 
         0.9471179419,   0.9494072194,   0.9575909522,   0.9775133307, ... 
         0.9893178889,   0.9949569277,   1.5364491604, ...
         1.8437021674,   0.2160197865,   0.4183815754,   0.6404570710, ... 
         1.2011654861,   1.2916378853,   3.0431512225,   2.8843908070, ... 
         2.7292070174,   2.5757203891,   2.4266455207,   2.2793290905, ... 
         0.9668914383,   2.1333398701,   1.9830743782,   1.8388046830, ... 
         1.6838652783,   1.5852534957,   0.3032782520 ]';
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
