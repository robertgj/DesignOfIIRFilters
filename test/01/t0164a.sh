#!/bin/sh

prog=iir_socp_slb_bandpass_test.m

depends="iir_socp_slb_bandpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m Aerror.m Perror.m Terror.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
local_max.m tf2x.m x2tf.m xConstraints.m \
qroots.m qzsolve.oct SeDuMi_1_3/"

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
Ud1=2,Vd1=0,Md1=18,Qd1=10,Rd1=2
d1 = [   0.0002926862, ...
         1.3288943425,   2.8878595727, ...
         0.9744356084,   0.9780306443,   0.9874087433,   1.2434131492, ... 
         1.2932138397,   1.4061414664,   1.4357516872,   1.5844314624, ... 
         1.6316325745, ...
         1.8632909206,   0.2657689414,   1.6019888896,   2.1400274867, ... 
         0.9365825776,   2.5914232178,   2.2375028079,   2.2228147265, ... 
         2.6273861411, ...
         0.1879112934,   0.5898738969,   0.6015561944,   0.6249270740, ... 
         0.7027891528, ...
         2.3988398649,   2.3440814917,   2.8835081382,   1.4308076449, ... 
         1.0137307540 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_socp_slb_bandpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
