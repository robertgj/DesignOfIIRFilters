#!/bin/sh

prog=directFIRnonsymmetric_kyp_dual_lowpass_test.m

depends="test/directFIRnonsymmetric_kyp_dual_lowpass_test.m test_common.m \
delayz.m"

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
max_Esq_z=0.00008103,Esq_z=0.00010000
max_Asq_s=0.00000069,Asq_s=0.00000100
Recovered primal duality gap=3.90084e-08
Recovered primal variable v_stop (Esq_s) =-13.6878
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok directFIRnonsymmetric_kyp_dual_lowpass_test.results
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

