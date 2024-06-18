#!/bin/sh

prog=schurNSlattice_sqp_slb_bandpass_test.m
depends="test/schurNSlattice_sqp_slb_bandpass_test.m \
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
schurNSlattice_sqp_slb_bandpass_plot.m \
schurNSlattice2tf.m \
schurNSlatticeFilter.m \
crossWelch.m \
tf2schurNSlattice.m local_max.m x2tf.m tf2pa.m print_polynomial.m \
sqp_bfgs.m armijo_kim.m updateWbfgs.m invSVD.m H2Asq.m H2T.m KW.m p2n60.m \
schurNSlattice2Abcd.oct schurNSscale.oct Abcd2H.oct spectralfactor.oct \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct qroots.m qzsolve.oct \
Abcd2tf.oct"

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
s10_2 = [  -0.6116072803,  -1.0598826254,  -1.1932962059,  -0.4195022644, ... 
            1.1681222162,   1.0389299420,   0.5224542300,  -0.2397941919, ... 
           -0.5045656001,  -0.1363727666,   0.1325887121,  -0.4137197075, ... 
           -0.3999311792,  -0.3283232229,   1.0824998165,   0.9020436109, ... 
           -0.5671900765,   0.0389933566,   0.5097577811,   0.0081609903 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi

cat > test.s11.ok << 'EOF'
s11_2 = [   0.7721081625,   0.3663783574,   0.8915754705,   1.1091244289, ... 
            1.1984045597,   0.7171472399,   1.0535824577,   1.1490314010, ... 
            1.4159849110,   1.3323899866,   2.8073085795,   0.7863829986, ... 
            0.7660600899,   2.3167214048,   2.5633740389,   1.8762701398, ... 
            0.9943937410,   0.3414305006,   1.0940500867,   0.0495531758 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s11.ok"; fail; fi

cat > test.s20.ok << 'EOF'
s20_2 = [   0.0000000000,   0.3225511304,   0.0000000000,   0.4555468568, ... 
            0.0000000000,   0.4796479452,   0.0000000000,   0.4481272078, ... 
            0.0000000000,  -0.1298600943,   0.0000000000,  -0.3334209377, ... 
            0.0000000000,   0.6736375802,   0.0000000000,   0.7579781156, ... 
            0.0000000000,  -0.5631722547,   0.0000000000,   0.1215766546 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s20.ok"; fail; fi

cat > test.s00.ok << 'EOF'
s00_2 = [   1.0000000000,   0.9990000000,   1.0000000000,   0.8705547775, ... 
            1.0000000000,   0.8740463167,   1.0000000000,   0.9111360631, ... 
            1.0000000000,   0.8385544360,   1.0000000000,   0.7464619947, ... 
            1.0000000000,   0.7862901655,   1.0000000000,   0.9990000000, ... 
            1.0000000000,   0.9990000000,   1.0000000000,   0.6367279048 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s00.ok"; fail; fi

cat > test.s02.ok << 'EOF'
s02_2 = [  -0.0000000000,  -0.6960318354,  -0.0000000000,  -0.8631065798, ... 
           -0.0000000000,  -0.3255801252,  -0.0000000000,  -0.5755112099, ... 
           -0.0000000000,  -0.2854159236,  -0.0000000000,  -0.5607581974, ... 
           -0.0000000000,  -0.3540472579,  -0.0000000000,  -0.5950495033, ... 
           -0.0000000000,   0.0573675332,  -0.0000000000,  -0.5504569305 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s02.ok"; fail; fi

cat > test.s22.ok << 'EOF'
s22_2 = [   1.0000000000,   0.1025824211,   1.0000000000,   0.2099969225, ... 
            1.0000000000,   0.6970619049,   1.0000000000,   0.9487614496, ... 
            1.0000000000,   0.9724846033,   1.0000000000,   0.9801947418, ... 
            1.0000000000,   0.9961939253,   1.0000000000,  -0.0354044891, ... 
            1.0000000000,   0.9990000000,   1.0000000000,   0.9925820455 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s22.ok"; fail; fi


# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.s10.ok schurNSlattice_sqp_slb_bandpass_test_s10_2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s10.ok"; fail; fi

diff -Bb test.s11.ok schurNSlattice_sqp_slb_bandpass_test_s11_2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s11.ok"; fail; fi

diff -Bb test.s20.ok schurNSlattice_sqp_slb_bandpass_test_s20_2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s20.ok"; fail; fi

diff -Bb test.s00.ok schurNSlattice_sqp_slb_bandpass_test_s00_2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s00.ok"; fail; fi

diff -Bb test.s02.ok schurNSlattice_sqp_slb_bandpass_test_s02_2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s02.ok"; fail; fi

diff -Bb test.s22.ok schurNSlattice_sqp_slb_bandpass_test_s22_2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.s22.ok"; fail; fi

#
# this much worked
#
pass

