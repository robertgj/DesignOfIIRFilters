#!/bin/sh

prog=iir_frm_allpass_slb_update_constraints_test.m 

depends="iir_frm_allpass_slb_update_constraints_test.m test_common.m \
iir_frm_allpass_slb_update_constraints.m \
iir_frm_allpass_slb_show_constraints.m \
iir_frm_allpass_struct_to_vec.m iir_frm_allpass_vec_to_struct.m \
iir_frm_allpass.m allpassP.m allpassT.m local_max.m tf2a.m a2tf.m \
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
cat > test.ok << 'EOF'
verbose = 1
tol = 1.0000e-05
al=[ 601 ]
au=[ 1 60 106 161 209 276 303 367 412 487 516 581 621 626 ]
tl=[ 558 585 ]
tu=[ 544 571 601 ]
Current constraints:
al=[ 601 ]
f(al)=[ 0.300000 ](fs=1)
Asql=[ -0.515109 ](dB)
au=[ 1 60 106 161 209 276 303 367 412 487 516 581 621 626 ]
f(au)=[ 0.000000 0.029500 0.052500 0.080000 0.104000 0.137500 0.151000 0.183000 0.205500 0.243000 0.257500 0.290000 0.310000 0.312500 ](fs=1)
Asqu=[ 0.039583 0.052431 0.012062 0.016701 0.025501 0.021810 0.024844 0.030175 0.069541 0.096763 0.033190 0.089764 -34.520128 -43.779791 ](dB)
tl=[ 558 585 ]
f(tl)=[ 0.278500 0.292000 ](fs=1)
Tl=[ -1.953724 -3.624862 ](Samples)
tu=[ 544 571 601 ]
f(tu)=[ 0.271500 0.285000 0.300000 ](fs=1)
Tu=[ 1.436963 2.899638 20.474694 ](Samples)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

