#!/bin/sh

prog=iir_yalmip_mmse_test.m

depends="test/iir_yalmip_mmse_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_yalmip_mmse.m iir_slb_update_constraints.m iir_slb_show_constraints.m \
cl2bp.m fixResultNaN.m iirA.m iirE.m iirT.m iirP.m local_max.m zp2x.m x2tf.m \
showResponseBands.m showResponse.m showResponsePassBands.m showZPplot.m tf2x.m \
xConstraints.m iir_slb_set_empty_constraints.m iir_slb_constraints_are_empty.m \
qroots.oct"

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
cat > test_scs-direct_x1_coef.ok << 'EOF'
x1 = [   0.0022646452,   0.8914897441,   0.9018747091,   1.2039012325, ... 
        -0.8753589458,   1.0764769266,   1.1633584859,   1.1873804924, ... 
         1.1873804919,   0.0000000000,   1.8807081349,   1.8245652065, ... 
         3.0153915575,   2.2902913511,   3.7573141028,   3.1415373856, ... 
         3.1417667657,   0.9687271229,   0.7007615889,   0.9686104496, ... 
         0.6961171397,   1.1258550319,   1.6047069955,   2.6203709343, ... 
         1.7536411129 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_scs-direct_x1_coef.ok";fail;
fi

cat > test_scs-indirect_x1_coef.ok << 'EOF'
x1 = [   0.0022629492,   0.8910573158,   0.9018632790,   1.2040090423, ... 
        -0.8748300627,   1.0765434964,   1.1634014159,   1.1874066997, ... 
         1.1874066992,   0.0000000000,   1.8808340340,   1.8244072697, ... 
         3.0154901873,   2.2902939939,   3.7573221568,   3.1415373831, ... 
         3.1417667665,   0.9687271182,   0.7005772425,   0.9686104544, ... 
         0.6961409327,   1.1268351428,   1.6050923547,   2.6203772304, ... 
         1.7537419224 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_scs-indirect_x1_coef.ok";fail;
fi

cat > test_sedumi_x1_coef.ok << 'EOF'
x1 = [   0.0022581520,   0.8910828481,   0.9023117605,   1.2054281005, ... 
        -0.8749665894,   1.0759924939,   1.1629925747,   1.1871245202, ... 
         1.1871245197,   0.0000000000,   1.8791753047,   1.8264195404, ... 
         3.0150953425,   2.2900415379,   3.7573914526,   3.1415379819, ... 
         3.1417673790,   0.9687271224,   0.7008347883,   0.9686104489, ... 
         0.6968690641,   1.1266027309,   1.6053255109,   2.6203486289, ... 
         1.7546274074 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_sedumi_x1_coef.ok";fail;
fi

cat > test_sdpt3_x1_coef.ok << 'EOF'
x1 = [   0.0022581336,   0.8910741710,   0.9023144623,   1.2054390232, ... 
        -0.8749594632,   1.0759910840,   1.1629922450,   1.1871247848, ... 
         1.1871247843,   0.0000000000,   1.8791657168,   1.8264274339, ... 
         3.0150945640,   2.2900413226,   3.7573906810,   3.1415375332, ... 
         3.1417669302,   0.9687271175,   0.7008371263,   0.9686104501, ... 
         0.6968704112,   1.1266032422,   1.6053305845,   2.6203484762, ... 
         1.7546309470 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_sdpt3_x1_coef.ok";fail;
fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_scs-direct_x1_coef.ok iir_yalmip_mmse_test_scs-direct_x1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_scs-direct_x1_coef.ok"; fail;
fi

diff -Bb test_scs-indirect_x1_coef.ok iir_yalmip_mmse_test_scs-indirect_x1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_scs-indirect_x1_coef.ok"; fail;
fi

diff -Bb test_sedumi_x1_coef.ok iir_yalmip_mmse_test_sedumi_x1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_sedumi_x1_coef.ok"; fail;
fi

diff -Bb test_sdpt3_x1_coef.ok iir_yalmip_mmse_test_sdpt3_x1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_sdpt3_x1_coef.ok"; fail;
fi


#
# this much worked
#
pass

