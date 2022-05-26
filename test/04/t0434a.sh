#!/bin/sh

prog=zolotarev_vlcek_unbehauen_table_v_test.m

depends="test/zolotarev_vlcek_unbehauen_table_v_test.m \
zolotarev_vlcek_unbehauen.m test_common.m print_polynomial.m \
elliptic_F.m elliptic_E.m jacobi_Eta.m jacobi_Theta.m jacobi_Zeta.m \
jacobi_theta1.m jacobi_theta1k.m jacobi_theta2.m jacobi_theta2k.m \
jacobi_theta3.m jacobi_theta3k.m jacobi_theta4.m jacobi_theta4k.m \
jacobi_theta2p.m jacobi_theta4p.m jacobi_theta4kp.m \
carlson_RJ.m carlson_RD.m carlson_RC.m carlson_RF.m \
chebyshevP.m chebyshevT.m chebyshevU.m chebyshevT_expand.m"

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
cat > test_a_3_6.ok << 'EOF'
a_3_6 = [   0.0985975441,   0.0979370695,  -0.0986423865,  -0.1934009697, ... 
           -0.0935059158,   0.0955182760,   0.1823184146,   0.0857438837, ... 
           -0.0887676563,  -1.0857982595 ];
EOF
if [ $? -ne 0 ]; then echo "Failed cat test_a_3_6.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a_3_6.ok zolotarev_vlcek_unbehauen_table_v_test_a_3_6_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_a_3_6.ok"; fail; fi

#
# this much worked
#
pass

