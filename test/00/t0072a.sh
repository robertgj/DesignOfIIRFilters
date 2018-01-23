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
iirA.m iirP.m iirT.m iirdelAdelw.m fixResultNaN.m tf2x.m x2tf.m \
xConstraints.m print_polynomial.m print_pole_zero.m \
local_max.m local_peak.m SeDuMi_1_3/"

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
a = [   0.0118671549,   0.0403483660,  -0.0401859094,  -0.0745053774, ... 
        0.1016976908,   0.1689638259,  -0.2009531006,   0.4317717350, ... 
       -0.5348389143,   0.2747903940,   0.1253912551 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a_coef.m.ok"; fail; fi
cat > test_d_coef.m.ok << 'EOF'
d = [   1.0000000000,   0.1199292987,   0.5313265081,   0.1162034463, ... 
       -0.0540372367,  -0.0271434719,  -0.0011135167,   0.0183991286, ... 
        0.0164188642,   0.0056997748,  -0.0004245625 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_coef.m.ok"; fail; fi
cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0025421174,   0.0030158402,  -0.0011923754,  -0.0006328065, ... 
         0.0009847268,   0.0003773102,  -0.0051442073,   0.0055522106, ... 
        -0.0017905987,  -0.0189433683,   0.0253835248,  -0.0080790588, ... 
        -0.0178318342,   0.0265193997,  -0.0020915624,  -0.0512595137, ... 
         0.0639416878,  -0.0022813384,  -0.1417655442,   0.2834508051, ... 
         0.6576762881,   0.2834508051,  -0.1417655442,  -0.0022813384, ... 
         0.0639416878,  -0.0512595137,  -0.0020915624,   0.0265193997, ... 
        -0.0178318342,  -0.0080790588,   0.0253835248,  -0.0189433683, ... 
        -0.0017905987,   0.0055522106,  -0.0051442073,   0.0003773102, ... 
         0.0009847268,  -0.0006328065,  -0.0011923754,   0.0030158402, ... 
        -0.0025421174 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi
cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0157069388,  -0.0180739765,   0.0014544326,   0.0158017903, ... 
        -0.0109376535,  -0.0134995899,   0.0368773478,  -0.0133998280, ... 
        -0.0307985430,   0.0166141850,   0.0296290876,  -0.0503465199, ... 
         0.0108677102,   0.0469808459,  -0.0465385978,  -0.0442618378, ... 
         0.1047936348,  -0.0404069275,  -0.1124081987,   0.2862717973, ... 
         0.6371289655,   0.2862717973,  -0.1124081987,  -0.0404069275, ... 
         0.1047936348,  -0.0442618378,  -0.0465385978,   0.0469808459, ... 
         0.0108677102,  -0.0503465199,   0.0296290876,   0.0166141850, ... 
        -0.0307985430,  -0.0133998280,   0.0368773478,  -0.0134995899, ... 
        -0.0109376535,   0.0158017903,   0.0014544326,  -0.0180739765, ... 
         0.0157069388 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_ac_coef.m.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
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

