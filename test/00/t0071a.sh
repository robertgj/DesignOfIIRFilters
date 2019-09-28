#!/bin/sh

prog=iir_socp_slb_test.m

depends="iir_socp_slb_test.m test_common.m iir_socp_mmse.m \
iir_slb.m iir_slb_constraints_are_empty.m \
iir_slb_exchange_constraints.m iir_slb_set_empty_constraints.m \
iir_slb_show_constraints.m iir_slb_update_constraints.m \
iirA.m iirP.m iirT.m iirE.m Aerror.m x2tf.m tf2x.m zp2x.m fixResultNaN.m \
xConstraints.m print_pole_zero.m showZPplot.m local_max.m local_peak.m \
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
cat > test_d2_coef.m << 'EOF'
Ud2=1,Vd2=1,Md2=6,Qd2=6,Rd2=1
d2 = [   0.0143152519, ...
        -0.9998555248, ...
         0.4900917108, ...
         0.9997315382,   0.9998999191,   1.0000216862, ...
         1.7646514328,   1.3202073475,   1.1676355768, ...
         0.6359639483,   0.8326280093,   0.9543718092, ...
         0.6802440221,   0.9195627166,   0.9884107477 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d2_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
diff -Bb test_d2_coef.m iir_socp_slb_test_d2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on d2.coef"; fail; fi

#
# this much worked
#
pass

