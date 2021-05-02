#!/bin/sh

prog=schurOneMAPlattice_frm_socp_slb_test.m

depends="schurOneMAPlattice_frm_socp_slb_test.m test_common.m \
schurOneMAPlattice_frm_slb.m \
schurOneMAPlattice_frm_socp_mmse.m \
schurOneMAPlattice_frm_slb_set_empty_constraints.m \
schurOneMAPlattice_frm_slb_constraints_are_empty.m \
schurOneMAPlattice_frm_slb_update_constraints.m \
schurOneMAPlattice_frm_slb_exchange_constraints.m \
schurOneMAPlattice_frm_slb_show_constraints.m \
schurOneMAPlattice_frm_socp_slb_plot.m \
schurOneMAPlattice_frm.m \
schurOneMAPlattice_frmEsq.m schurOneMAPlattice_frmT.m \
schurOneMAPlattice_frmAsq.m schurOneMAPlattice_frmP.m \
schurOneMAPlattice2tf.m tf2schurOneMlattice.m \
schurOneMAPlatticeP.m schurOneMAPlatticeT.m  \
schurOneMAPlattice2Abcd.m Abcd2tf.m tf2pa.m schurOneMscale.m \
H2Asq.m H2P.m H2T.m local_max.m \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct \
spectralfactor.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
print_polynomial.m print_pole_zero.m qroots.m qzsolve.oct"

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
cat > test_k1_coef.m << 'EOF'
k1 = [  -0.0146211106,   0.5777414027,   0.0181702261,  -0.1428708243, ... 
        -0.0045559735,   0.0545939011,   0.0099115903,  -0.0279491983, ... 
        -0.0043777543,   0.0086675795 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k1_coef.m"; fail; fi

cat > test_epsilon1_coef.m << 'EOF'
epsilon1 = [  1,  1, -1,  1, ... 
              1, -1, -1,  1, ... 
              1, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_epsilon1_coef.m"; fail; fi

cat > test_u1_coef.m << 'EOF'
u1 = [   0.5698720310,   0.3066139370,  -0.0622874460,  -0.0846974802, ... 
         0.0503130252,   0.0341474095,  -0.0429614935,  -0.0058587109, ... 
         0.0349980389,  -0.0115266842,  -0.0173788251,   0.0128969260, ... 
         0.0100895313,  -0.0087030450,  -0.0047145346,   0.0083435145, ... 
        -0.0004541138,  -0.0075994376,   0.0045979132,   0.0025210304, ... 
        -0.0039022018 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_u1_coef.m"; fail; fi

cat > test_v1_coef.m << 'EOF'
v1 = [  -0.6661044946,  -0.2735403306,   0.1346966860,   0.0031754878, ... 
        -0.0651379084,   0.0491337252,   0.0028885497,  -0.0337456463, ... 
         0.0281133985,  -0.0004993262,  -0.0182710308,   0.0157696235, ... 
         0.0015726826,  -0.0101280774,   0.0079311008,   0.0013575676, ... 
        -0.0066956214,   0.0060711378,  -0.0010413743,  -0.0025151577, ... 
         0.0030291400 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_v1_coef.m"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr=schurOneMAPlattice_frm_socp_slb_test
diff -Bb test_k1_coef.m $nstr"_k1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k1_coef.m"; fail; fi

diff -Bb test_epsilon1_coef.m $nstr"_epsilon1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_epsilon1_coef.m"; fail; fi

diff -Bb test_u1_coef.m $nstr"_u1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_u1_coef.m"; fail; fi

diff -Bb test_v1_coef.m $nstr"_v1_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_v1_coef.m"; fail; fi

#
# this much worked
#
pass

