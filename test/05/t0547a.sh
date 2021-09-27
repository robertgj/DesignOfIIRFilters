#!/bin/sh

prog=schurNSlattice_sqp_slb_bandpass_test.m
depends="schurNSlattice_sqp_slb_bandpass_test.m \
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
tf2schurNSlattice.m local_max.m x2tf.m tf2pa.m print_polynomial.m Abcd2tf.m \
sqp_bfgs.m armijo_kim.m updateWbfgs.m invSVD.m H2Asq.m H2T.m KW.m p2n60.m \
schurNSlattice2Abcd.oct schurNSscale.oct Abcd2H.oct spectralfactor.oct \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct qroots.m qzsolve.oct"

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
s10_2 = [  -1.3442210282,  -1.1708591463,  -1.3701441259,  -0.5525113866, ... 
            0.6712915291,   0.9090299447,   0.5626850335,   0.0304185706, ... 
           -0.3304555289,  -0.3043146220,  -0.2494769827,  -0.3134528559, ... 
           -0.5408809554,  -0.5205390902,   0.1377893381,   0.5041797374, ... 
           -0.0782838914,  -0.1315005451,   0.2022396023,   0.0085900656 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s10.ok"; fail; fi

cat > test.s11.ok << 'EOF'
s11_2 = [   1.4071571655,   0.5065575122,   0.8280881464,   1.2186212715, ... 
            1.3944348475,   0.9291019545,   1.0184526609,   1.1201173088, ... 
            1.3767622592,   1.2405716214,   2.3623183094,   0.8263296106, ... 
            0.9819493423,   1.3728452765,   2.2515046945,   1.5809206421, ... 
            1.1020741346,   0.7570071306,   0.6752352655,   0.1092354051 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s11.ok"; fail; fi

cat > test.s20.ok << 'EOF'
s20_2 = [   0.0000000000,   0.4177126892,   0.0000000000,   0.5021998483, ... 
            0.0000000000,  -0.0342169493,   0.0000000000,   0.9825917962, ... 
            0.0000000000,  -0.3268314878,   0.0000000000,   0.9999000000, ... 
            0.0000000000,   0.7038158386,   0.0000000000,  -0.9421356649, ... 
            0.0000000000,   0.4772157794,   0.0000000000,   0.1215766546 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s20.ok"; fail; fi

cat > test.s00.ok << 'EOF'
s00_2 = [   1.0000000000,   0.5889960357,   1.0000000000,   0.5969033005, ... 
            1.0000000000,   0.7971266404,   1.0000000000,   0.9482762160, ... 
            1.0000000000,   0.8792339730,   1.0000000000,   0.9630355640, ... 
            1.0000000000,   0.9999000000,   1.0000000000,   0.9986633554, ... 
            1.0000000000,   0.6826563110,   1.0000000000,   0.3219691719 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s00.ok"; fail; fi

cat > test.s02.ok << 'EOF'
s02_2 = [  -0.0000000000,  -0.5189659505,  -0.0000000000,  -0.9371482221, ... 
           -0.0000000000,  -0.3168865169,  -0.0000000000,  -0.4473974334, ... 
           -0.0000000000,  -0.2138873318,  -0.0000000000,  -0.6091367317, ... 
           -0.0000000000,  -0.4918582532,  -0.0000000000,  -0.2574539979, ... 
           -0.0000000000,  -0.2259878725,  -0.0000000000,  -0.3298861840 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.s02.ok"; fail; fi

cat > test.s22.ok << 'EOF'
s22_2 = [   1.0000000000,   0.3830035840,   1.0000000000,   0.0586219722, ... 
            1.0000000000,   0.6704475814,   1.0000000000,   0.8998286499, ... 
            1.0000000000,   0.9999000000,   1.0000000000,   0.9999000000, ... 
            1.0000000000,   0.9192285258,   1.0000000000,   0.9960076504, ... 
            1.0000000000,   0.7349101303,   1.0000000000,   0.9925820455 ];
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

