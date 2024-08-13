#!/bin/sh

prog=iir_scs_mmse_test.m

depends="test/iir_scs_mmse_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_scs_mmse.m iir_slb_update_constraints.m iir_slb_show_constraints.m \
cl2bp.m fixResultNaN.m iirA.m iirE.m iirT.m iirP.m local_max.m zp2x.m x2tf.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m tf2x.m \
xConstraints.m iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m \
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
cat > test_x1_coef.ok << 'EOF'
x1 = [   0.0022581388,   0.8910768991,   0.9023158611,   1.2054423694, ... 
        -0.8749611468,   1.0759891961,   1.1629906212,   1.1871234704, ... 
         1.1871234699,   0.0000000000,   1.8791607653,   1.8264317070, ... 
         3.0150931410,   2.2900398112,   3.7573911216,   3.1415373745, ... 
         3.1417667717,   0.9687271229,   0.7008363941,   0.9686104488, ... 
         0.6968703953,   1.1266029008,   1.6053284873,   2.6203484691, ... 
         1.7546299525 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x1_coef.ok iir_scs_mmse_test_x1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x1_coef.ok"; fail; fi


#
# this much worked
#
pass

