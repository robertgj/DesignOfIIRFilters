#!/bin/sh

prog=iir_socp_slb_lowpass_test.m

depends="iir_socp_slb_lowpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m Aerror.m Perror.m Terror.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
local_max.m local_peak.m tf2x.m x2tf.m xConstraints.m WISEJ_ND.m tf2Abcd.m \
SeDuMi_1_3/"
tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
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
Ud1=1,Vd1=1,Md1=14,Qd1=14,Rd1=1
d1 = [   0.0058965260, ...
         0.6023327851, ...
         0.7510800920, ...
         1.3609660662,   0.9162196073,   0.8961328608,   1.0000854729, ... 
         0.8449034795,   0.7514302329,   0.7425779898, ...
         0.3535007911,   0.9445223690,   1.4484632372,   1.2724820852, ... 
         1.9220008583,   2.4691482841,   2.9239834231, ...
         0.9337467010,   0.9074884262,   0.5841220906,   0.7492877696, ... 
         0.5241871112,   0.3593140499,   0.1437175635, ...
         1.0456940706,   0.9339612641,   1.2721668494,   0.7113638903, ... 
         0.2869657618,   1.4680073484,   1.7813591878 ]';
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
