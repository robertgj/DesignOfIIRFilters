#!/bin/sh

prog=iir_socp_slb_lowpass_test.m

depends="iir_socp_slb_lowpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
local_max.m tf2x.m zp2x.m x2tf.m xConstraints.m WISEJ_ND.m \
tf2Abcd.m qroots.m qzsolve.oct"
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
Ud1=1,Vd1=1,Md1=14,Qd1=14,Rd1=1
d1 = [   0.0034066604, ...
         0.5189145112, ...
         0.7168168124, ...
         0.8103309653,   0.8213752338,   0.8226352040,   0.9268699489, ... 
         0.9730283118,   0.9956493256,   1.3889635057, ...
         2.9617093293,   2.5858625740,   2.1711815848,   1.5704844551, ... 
         0.9944750993,   1.2797598551,   0.3663885780, ...
         0.1324784021,   0.3502254432,   0.5359300908,   0.5464402779, ... 
         0.7477104197,   0.9282882315,   0.9751175854, ...
         1.9557306248,   1.4847730577,   0.3409829878,   1.1816628467, ... 
         0.7564605263,   1.0668269370,   0.9978203647 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.d1.ok iir_socp_slb_lowpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
