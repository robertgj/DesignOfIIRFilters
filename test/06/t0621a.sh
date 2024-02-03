#!/bin/sh

prog=yalmip_generalised_kyp_dual_lowpass_test.m

depends="test/yalmip_generalised_kyp_dual_lowpass_test.m test_common.m"

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
Primary constraints (pl,pu,s,tu) sol.problem=0
Primary constraints (tu) sol.problem=0
Dual constraints (pl,pu,s) sol.problem=0
Dual constraints (SDPT3,tl,tu) sol.problem=0
norm(value(W_pl))=    0.0263,trace(value(W_pl)*Theta_pl)=  2.38e-09
norm(value(W_pu))=     0.751,trace(value(W_pu)*Theta_pu)=  3.03e-09
norm(value(W_s))=      0.725,trace(value(W_s)*Theta_s)=    2.77e-09
norm(value(W_tu))=  6.07e-12,trace(value(W_tu)*Theta_tu)=  -2.9e-12
norm(value(W_tl))=  3.29e-12,trace(value(W_tl)*Theta_tl)= -3.34e-13
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1

diff -Bb test.ok yalmip_generalised_kyp_dual_lowpass_test.results
if [ $? -ne 0 ]; then echo "Failed diff -Bb on test.ok"; fail; fi

#
# this much worked
#
pass

