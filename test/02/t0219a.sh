#!/bin/sh

prog=schurNSlattice_sqp_slb_lowpass_test.m
depends="test/schurNSlattice_sqp_slb_lowpass_test.m \
test_common.m \
schurNSlatticeAsq.m \
schurNSlatticeT.m \
schurNSlatticeEsq.m \
schurNSlattice_slb.m \
schurNSlattice_slb_constraints_are_empty.m \
schurNSlattice_sqp_mmse.m \
schurNSlattice_slb_exchange_constraints.m \
schurNSlattice_slb_set_empty_constraints.m \
schurNSlattice_slb_show_constraints.m \
schurNSlattice_slb_update_constraints.m \
schurNSlattice_sqp_slb_lowpass_plot.m \
schurNSlattice2tf.m \
schurNSlatticeFilter.m \
tf2schurNSlattice.m local_max.m x2tf.m tf2pa.m print_polynomial.m Abcd2tf.m \
sqp_bfgs.m armijo_kim.m updateWbfgs.m invSVD.m H2Asq.m H2T.m KW.m \
schurNSlattice2Abcd.oct schurNSscale.oct Abcd2H.oct \
spectralfactor.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
qroots.m qzsolve.oct"

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
cat > test.s10.ok << 'EOF'
s10_2 = [   0.9264513567,   0.1152940006,  -0.1192003216,  -0.0441970678, ... 
            0.0232422300,   0.0259930923,  -0.0034407910,  -0.0128985630, ... 
           -0.0024065496,   0.0054752723 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi

cat > test.s11.ok << 'EOF'
s11_2 = [   1.0052477837,   0.9082044912,   0.9761300906,   1.0094266892, ... 
            1.0854082474,   1.0316983639,   1.0592144362,   1.0687664900, ... 
            1.0739802683,   0.7412544053 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi

cat > test.s20.ok << 'EOF'
s20_2 = [  -0.5970533029,   0.7171705548,  -0.5056592608,  -0.1136577915, ... 
            0.9839704466,   0.0441000000,   0.0000000000,   0.0000000000, ... 
            0.0000000000,   0.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s20.ok"; fail; fi

cat > test.s00.ok << 'EOF'
s00_2 = [   0.8035005457,   0.5774865137,   0.7368565622,   0.8659868445, ... 
            0.8044284234,   0.9999000000,   1.0000000000,   1.0000000000, ... 
            1.0000000000,   1.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s00.ok"; fail; fi

cat > test.s02.ok << 'EOF'
s02_2 = [   0.7712564164,  -0.7446390770,   0.6815569172,  -0.5657532054, ... 
            0.4200140379,  -0.1741629822,  -0.0000000000,  -0.0000000000, ... 
           -0.0000000000,  -0.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s02.ok"; fail; fi

cat > test.s22.ok << 'EOF'
s22_2 = [   0.6615901421,   0.8950771164,   0.9158924916,   0.8838964529, ... 
            0.9946619491,   0.9990271218,   1.0000000000,   1.0000000000, ... 
            1.0000000000,   1.0000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s22.ok"; fail; fi


# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="schurNSlattice_sqp_slb_lowpass_test"

diff -Bb test.s10.ok $nstr"_s10_2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s10.ok"; fail; fi

diff -Bb test.s11.ok $nstr"_s11_2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s11.ok"; fail; fi

diff -Bb test.s20.ok $nstr"_s20_2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s20.ok"; fail; fi

diff -Bb test.s00.ok $nstr"_s00_2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s00.ok"; fail; fi

diff -Bb test.s02.ok $nstr"_s02_2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s02.ok"; fail; fi

diff -Bb test.s22.ok $nstr"_s22_2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s22.ok"; fail; fi

#
# this much worked
#
pass

