#!/bin/sh

prog=iir_frm_socp_slb_test.m

depends="iir_frm_socp_slb_test.m test_common.m \
iir_frm.m \
iir_frm_slb.m \
iir_frm_slb_constraints_are_empty.m \
iir_frm_slb_exchange_constraints.m \
iir_frm_slb_set_empty_constraints.m \
iir_frm_slb_show_constraints.m \
iir_frm_slb_update_constraints.m \
iir_frm_socp_mmse.m \
iir_frm_socp_slb_plot.m \
iir_frm_struct_to_vec.m \
iir_frm_vec_to_struct.m \
iirA.m iirP.m iirT.m iirdelAdelw.m fixResultNaN.m tf2x.m zp2x.m x2tf.m \
xConstraints.m print_polynomial.m print_pole_zero.m \
local_max.m qroots.m qzsolve.oct"

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
cat > test_a_coef.m.ok << 'EOF'
a = [   0.0017318515,   0.0017085649,  -0.0018370129,  -0.0031501272, ... 
        0.0045117556,   0.0065808594,  -0.0105041041,   0.0167267305, ... 
       -0.0030729049,  -0.0064443719,   0.0023167386 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a_coef.m.ok"; fail; fi

cat > test_d_coef.m.ok << 'EOF'
d = [   1.0000000000,   1.3894302730,   1.4139032461,   0.8211186891, ... 
       -0.0344286119,  -0.3810690593,  -0.2754109098,  -0.0585094905, ... 
        0.0329935630,   0.0201866630,   0.0030208096 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_coef.m.ok"; fail; fi

cat > test_aa_coef.m.ok << 'EOF'
aa = [   0.2110747771,  -0.0709287364,  -0.1892110999,   0.2566963157, ... 
         0.0711368852,  -0.2907807494,   0.2809489374,   0.2000774721, ... 
        -0.4317551430,   0.1087159584,   0.4723230801,  -0.4311018025, ... 
        -0.2051823948,   0.5915588797,  -0.1010405861,  -0.5383016051, ... 
         0.5016421209,   0.3005686775,  -0.3537946753,   0.2437140422, ... 
         0.9350421235,   0.2437140422,  -0.3537946753,   0.3005686775, ... 
         0.5016421209,  -0.5383016051,  -0.1010405861,   0.5915588797, ... 
        -0.2051823948,  -0.4311018025,   0.4723230801,   0.1087159584, ... 
        -0.4317551430,   0.2000774721,   0.2809489374,  -0.2907807494, ... 
         0.0711368852,   0.2566963157,  -0.1892110999,  -0.0709287364, ... 
         0.2110747771 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi

cat > test_ac_coef.m.ok << 'EOF'
ac = [  -0.0054848310,   0.0012367308,   0.0053811570,  -0.0050942035, ... 
        -0.0048115433,   0.0079186107,  -0.0038086017,  -0.0080515305, ... 
         0.0078397093,   0.0184916177,  -0.0167564605,  -0.0135806784, ... 
         0.0312361721,   0.0034131501,  -0.0436672128,   0.0304843285, ... 
         0.0526274347,  -0.0818400082,  -0.0728954940,   0.3085167748, ... 
         0.5734445057,   0.3085167748,  -0.0728954940,  -0.0818400082, ... 
         0.0526274347,   0.0304843285,  -0.0436672128,   0.0034131501, ... 
         0.0312361721,  -0.0135806784,  -0.0167564605,   0.0184916177, ... 
         0.0078397093,  -0.0080515305,  -0.0038086017,   0.0079186107, ... 
        -0.0048115433,  -0.0050942035,   0.0053811570,   0.0012367308, ... 
        -0.0054848310 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ac_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
diff -Bb test_a_coef.m.ok iir_frm_socp_slb_test_a_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on a.coef"; fail; fi

diff -Bb test_d_coef.m.ok iir_frm_socp_slb_test_d_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on d.coef"; fail; fi

diff -Bb test_aa_coef.m.ok iir_frm_socp_slb_test_aa_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on aa.coef"; fail; fi

diff -Bb test_ac_coef.m.ok iir_frm_socp_slb_test_ac_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb on ac.coef"; fail; fi

#
# this much worked
#
pass

