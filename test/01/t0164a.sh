#!/bin/sh

prog=iir_socp_slb_bandpass_test.m

depends="iir_socp_slb_bandpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m 
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m Aerror.m Perror.m Terror.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
local_max.m local_peak.m tf2x.m x2tf.m xConstraints.m SeDuMi_1_3/"
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
cat > test.ok << 'EOF'
Ud1=2,Vd1=0,Md1=18,Qd1=10,Rd1=2
d1 = [   0.0002963101, ...
         2.6259837779,   1.3069430770, ...
         1.2931230772,   0.9853880141,   0.9901079752,   1.5513139750, ... 
         1.0084464780,   1.4806163982,   1.3560239792,   1.5228531555, ... 
         1.3263961794, ...
         0.9376529564,   0.2649459226,   1.6038066463,   2.1832519229, ... 
         1.8531165008,   2.6291165346,   2.6670600922,   2.3246853748, ... 
         2.2743635581, ...
         0.6955309527,   0.6211003619,   0.6158345184,   0.5952781504, ... 
         0.1621688198, ...
         1.0025152827,   1.4288446716,   2.8466776361,   2.3406230402, ... 
         2.0739458129 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_socp_slb_bandpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
