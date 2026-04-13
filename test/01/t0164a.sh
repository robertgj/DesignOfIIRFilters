#!/bin/sh

prog=iir_socp_slb_bandpass_R2_test.m

depends="test/iir_socp_slb_bandpass_R2_test.m test_common.m delayz.m \
../tarczynski_bandpass_R2_test_x_coef.m \
print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
local_max.m tf2x.m x2tf.m xConstraints.m \
qroots.oct"

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
cat > test.ok << 'EOF'
Ud1=2,Vd1=2,Md1=18,Qd1=8,Rd1=2
d1 = [   0.0106092167, ...
        -1.0937678973,   0.9870765735, ...
        -0.6133300781,  -0.4909827993, ...
         0.9931917667,   0.9948441597,   0.9984851119,   0.9997335057, ... 
         1.0992890462,   1.1317147132,   1.1812538487,   1.3109647866, ... 
         1.3310676041, ...
         1.9585095589,   0.2801716799,   1.7339569544,   1.5925349583, ... 
         2.2690891413,   2.4734369863,   2.6832858922,   0.7907994906, ... 
         1.1073611886, ...
         0.5572879789,   0.6001167626,   0.6075021816,   0.7191981647, ...
         1.9382060501,   1.3059607565,   2.6117195582,   1.0061063165 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_socp_slb_bandpass_R2_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
