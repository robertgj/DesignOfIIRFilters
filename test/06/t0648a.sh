#!/bin/sh

prog=iir_piqp_slb_hilbert_R2_test.m

depends="test/iir_piqp_slb_hilbert_R2_test.m \
../tarczynski_hilbert_R2_test_D0_coef.m \
../tarczynski_hilbert_R2_test_N0_coef.m \
test_common.m print_polynomial.m print_pole_zero.m fixResultNaN.m \
iirA.m iirE.m iirT.m iirP.m local_max.m iir_piqp_mmse.m iir_slb.m \
iir_slb_exchange_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m showResponseBands.m tf2x.m x2tf.m zp2x.m \
showResponse.m showResponsePassBands.m showZPplot.m xConstraints.m \
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
Ud1=7,Vd1=4,Md1=4,Qd1=2,Rd1=2
d1 = [   0.0094567570, ...
        -2.6154872661,  -0.8332583545,  -0.2954790421,  -0.2282825924, ... 
         0.3817815750,   0.4814728504,   1.2164323286, ...
        -0.2217054809,   0.1820329722,   0.2225673371,   0.6886869649, ...
         2.2679216353,   2.5405979202, ...
         1.0386127870,   2.0930312669, ...
         0.2417934073, ...
         1.6271712597 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_piqp_slb_hilbert_R2_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass
