#!/bin/sh

prog=iir_socp_slb_lowpass_differentiator_test.m

depends="test/iir_socp_slb_lowpass_differentiator_test.m \
../tarczynski_lowpass_differentiator_test_N0_coef.m \
../tarczynski_lowpass_differentiator_test_D0_coef.m \
test_common.m delayz.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_exchange_constraints.m \
iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_show_constraints.m iir_slb_update_constraints.m \
fixResultNaN.m iirA.m iirE.m iirT.m iirP.m local_max.m showZPplot.m \
zp2x.m tf2x.m x2tf.m xConstraints.m qroots.oct \
"

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
cat > test_d1z.ok << 'EOF'
Ud1z=2,Vd1z=1,Md1z=10,Qd1z=10,Rd1z=1
d1z = [   0.0028834725, ...
         -1.0214159134,   1.0000000000, ...
          0.4787107456, ...
          0.7569056374,   1.0915932462,   1.6525068722,   1.8325296967, ... 
          1.9462224379, ...
          2.4218671238,   2.6376026574,   1.5192464141,   0.8329330514, ... 
          0.3638365205, ...
          0.4302598878,   0.5022822816,   0.5220527618,   0.7195893332, ... 
          0.9215850659, ...
          0.3933290961,   1.1077015496,   1.3494605915,   1.8343327444, ... 
          2.0904052114 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d1z.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_d1z.ok iir_socp_slb_lowpass_differentiator_test_d1z_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d1z.ok"; fail; fi

#
# this much worked
#
pass

