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
Ud1=2,Vd1=0,Md1=58,Qd1=0,Rd1=1
d1 = [   0.0004579385, ...
         0.7603830040,   0.7603830663, ...
         0.5585377733,   0.8114699058,   0.8222006540,   0.8336810200, ... 
         0.8496269806,   0.8629910458,   0.8919107447,   0.9931229542, ... 
         0.9932875631,   0.9940434149,   0.9943475578,   0.9951116635, ... 
         0.9962776910,   0.9975229606,   0.9979488342,   0.9988151852, ... 
         1.0001531619,   1.0014901570,   1.0028960477,   1.0041805010, ... 
         1.0055023770,   1.0065250291,   1.0079882305,   1.0089093737, ... 
         1.0093270981,   1.0094473637,   1.4062880022,   1.4396184664, ... 
         2.2571656443, ...
         0.0002689134,   0.2047120224,   0.3665415203,   0.5177073437, ... 
         0.6630238879,   0.8085814900,   0.9528216349,   1.4144291985, ... 
         1.5079292082,   1.6060305247,   1.3308594539,   1.7066237114, ... 
         1.8087075474,   1.9118343019,   1.2706876181,   2.0156791894, ... 
         2.1201442484,   2.2251570940,   2.3308336605,   2.4370235308, ... 
         2.5437559130,   2.6511268417,   2.7591422768,   2.8676444767, ... 
         2.9766355666,   3.0853523015,   0.6648493888,   0.2198112180, ... 
         3.1414452725 ]';
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
