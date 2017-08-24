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
a = [   0.0045648449,   0.0368305229,  -0.0458975597,  -0.0563324531, ... 
        0.1079232951,   0.1135595430,  -0.2061445808,   0.4519740716, ... 
       -0.5503142718,   0.2710045659,   0.0933672609 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_a_coef.m.ok"; fail; fi
cat > test_d_coef.m.ok << 'EOF'
d = [   1.0000000000,   0.0560653813,   0.5562080435,   0.0880256835, ... 
       -0.0713794237,  -0.0315154689,   0.0035929704,   0.0202224445, ... 
        0.0150605606,   0.0063771283,  -0.0000149336 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_d_coef.m.ok"; fail; fi
cat > test_aa_coef.m.ok << 'EOF'
aa = [  -0.0036580464,   0.0030370368,   0.0006776802,  -0.0040707052, ... 
         0.0033832296,   0.0005113801,  -0.0085370941,   0.0082378743, ... 
        -0.0003218516,  -0.0203627908,   0.0212189110,  -0.0001324178, ... 
        -0.0245135991,   0.0275778815,  -0.0001755970,  -0.0517110007, ... 
         0.0628843728,  -0.0004739776,  -0.1414917954,   0.2776465180, ... 
         0.6654961257,   0.2776465180,  -0.1414917954,  -0.0004739776, ... 
         0.0628843728,  -0.0517110007,  -0.0001755970,   0.0275778815, ... 
        -0.0245135991,  -0.0001324178,   0.0212189110,  -0.0203627908, ... 
        -0.0003218516,   0.0082378743,  -0.0085370941,   0.0005113801, ... 
         0.0033832296,  -0.0040707052,   0.0006776802,   0.0030370368, ... 
        -0.0036580464 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_aa_coef.m.ok"; fail; fi
cat > test_ac_coef.m.ok << 'EOF'
ac = [   0.0132390849,  -0.0133088895,  -0.0019623906,   0.0166056919, ... 
        -0.0107432351,  -0.0113415248,   0.0327791034,  -0.0131777714, ... 
        -0.0266613775,   0.0162259489,   0.0214335706,  -0.0406341957, ... 
         0.0076388406,   0.0437240969,  -0.0458061171,  -0.0387546053, ... 
         0.1008794630,  -0.0435601413,  -0.1096945904,   0.2931476842, ... 
         0.6249324247,   0.2931476842,  -0.1096945904,  -0.0435601413, ... 
         0.1008794630,  -0.0387546053,  -0.0458061171,   0.0437240969, ... 
         0.0076388406,  -0.0406341957,   0.0214335706,   0.0162259489, ... 
        -0.0266613775,  -0.0131777714,   0.0327791034,  -0.0113415248, ... 
        -0.0107432351,   0.0166056919,  -0.0019623906,  -0.0133088895, ... 
         0.0132390849 ]';
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

