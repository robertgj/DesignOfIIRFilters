#!/bin/sh

prog=frm2ndOrderCascade_socp_test.m

depends="frm2ndOrderCascade_socp_test.m test_common.m \
frm2ndOrderCascade_socp.m frm2ndOrderCascade.m tf2casc.m casc2tf.m \
frm2ndOrderCascade_vec_to_struct.m frm2ndOrderCascade_struct_to_vec.m \
frm_lowpass_vectors.m stability2ndOrderCascade.m print_polynomial.m SeDuMi_1_3/"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
echo $here
for file in $depends;do \
  cp -R src/$file $tmp; \
  if [ $? -ne 0 ]; then echo "Failed cp "$file; fail; fi \
done
cd $tmp
if [ $? -ne 0 ]; then echo "Failed cd"; fail; fi

#
# the output should look like this
#
cat > test_a_coef.m.ok << 'EOF'
a = [  -0.0670546452,   0.2075411246,  -0.2558804280,   0.0431470992, ... 
        0.2509156686,  -0.0221074511,  -0.8451495449,  -0.4404185301, ... 
       -0.6556919561,   1.1929884066,  -0.1194066596 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a_coef.m.ok"; fail; fi
cat > test_d_coef.m.ok << 'EOF'
d = [   1.0000000000,  -1.1302284404,   1.0710072441,  -1.0142298433, ... 
        0.3943954024,   0.0719108007,  -0.2344047731,   0.1797717405, ... 
       -0.0744920814,   0.0163997036,  -0.0015708961 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_coef.m.ok"; fail; fi
cat > test_aa_coef.m.ok << 'EOF'
aa = [   0.0037047681,  -0.0090367187,  -0.0029380252,   0.0147570950, ... 
        -0.0084247304,  -0.0129993264,   0.0226914904,   0.0019752296, ... 
        -0.0212928095,   0.0346276786,  -0.0133590313,  -0.0453857470, ... 
         0.0734396134,  -0.0106391867,  -0.1385722131,   0.2789885219, ... 
         0.6783003812,   0.2789885219,  -0.1385722131,  -0.0106391867, ... 
         0.0734396134,  -0.0453857470,  -0.0133590313,   0.0346276786, ... 
        -0.0212928095,   0.0019752296,   0.0226914904,  -0.0129993264, ... 
        -0.0084247304,   0.0147570950,  -0.0029380252,  -0.0090367187, ... 
         0.0037047681 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi
cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0017285751,  -0.0047614236,  -0.0004221811,   0.0073778746, ... 
        -0.0065757674,  -0.0050556645,   0.0135559950,  -0.0030070218, ... 
        -0.0087833435,   0.0278348521,  -0.0228558863,  -0.0298658442, ... 
         0.0717853770,  -0.0266370007,  -0.1221792522,   0.2866262979, ... 
         0.6524641775,   0.2866262979,  -0.1221792522,  -0.0266370007, ... 
         0.0717853770,  -0.0298658442,  -0.0228558863,   0.0278348521, ... 
        -0.0087833435,  -0.0030070218,   0.0135559950,  -0.0050556645, ... 
        -0.0065757674,   0.0073778746,  -0.0004221811,  -0.0047614236, ... 
         0.0017285751 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ac_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_a_coef.m.ok frm2ndOrderCascade_socp_test_a_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on a.coef"; fail; fi
diff -Bb test_d_coef.m.ok frm2ndOrderCascade_socp_test_d_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on d.coef"; fail; fi
diff -Bb test_aa_coef.m.ok frm2ndOrderCascade_socp_test_aa_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on aa.coef"; fail; fi
diff -Bb test_ac_coef.m.ok frm2ndOrderCascade_socp_test_ac_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on ac.coef"; fail; fi

#
# this much worked
#
pass

