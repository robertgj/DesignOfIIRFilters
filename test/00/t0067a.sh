#!/bin/sh

prog=iir_frm_allpass_slb_exchange_constraints_test.m

depends="iir_frm_allpass_slb_exchange_constraints_test.m test_common.m \
iir_frm_allpass_slb_exchange_constraints.m \
iir_frm_allpass_slb_show_constraints.m \
iir_frm_allpass_slb_update_constraints.m \
iir_frm_allpass_struct_to_vec.m iir_frm_allpass_vec_to_struct.m \
iir_frm_allpass.m allpassP.m allpassT.m tf2a.m a2tf.m local_max.m \
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
maxiter = 2000
tol = 5.0000e-06
verbose = 1
dmask = 16
tp = 97
vRx0 before exchange constraints:
Current constraints:
al=[ 601 ]
f(al)=[ 0.300000 ](fs=1)
Asql=[ -0.515109 ](dB)
au=[ 1 60 106 161 209 276 303 367 412 487 516 581 621 626 636 ]
f(au)=[ 0.000000 0.029500 0.052500 0.080000 0.104000 0.137500 0.151000 0.183000 0.205500 0.243000 0.257500 0.290000 0.310000 0.312500 0.317500 ](fs=1)
Asqu=[ 0.039583 0.052431 0.012062 0.016701 0.025501 0.021810 0.024844 0.030175 0.069541 0.096763 0.033190 0.089764 -34.520128 -43.779791 -47.645604 ](dB)
tl=[ 558 585 ]
f(tl)=[ 0.278500 0.292000 ](fs=1)
Tl=[ -1.953724 -3.624862 ](Samples)
tu=[ 544 571 601 ]
f(tu)=[ 0.271500 0.285000 0.300000 ](fs=1)
Tu=[ 1.436963 2.899638 20.474694 ](Samples)
vSx1 before exchange constraints:
Current constraints:
au=[ 35 65 131 171 232 279 326 340 375 390 438 496 524 585 621 627 639 671 703 724 739 769 946 966 1000 ]
f(au)=[ 0.017000 0.032000 0.065000 0.085000 0.115500 0.139000 0.162500 0.169500 0.187000 0.194500 0.218500 0.247500 0.261500 0.292000 0.310000 0.313000 0.319000 0.335000 0.351000 0.361500 0.369000 0.384000 0.472500 0.482500 0.499500 ](fs=1)
Asqu=[ 0.013388 0.001751 0.001208 0.009955 0.010250 0.012132 0.002921 0.001181 0.000790 0.018094 0.020340 0.026536 0.016623 0.038117 -29.181703 -38.379587 -41.172447 -43.855337 -44.475554 -43.372421 -48.095270 -47.228371 -45.899936 -47.786201 -48.163556 ](dB)
tl=[ 590 ]
f(tl)=[ 0.294500 ](fs=1)
Tl=[ -2.332216 ](Samples)
tu=[ 573 601 ]
f(tu)=[ 0.286000 0.300000 ](fs=1)
Tu=[ 1.175510 4.594870 ](Samples)
Exchanged constraint from vR.tu(601) to vS
vRx1 after exchange constraints:
Current constraints:
al=[ 601 ]
f(al)=[ 0.300000 ](fs=1)
Asql=[ -0.079747 ](dB)
au=[ 1 60 106 161 209 276 303 367 412 487 516 581 621 626 636 ]
f(au)=[ 0.000000 0.029500 0.052500 0.080000 0.104000 0.137500 0.151000 0.183000 0.205500 0.243000 0.257500 0.290000 0.310000 0.312500 0.317500 ](fs=1)
Asqu=[ -0.012092 -0.004242 -0.001085 -0.001461 -0.004298 0.008508 -0.001244 -0.001106 -0.016115 0.003194 0.010958 0.033308 -29.181703 -38.891274 -42.052839 ](dB)
tl=[ 558 585 ]
f(tl)=[ 0.278500 0.292000 ](fs=1)
Tl=[ -0.913437 -1.619713 ](Samples)
tu=[ 544 571 ]
f(tu)=[ 0.271500 0.285000 ](fs=1)
Tu=[ 0.393199 1.000522 ](Samples)
vSx1 after exchange constraints:
Current constraints:
au=[ 35 65 131 171 232 279 326 340 375 390 438 496 524 585 621 627 639 671 703 724 739 769 946 966 1000 ]
f(au)=[ 0.017000 0.032000 0.065000 0.085000 0.115500 0.139000 0.162500 0.169500 0.187000 0.194500 0.218500 0.247500 0.261500 0.292000 0.310000 0.313000 0.319000 0.335000 0.351000 0.361500 0.369000 0.384000 0.472500 0.482500 0.499500 ](fs=1)
Asqu=[ 0.013388 0.001751 0.001208 0.009955 0.010250 0.012132 0.002921 0.001181 0.000790 0.018094 0.020340 0.026536 0.016623 0.038117 -29.181703 -38.379587 -41.172447 -43.855337 -44.475554 -43.372421 -48.095270 -47.228371 -45.899936 -47.786201 -48.163556 ](dB)
tl=[ 590 ]
f(tl)=[ 0.294500 ](fs=1)
Tl=[ -2.332216 ](Samples)
tu=[ 573 601 ]
f(tu)=[ 0.286000 0.300000 ](fs=1)
Tu=[ 1.175510 4.594870 ](Samples)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

