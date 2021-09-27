#!/bin/sh

prog=iir_socp_slb_fir_lowpass_test.m

depends="iir_socp_slb_fir_lowpass_test.m \
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
Ud1=2,Vd1=0,Md1=54,Qd1=0,Rd1=1
d1 = [  0.00183851, ...
       -1.16375235,  0.86741437, ...
        0.86794029,  0.87007424,  0.87081647,  0.87271561, ... 
        0.87279406,  0.88806777,  0.93790944,  0.94529536, ... 
        0.95353372,  0.95607387,  0.96403147,  0.96949861, ... 
        0.97335286,  0.97615655,  0.97827276,  0.97992909, ... 
        0.98129133,  0.98249975,  0.98369302,  0.98449708, ... 
        0.98507624,  0.98695881,  0.98986377,  0.99330791, ... 
        0.99866273,  1.33714273,  1.35104506, ...
        0.47289024,  0.31206719,  0.15947848,  0.78063677, ... 
        0.62941577,  0.94160145,  1.49199705,  1.59212803, ... 
        1.40442969,  1.70032391,  1.80330121,  1.90661172, ... 
        2.01087553,  2.11604002,  2.22192814,  2.32836647, ... 
        2.43519178,  2.54227229,  2.64948568,  1.32286709, ... 
        2.75673251,  2.86397112,  2.97139520,  3.07844406, ... 
        1.26478671,  0.66461330,  0.22194857 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.d1.ok iir_socp_slb_fir_lowpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
