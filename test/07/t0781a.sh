#!/bin/sh

prog=yalmip_kyp_dual_recover_test.m

depends="test/yalmip_kyp_dual_recover_test.m test_common.m \
gkyp_find_z_basis.m kyp_expand_z_basis.m kyp_P_adjoint.m kyp_Q_adjoint.m"

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
Pass-band KYP primal maximum response error = 0.00449822(Esq_pass=0.00449823)

Pass-band KYP dual maximum response error = 0.00446346,(Esq_pass=0.00449823)
Primal duality_gap= 3.476e-05

Recovered primal objective = 0.00446346, (Esq_pass=0.00449823)
Recovered primal duality_gap=-2.97156e-09
Recovered primal norm(V_pass-value(Constraints(1)))=   9.53729
Recovered primal variable v_pass=  -8.94058
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok yalmip_kyp_dual_recover_test.results
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

