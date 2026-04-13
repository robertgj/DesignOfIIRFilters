#!/bin/sh

prog=yalmip_generalised_kyp_dual_bandpass_test.m

depends="test/yalmip_generalised_kyp_dual_bandpass_test.m test_common.m"

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
Primary constraints (sl,pl,pu,su) sol.problem=0
Dual constraints (sl,pl,pu,su) sol.problem=0
norm(value(W_pl))=  3.47e-13,trace(value(W_pl)*Theta_pl)= -3.02e-13
norm(value(W_pu))=  4.88e-13,trace(value(W_pu)*Theta_pu)= -5.31e-13
norm(value(W_su))=        89,trace(value(W_su)*Theta_su)=    -9e-11
norm(value(W_sl))=       376,trace(value(W_sl)*Theta_sl)= -9.05e-11
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1

diff -Bb test.ok yalmip_generalised_kyp_dual_bandpass_test.results
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test.ok"; fail; fi

#
# this much worked
#
pass

