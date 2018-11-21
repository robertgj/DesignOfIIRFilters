#!/bin/sh

prog=deczky3a_socp_test.m

depends="deczky3a_socp_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
Aerror.m Terror.m armijo_kim.m \
fixResultNaN.m iirA.m iirE.m iirT.m iirP.m local_max.m iir_slb.m \
iir_socp_mmse.m iir_slb_exchange_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m xConstraints.m showResponseBands.m \
showResponse.m showResponsePassBands.m showZPplot.m x2tf.m SeDuMi_1_3/"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp/SeDuMi_1_3
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

# the output should look like this
#
cat > test_d2_coef.m << 'EOF'
Ud2=0,Vd2=0,Md2=10,Qd2=6,Rd2=1
d2 = [   0.0006772923, ...
         1.0488579068,   1.2294047897,   1.3395150513,   1.8656744345, ... 
         2.8773873619, ...
         1.9080513885,   2.1820531229,   2.7687248523,   0.4215761064, ... 
         0.7902545210, ...
         0.6457618303,   0.7216100884,   0.7673107813, ...
         0.3572807694,   1.0088373082,   1.4821438720 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_d2_coef.m deczky3a_socp_test_d2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

