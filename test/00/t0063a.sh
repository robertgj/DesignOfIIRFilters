#!/bin/sh

prog=deczky3_socp_test.m

depends="deczky3_socp_test.m \
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
        echo FAILED ${0#$here"/"} $prog 1>&2
        cd $here
        rm -rf $tmp/SeDuMi_1_3
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

# the output should look like this
#
cat > test_d2_coef.m << 'EOF'
Ud2=0,Vd2=0,Md2=10,Qd2=6,Rd2=1
d2 = [   0.0034549892, ...
         1.0281357855,   1.0300194560,   1.4047410877,   1.7981205077, ... 
         2.1704133399, ...
         2.0034501134,   2.7150949171,   1.7701610817,   0.7330142457, ... 
         0.1788165601, ...
         0.4953456248,   0.5900366432,   0.6308488488, ...
         0.3523136329,   1.1006443928,   1.4455070181 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_d2_coef.m deczky3_socp_test_d2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

