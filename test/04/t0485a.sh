#!/bin/sh

prog=iir_socp_slb_multiband_test.m

depends="test/iir_socp_slb_multiband_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m x2zp.m \
phi2p.m tfp2g.m local_max.m tf2x.m zp2x.m x2tf.m xConstraints.m qroots.m \
qzsolve.oct"

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
cat > test_x2.ok << 'EOF'
Ux2=2,Vx2=0,Mx2=18,Qx2=20,Rx2=1
x2 = [   0.0502596081, ...
        -0.9961275860,   0.9930631866, ...
         0.9135162576,   0.9302346419,   0.9473744518,   0.9690485531, ... 
         0.9698188869,   0.9799202602,   0.9958962684,   0.9968095782, ... 
         0.9977177614, ...
         0.4772312911,   1.0586799798,   1.5039045996,   0.8498218010, ... 
         0.6608220278,   0.4355677165,   1.0891590910,   1.4236806266, ... 
         0.6349861296, ...
         0.9079743178,   0.9422193664,   0.9495733620,   0.9554948943, ... 
         0.9661518000,   0.9828244933,   0.9873943588,   0.9944620161, ... 
         0.9953330348,   0.9967046066, ...
         1.2417239145,   0.5678343079,   0.5041507413,   1.3961284923, ... 
         1.1210210960,   0.6282663990,   0.4688251663,   1.4155836184, ... 
         1.0980512522,   0.6329518479 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x2.ok"; fail; fi

cat > test_N2.ok << 'EOF'
N2 = [     0.0502596081,    -0.5059674490,     2.5649087948,    -8.6120652367, ... 
          21.2808577996,   -40.6877518260,    61.4589104744,   -72.9790806268, ... 
          64.8134995109,   -34.5032266034,    -8.6318012330,    47.8649716207, ... 
         -68.9682690106,    68.0811735749,   -51.9379578273,    31.5563726113, ... 
         -15.2447571014,     5.7184046305,    -1.5817894973,     0.2901263066, ... 
          -0.0268098084 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N2.ok"; fail; fi

cat > test_D2.ok << 'EOF'
D2 = [     1.0000000000,   -11.1837638559,    64.1217291833,  -248.2648641779, ... 
         724.0491462064, -1684.3732486992,  3234.2185491611, -5238.3466455247, ... 
        7258.1764872940, -8679.9007375001,  9002.9872928950, -8112.0552474656, ... 
        6339.8173145332, -4276.7486117574,  2468.4463735916, -1202.0740432300, ... 
         483.3479152202,  -155.1126967928,    37.5259826481,    -6.1378230584, ... 
           0.5155076298 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_D2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x2.ok iir_socp_slb_multiband_test_x2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x2.ok"; fail; fi

diff -Bb test_N2.ok iir_socp_slb_multiband_test_N2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N2.ok"; fail; fi

diff -Bb test_D2.ok iir_socp_slb_multiband_test_D2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_D2.ok"; fail; fi

#
# this much worked
#
pass

