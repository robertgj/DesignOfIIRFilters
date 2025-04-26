
#!/bin/sh

prog=schurOneMlattice_piqp_slb_hilbert_R2_test.m

depends="test/schurOneMlattice_piqp_slb_hilbert_R2_test.m test_common.m \
../tarczynski_hilbert_R2_test_D0_coef.m \
../tarczynski_hilbert_R2_test_N0_coef.m \
schurOneMlatticeAsq.m \
schurOneMlatticeT.m \
schurOneMlatticeP.m \
schurOneMlatticedAsqdw.m \
schurOneMlatticeEsq.m \
schurOneMlattice_piqp_mmse.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMlattice_sqp_slb_hilbert_plot.m \
schurOneMlattice2tf.m \
schurOneMscale.m tf2schurOneMlattice.m qroots.oct \
local_max.m print_polynomial.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
spectralfactor.oct schurdecomp.oct schurexpand.oct Abcd2tf.oct \
complex_zhong_inverse.oct schurOneMlattice2H.oct schurOneMlattice2Abcd.oct"

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
cat > test_k2.ok << 'EOF'
k2 = [   0.0000000000,  -0.8296196530,   0.0000000000,   0.2994495578, ... 
         0.0000000000,  -0.0352336833,   0.0000000000,   0.0013656784, ... 
         0.0000000000,  -0.0003869366,   0.0000000000,   0.0002206744 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k2.ok"; fail; fi

cat > test_epsilon2.ok << 'EOF'
epsilon2 = [  0, -1,  0, -1, ... 
              0,  1,  0, -1, ... 
              0,  1,  0, -1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_epsilon2.ok"; fail; fi

cat > test_p2.ok << 'EOF'
p2 = [   2.3181713391,   2.3181713391,   0.7074159914,   0.7074159914, ... 
         0.9634626428,   0.9634626428,   0.9980286554,   0.9980286554, ... 
         0.9993925735,   0.9993925735,   0.9997793499,   0.9997793499 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_p2.ok"; fail; fi

cat > test_c2.ok << 'EOF'
c2 = [  -0.0432091371,  -0.0517538375,  -0.1578905945,  -0.1927001164, ... 
        -0.1801442383,  -0.2718993739,  -0.6900964422,   0.5839707857, ... 
         0.1577675589,   0.0729935297,   0.0376428021,   0.0192692054, ... 
         0.0090357688 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurOneMlattice_piqp_slb_hilbert_R2_test"

diff -Bb test_k2.ok $nstr"_k2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_k2.ok"; fail; fi

diff -Bb test_epsilon2.ok $nstr"_epsilon2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_epsilon2.ok"; fail; fi

diff -Bb test_p2.ok $nstr"_p2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_p2.ok"; fail; fi

diff -Bb test_c2.ok $nstr"_c2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_c2.ok"; fail; fi

#
# this much worked
#
pass
