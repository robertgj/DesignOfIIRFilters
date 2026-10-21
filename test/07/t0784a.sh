#!/bin/sh

prog=directFIRsymmetric_kyp_dual_lowpass_test.m

depends="test/directFIRsymmetric_kyp_dual_lowpass_test.m test_common.m \
gkyp_find_z_basis.m kyp_P_adjoint.m kyp_Q_adjoint.m kyp_expand_z_basis.m \
kyp_find_symmetric_Theta_basis.m \
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

Find primal solution with empty objective:
max_Esq_z=0.00321627,Esq_z=0.00321670
max_Asq_p=1.11662003 (    0.4791 dB),min_Asq_p=0.88979200 (   -0.5071 dB)
max_Asq_s=0.00009996 (       -40 dB),Asq_s=0.00010000

Find primal solution with pass-band Esq_z:
max_Esq_z=0.00321135,Esq_z=0.00321145
max_Asq_p=1.11653055 (    0.4787 dB),min_Asq_p=0.88987387 (   -0.5067 dB)
max_Asq_s=0.00010013 (    -39.99 dB),Asq_s=0.00010000

Find reduced complexity dual solution:
Objective_dual=  3.67e-10
Recovered primal variable v_pass (Esq_s) =    -2.065
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok directFIRsymmetric_kyp_dual_lowpass_test.results
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

