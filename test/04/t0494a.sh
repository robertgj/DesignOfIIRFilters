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
d1 = [   0.0004531957, ...
         0.4403113995,   0.8271077886,   0.8334146877,   0.8355404619, ... 
         0.8411361516,   0.8531772327,   0.8649067274,   0.8927701920, ... 
         0.9925489420,   0.9925844708,   0.9932556485,   0.9939596686, ... 
         0.9942293187,   0.9953119880,   0.9965060120,   0.9977530722, ... 
         0.9978204352,   0.9990283772,   1.0003429242,   1.0016325478, ... 
         1.0029687062,   1.0042134217,   1.0054343282,   1.0066078929, ... 
         1.0074351873,   1.0081106780,   1.0083754638,   1.4074726750, ... 
         1.4423770179,   2.2522742703, ...
         0.0000977205,   0.0752234341,   0.2260318564,   0.3770150813, ... 
         0.5231635789,   0.6653553173,   0.8091165726,   0.9524118229, ... 
         1.4140534678,   1.5073908635,   1.6054152160,   1.3307322999, ... 
         1.7059822825,   1.8080368967,   1.9111690460,   2.0150915680, ... 
         1.2709209268,   2.1195496971,   2.2247070895,   2.3303150829, ... 
         2.4365171754,   2.5433440628,   2.6507844871,   2.7588400661, ... 
         2.8674895183,   2.9765958577,   3.0853531147,   0.6640020950, ... 
         0.2190497181,   3.1415631937 ]';
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
