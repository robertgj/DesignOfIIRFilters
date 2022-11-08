#!/bin/sh

prog=directFIRsymmetric_socp_slb_bandpass_test.m
depends="test/directFIRsymmetric_socp_slb_bandpass_test.m test_common.m \
directFIRsymmetric_slb.m \
directFIRsymmetric_slb_constraints_are_empty.m \
directFIRsymmetric_slb_exchange_constraints.m \
directFIRsymmetric_slb_set_empty_constraints.m \
directFIRsymmetric_slb_show_constraints.m \
directFIRsymmetric_slb_update_constraints.m \
directFIRsymmetric_socp_mmsePW.m \
directFIRsymmetricEsqPW.m \
directFIRsymmetricA.m \
local_max.m \
print_polynomial.m"

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
cat > test_hM1_coef.ok << 'EOF'
hM1 = [  -0.00498259,  -0.00077441,  -0.00359006,  -0.01197965, ... 
          0.00505930,   0.01489769,  -0.00162383,   0.02741140, ... 
          0.05084815,  -0.01823754,  -0.02676637,   0.01876929, ... 
         -0.14168499,  -0.24558003,   0.12083560,   0.43200933 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hM1_coef.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hM1_coef.ok "directFIRsymmetric_socp_slb_bandpass_test_hM1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hM1_coef.ok"; fail; fi

#
# this much worked
#
pass

