#!/bin/sh

prog=schurOneMAPlattice_frm_halfband_socp_slb_test.m

depends="schurOneMAPlattice_frm_halfband_socp_slb_test.m test_common.m \
schurOneMAPlattice_frm_halfband_socp_mmse.m \
schurOneMAPlattice_frm_halfband_slb.m \
schurOneMAPlattice_frm_halfband_slb_constraints_are_empty.m \
schurOneMAPlattice_frm_halfband_slb_exchange_constraints.m \
schurOneMAPlattice_frm_halfband_slb_set_empty_constraints.m \
schurOneMAPlattice_frm_halfband_slb_show_constraints.m \
schurOneMAPlattice_frm_halfband_slb_update_constraints.m \
schurOneMAPlattice_frm_halfband_socp_slb_plot.m schurOneMAPlattice2tf.m \
schurOneMAPlattice_frm_halfbandEsq.m schurOneMAPlattice_frm_halfbandT.m \
schurOneMAPlattice_frm_halfbandAsq.m schurOneMAPlatticeP.m \
schurOneMAPlatticeT.m tf2schurOneMlattice.m schurOneMAPlattice2Abcd.m \
Abcd2tf.m tf2pa.m schurOneMscale.m H2Asq.m H2P.m H2T.m \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct spectralfactor.oct \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
local_max.m print_polynomial.m print_pole_zero.m SeDuMi_1_3/"

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
cat > test_r2_coef.m << 'EOF'
r2 = [   1.0000000000,   0.4798972922,  -0.1016479773,   0.0351951888, ... 
        -0.0126520471,   0.0020565211 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_r2_coef.m"; fail; fi
cat > test_k2_coef.m << 'EOF'
k2 = [   0.5541159714,  -0.1235054400,   0.0419578980,  -0.0136390237, ... 
         0.0020565211 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k2_coef.m"; fail; fi
cat > test_u2_coef.m << 'EOF'
u2 = [  -0.0005745653,   0.0023384306,  -0.0070502278,   0.0130140428, ... 
        -0.0310645326,   0.0344544514,  -0.0508990361,   0.0577324312, ... 
         0.4385696117 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_u2_coef.m"; fail; fi
cat > test_v2_coef.m << 'EOF'
v2 = [   0.0066212307,  -0.0044127894,   0.0067211174,  -0.0028602101, ... 
        -0.0069802620,   0.0308565055,  -0.0815328874,   0.3143514031 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_v2_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_r2_coef.m schurOneMAPlattice_frm_halfband_socp_slb_test_r2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_r2_coef.m"; fail; fi
diff -Bb test_k2_coef.m schurOneMAPlattice_frm_halfband_socp_slb_test_k2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k2_coef.m"; fail; fi
diff -Bb test_u2_coef.m schurOneMAPlattice_frm_halfband_socp_slb_test_u2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_u2_coef.m"; fail; fi
diff -Bb test_v2_coef.m schurOneMAPlattice_frm_halfband_socp_slb_test_v2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_v2_coef.m"; fail; fi

#
# this much worked
#
pass

