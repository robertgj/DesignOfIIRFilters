#!/bin/sh

prog=iir_socp_slb_bandpass_test.m

depends="iir_socp_slb_bandpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m Aerror.m Perror.m Terror.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
local_max.m local_peak.m tf2x.m x2tf.m xConstraints.m \
qroots.m qzsolve.oct SeDuMi_1_3/"

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
d1 = [   0.0004871361, ...
         1.2714222711,   2.6922885228, ...
         0.9201251155,   0.9454013125,   0.9844190677,   0.9910987582, ... 
         1.1613784031,   1.2934057132,   1.3507448639,   1.4428631055, ... 
         2.3896476055, ...
         2.1971112396,   1.8190937918,   1.6108412910,   0.2635969328, ... 
         2.5182767472,   0.9383703401,   2.5023178028,   2.5030862828, ... 
         1.6763789758, ...
         0.1493842403,   0.6031046427,   0.6127247630,   0.6719681688, ... 
         0.6871981014, ...
         1.4595667876,   2.3037826588,   1.4435742952,   2.7324037149, ... 
         1.0205731153 ]';
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
