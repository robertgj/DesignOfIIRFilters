#!/bin/sh

prog=fir_socp_slb_lowpass_test.m

depends="fir_socp_slb_lowpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
local_max.m tf2x.m zp2x.m x2tf.m xConstraints.m \
qroots.m qzsolve.oct"

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
Ud1=2,Vd1=0,Md1=28,Qd1=0,Rd1=1
d1 = [   0.0046127588, ...
        -3.6214938134,  -0.9413639079, ...
         0.7358548492,   0.7564278737,   0.7836199014,   0.8255272419, ... 
         0.8255305405,   0.8439132273,   0.8874924858,   0.9260336458, ... 
         0.9320844783,   0.9497765441,   0.9698918432,   0.9942608895, ... 
         1.0015191287,   1.3103104036, ...
         0.8295994954,   0.1953977844,   0.4610367527,   2.1069332831, ... 
         2.0529475946,   2.4089462771,   2.5919602126,   1.8113067821, ... 
         2.7625173275,   1.5886980497,   1.4013498778,   1.2753495419, ... 
         2.9456673979,   0.3680431836 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.d1.ok fir_socp_slb_lowpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
