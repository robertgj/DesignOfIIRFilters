#!/bin/sh

prog=bitflip_bandpass_OneM_lattice_test.m
depends="bitflip_bandpass_OneM_lattice_test.m test_common.m \
bitflip_bandpass_test_common.m schurOneMlattice_cost.m schurOneMlattice2tf.m \
schurdecomp.oct schurexpand.oct bin2SD.oct flt2SD.m x2nextra.m bitflip.oct \
tf2schurOneMlattice.m schurOneMlatticeNoiseGain.m schurOneMlattice2Abcd.oct \
Abcd2tf.m schurOneMscale.m print_polynomial.m bin2SPT.oct schurOneMlatticeAsq.m \
schurOneMlattice2H.oct complex_zhong_inverse.oct H2Asq.m schurOneMlatticeEsq.m \
schurOneMlatticeT.m H2T.m bin2SDul.m schurOneMlattice_allocsd_Lim.m SDadders.m \
schurOneMlattice_allocsd_Ito.m"

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
cat > test.k_ex.ok << 'EOF'
k_ex = [   0.0000000000,   0.7864559535,   0.0000000000,   0.5199883943, ... 
           0.0000000000,   0.3748339116,   0.0000000000,   0.4165535431, ... 
           0.0000000000,   0.3429075433,   0.0000000000,   0.2774570212, ... 
           0.0000000000,   0.1813292593,   0.0000000000,   0.1190635838, ... 
           0.0000000000,   0.0502527105,   0.0000000000,   0.0186365784 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_ex.ok"; fail; fi
cat > test.c_ex.ok << 'EOF'
c_ex = [   0.0774993960,   0.0297036121,  -0.2481854230,  -0.6634416943, ... 
          -0.3305275325,   0.0236518775,   0.2064969599,   0.2216127935, ... 
           0.1093848637,  -0.0724563024,  -0.0523070973,  -0.0073022449, ... 
          -0.0104117705,  -0.0526907120,  -0.0476225261,  -0.0086413048, ... 
           0.0185928090,   0.0167985527,   0.0048972319,   0.0033403128, ... 
           0.0127469845 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_ex.ok"; fail; fi
cat > test.k_rd.ok << 'EOF'
k_rd = [  0.00000,  0.78125,  0.00000,  0.53125, ... 
          0.00000,  0.37500,  0.00000,  0.40625, ... 
          0.00000,  0.34375,  0.00000,  0.28125, ... 
          0.00000,  0.18750,  0.00000,  0.12500, ... 
          0.00000,  0.06250,  0.00000,  0.03125 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_rd.ok"; fail; fi
cat > test.c_rd.ok << 'EOF'
c_rd = [  0.06250,  0.03125, -0.25000, -0.65625, ... 
         -0.31250,  0.03125,  0.21875,  0.21875, ... 
          0.09375, -0.06250, -0.06250, -0.00000, ... 
         -0.00000, -0.06250, -0.06250, -0.00000, ... 
          0.03125,  0.03125,  0.00000,  0.00000, ... 
          0.00000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_rd.ok"; fail; fi
cat > test.k_bf.ok << 'EOF'
k_bf = [  0.00000,  0.78125,  0.00000,  0.53125, ... 
          0.00000,  0.34375,  0.00000,  0.43750, ... 
          0.00000,  0.34375,  0.00000,  0.28125, ... 
          0.00000,  0.18750,  0.00000,  0.15625, ... 
          0.00000,  0.06250,  0.00000,  0.03125 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bf.ok"; fail; fi
cat > test.c_bf.ok << 'EOF'
c_bf = [  0.09375,  0.03125, -0.25000, -0.65625, ... 
         -0.31250,  0.03125,  0.21875,  0.21875, ... 
          0.09375, -0.06250, -0.06250, -0.00000, ... 
         -0.00000, -0.06250, -0.06250, -0.00000, ... 
          0.03125,  0.03125,  0.00000,  0.00000, ... 
          0.00000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_bf.ok"; fail; fi
cat > test.k_sd.ok << 'EOF'
k_sd = [  0.00000,  0.78125,  0.00000,  0.53125, ... 
          0.00000,  0.37500,  0.00000,  0.40625, ... 
          0.00000,  0.34375,  0.00000,  0.28125, ... 
          0.00000,  0.18750,  0.00000,  0.12500, ... 
          0.00000,  0.06250,  0.00000,  0.03125 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_sd.ok"; fail; fi
cat > test.c_sd.ok << 'EOF'
c_sd = [  0.06250,  0.03125, -0.25000, -0.65625, ... 
         -0.31250,  0.03125,  0.21875,  0.21875, ... 
          0.09375, -0.06250, -0.06250,  0.00000, ... 
          0.00000, -0.06250, -0.06250,  0.00000, ... 
          0.03125,  0.03125, -0.00000, -0.00000, ... 
         -0.00000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_sd.ok"; fail; fi
cat > test.k_bfsd.ok << 'EOF'
k_bfsd = [  0.00000,  0.78125,  0.00000,  0.53125, ... 
            0.00000,  0.34375,  0.00000,  0.43750, ... 
            0.00000,  0.34375,  0.00000,  0.28125, ... 
            0.00000,  0.18750,  0.00000,  0.15625, ... 
            0.00000,  0.06250,  0.00000,  0.03125 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bfsd.ok"; fail; fi
cat > test.c_bfsd.ok << 'EOF'
c_bfsd = [  0.09375,  0.03125, -0.25000, -0.65625, ... 
           -0.31250,  0.03125,  0.21875,  0.21875, ... 
            0.09375, -0.06250, -0.06250,  0.00000, ... 
            0.00000, -0.06250, -0.06250,  0.00000, ... 
            0.03125,  0.03125,  0.00000,  0.00000, ... 
            0.00000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_bfsd.ok"; fail; fi
cat > test.k_bfsdl.ok << 'EOF'
k_bfsdl = [  0.00000,  0.81250,  0.00000,  0.56250, ... 
             0.00000,  0.31250,  0.00000,  0.43750, ... 
             0.00000,  0.34375,  0.00000,  0.28125, ... 
             0.00000,  0.18750,  0.00000,  0.15625, ... 
             0.00000,  0.06250,  0.00000,  0.03125 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bfsdl.ok"; fail; fi
cat > test.c_bfsdl.ok << 'EOF'
c_bfsdl = [  0.06250,  0.03125, -0.25000, -0.65625, ... 
            -0.31250,  0.03125,  0.21875,  0.21875, ... 
             0.09375, -0.06250, -0.06250,  0.00000, ... 
             0.00000, -0.06250, -0.06250,  0.00000, ... 
             0.03125,  0.03125,  0.00000,  0.00000, ... 
             0.00000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_bfsdl.ok"; fail; fi
cat > test.k_bfsdi.ok << 'EOF'
k_bfsdi = [  0.00000,  0.75000,  0.00000,  0.50000, ... 
             0.00000,  0.28125,  0.00000,  0.40625, ... 
             0.00000,  0.34375,  0.00000,  0.21875, ... 
             0.00000,  0.18750,  0.00000,  0.12500, ... 
             0.00000,  0.06250,  0.00000,  0.00000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bfsdi.ok"; fail; fi
cat > test.c_bfsdi.ok << 'EOF'
c_bfsdi = [  0.06250,  0.00000, -0.25000, -0.50000, ... 
            -0.25000,  0.06250,  0.25000,  0.25000, ... 
             0.12500, -0.06250, -0.06250,  0.00000, ... 
             0.00000, -0.06250, -0.06250,  0.00000, ... 
             0.03125,  0.03125,  0.00000,  0.00000, ... 
             0.00000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c_bfsdi.ok"; fail; fi
cat > test.adders_bfsd.ok << 'EOF'
$18$
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.adders_bfsd.ok"; fail; fi
cat > test.adders_Lim.ok << 'EOF'
$16$
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.adders_Lim.ok"; fail; fi
cat > test.adders_Ito.ok << 'EOF'
$8$
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.adders_Ito.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.k_rd.ok bitflip_bandpass_OneM_lattice_test_k_rd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_rd.ok"; fail; fi
diff -Bb test.c_rd.ok bitflip_bandpass_OneM_lattice_test_c_rd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_rd.ok"; fail; fi
diff -Bb test.k_bf.ok bitflip_bandpass_OneM_lattice_test_k_bf_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_bf.ok"; fail; fi
diff -Bb test.c_bf.ok bitflip_bandpass_OneM_lattice_test_c_bf_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_bf.ok"; fail; fi
diff -Bb test.k_sd.ok bitflip_bandpass_OneM_lattice_test_k_sd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_sd.ok"; fail; fi
diff -Bb test.c_sd.ok bitflip_bandpass_OneM_lattice_test_c_sd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_sd.ok"; fail; fi
diff -Bb test.k_bfsd.ok bitflip_bandpass_OneM_lattice_test_k_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_bfsd.ok"; fail; fi
diff -Bb test.c_bfsd.ok bitflip_bandpass_OneM_lattice_test_c_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_bfsd.ok"; fail; fi
diff -Bb test.k_bfsdl.ok bitflip_bandpass_OneM_lattice_test_k_bfsdl_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_bfsdl.ok"; fail; fi
diff -Bb test.c_bfsdl.ok bitflip_bandpass_OneM_lattice_test_c_bfsdl_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_bfsdl.ok"; fail; fi
diff -Bb test.k_bfsdi.ok bitflip_bandpass_OneM_lattice_test_k_bfsdi_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_bfsdi.ok"; fail; fi
diff -Bb test.c_bfsdi.ok bitflip_bandpass_OneM_lattice_test_c_bfsdi_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.c_bfsdi.ok"; fail; fi
diff -Bb test.adders_bfsd.ok bitflip_bandpass_OneM_lattice_test_adders_bfsd.tab
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.adders_bfsd.ok"; fail; fi
diff -Bb test.adders_Lim.ok bitflip_bandpass_OneM_lattice_test_adders_Lim.tab
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.adders_Lim.ok"; fail; fi
diff -Bb test.adders_Ito.ok bitflip_bandpass_OneM_lattice_test_adders_Ito.tab
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.adders_Ito.ok"; fail; fi

#
# this much worked
#
pass

