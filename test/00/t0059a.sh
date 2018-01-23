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
a = [  -0.0670638355,   0.2075231646,  -0.2557629487,   0.0429412824, ... 
        0.2510381494,  -0.0220238387,  -0.8452013645,  -0.4404853589, ... 
       -0.6561340777,   1.1930262627,  -0.1191646168 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a_coef.m.ok"; fail; fi
cat > test_d_coef.m.ok << 'EOF'
d = [   1.0000000000,  -1.1297298975,   1.0703348345,  -1.0136151448, ... 
        0.3939445988,   0.0719575589,  -0.2341804517,   0.1795060709, ... 
       -0.0743305673,   0.0163517321,  -0.0015651193 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_coef.m.ok"; fail; fi
cat > test_aa_coef.m.ok << 'EOF'
aa = [   0.0037135196,  -0.0090258670,  -0.0029427402,   0.0147479739, ... 
        -0.0084170312,  -0.0129877846,   0.0226913959,   0.0019769306, ... 
        -0.0212855058,   0.0346447841,  -0.0133448209,  -0.0453932272, ... 
         0.0734263389,  -0.0106279856,  -0.1385485540,   0.2789950982, ... 
         0.6782975754,   0.2789950982,  -0.1385485540,  -0.0106279856, ... 
         0.0734263389,  -0.0453932272,  -0.0133448209,   0.0346447841, ... 
        -0.0212855058,   0.0019769306,   0.0226913959,  -0.0129877846, ... 
        -0.0084170312,   0.0147479739,  -0.0029427402,  -0.0090258670, ... 
         0.0037135196 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi
cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0017342802,  -0.0047535671,  -0.0004251481,   0.0073708021, ... 
        -0.0065701932,  -0.0050468569,   0.0135548278,  -0.0030063076, ... 
        -0.0087769243,   0.0278469608,  -0.0228460103,  -0.0298698217, ... 
         0.0717752758,  -0.0266304594,  -0.1221601869,   0.2866321256, ... 
         0.6524596979,   0.2866321256,  -0.1221601869,  -0.0266304594, ... 
         0.0717752758,  -0.0298698217,  -0.0228460103,   0.0278469608, ... 
        -0.0087769243,  -0.0030063076,   0.0135548278,  -0.0050468569, ... 
        -0.0065701932,   0.0073708021,  -0.0004251481,  -0.0047535671, ... 
         0.0017342802 ]';
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

