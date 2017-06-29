#!/bin/sh

prog=parhi_ex12_9_1_test.m

depends="obsolete/parhi_ex12_9_1_test.m \
test_common.m xInitHd.m iirE.m iirA.m iirP.m iirT.m Aerror.m \
Perror.m Terror.m xConstraints.m tf2x.m x2tf.m iir_socp_mmse.m fixResultNaN.m \
showResponse.m showResponsePassBands.m showZPplot.m print_pole_zero.m \
print_polynomial.m iir_slb_set_empty_constraints.m iir_slb_show_constraints.m \
iir_slb_constraints_are_empty.m SeDuMi_1_3/"

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
cat > test_d2_coef.m << 'EOF'
Ud2=2,Vd2=0,Md2=4,Qd2=2,Rd2=4
d2 = [   0.0876443042, ...
        -0.9836575135,  -0.9836575135, ...
         1.0008602253,   0.9878329661, ...
         1.1951857404,   2.0503937572, ...
         0.1723230903, ...
         2.4450486535 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_d2_coef.m parhi_ex12_9_1_test_d2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_d2_coef.m"; fail; fi

#
# this much worked
#
pass

