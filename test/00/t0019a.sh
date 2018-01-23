#!/bin/sh

prog=iir_sqp_slb_bandpass_test.m

depends="iir_sqp_slb_bandpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_sqp_mmse.m \
iir_slb_show_constraints.m iir_slb_update_constraints.m \
iir_slb_exchange_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m \
Aerror.m Terror.m armijo_kim.m cl2bp.m fixResultNaN.m iirA.m iirE.m iirP.m \
iirT.m iir_sqp_octave.m invSVD.m local_max.m local_peak.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m \
sqp_bfgs.m tf2x.m updateWchol.m updateWbfgs.m x2tf.m xConstraints.m"
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
d1 = [   0.0119791719, ...
         0.9668940600,  -0.9563034376, ...
         1.4174259752,  -0.9929305638,   0.9825537291,   0.9840647434, ... 
         0.9850565085,   0.9840731174,   0.9950610666,   0.9828019217, ... 
         1.3531788870, ...
         1.0931319109,   3.4229979979,   2.1916366919,   1.9374253151, ... 
         1.7364023574,   2.4477259435,   4.6900215587,   2.6751180805, ... 
         5.4421470715, ...
         0.7466027919,   0.6464650447,   0.5695933021,   0.6210134085, ... 
         0.7114773551, ...
         1.0539622880,   1.3921818896,   1.9317496488,   2.4246019268, ... 
         2.8011826798 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok iir_sqp_slb_bandpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
