#!/bin/sh

prog=deczky3_piqp_test.m

depends="test/deczky3_piqp_test.m \
test_common.m print_polynomial.m print_pole_zero.m fixResultNaN.m \
iirA.m iirE.m iirT.m iirP.m local_max.m iir_piqp_mmse.m iir_slb.m \
iir_slb_exchange_constraints.m iir_slb_constraints_are_empty.m \
iir_slb_set_empty_constraints.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m showResponseBands.m \
showResponse.m showResponsePassBands.m showZPplot.m xConstraints.m x2tf.m"

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
Ud1=0,Vd1=0,Md1=10,Qd1=6,Rd1=1
d1 = [   0.0026261424, ...
         1.0040405181,   1.0144687854,   1.3629007535,   1.8183761753, ... 
         2.3486458362, ...
         2.0917464989,   2.7612313978,   1.7484695942,   0.7071159216, ... 
         0.0146639395, ...
         0.5030087246,   0.5927948941,   0.6428540221, ...
         0.3452020104,   1.0664101495,   1.4174345838 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok deczky3_piqp_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass
