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
d1 = [   0.0121797025, ...
         0.9737564861,  -0.9407368121, ...
         1.4670056060,  -0.9939270229,   0.9756166898,   0.9777463256, ... 
         0.9805296265,   0.9795312589,   0.9955763363,   0.9797312081, ... 
         1.3298964377, ...
         1.1054498390,   3.4230971323,   2.1541209613,   1.9135326087, ... 
         1.7264436726,   2.4222348902,   4.6917485784,   2.6547478753, ... 
         5.4146044096, ...
         0.7558653825,   0.6654897294,   0.5810684018,   0.6390408964, ... 
         0.7256942915, ...
         1.0659341269,   1.4085319806,   1.9688769424,   2.4347284339, ... 
         2.8280539303 ]';
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
