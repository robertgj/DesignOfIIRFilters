#!/bin/sh

prog=socp_relaxation_schurFIRlattice_gaussian_16_nbits_test.m

depends="socp_relaxation_schurFIRlattice_gaussian_16_nbits_test.m \
test_common.m \
complementaryFIRlatticeAsq.m \
complementaryFIRlatticeT.m \
complementaryFIRlatticeP.m \
complementaryFIRlatticeEsq.m \
complementaryFIRlattice_slb.m \
complementaryFIRlattice_slb_constraints_are_empty.m \
complementaryFIRlattice_socp_mmse.m \
complementaryFIRlattice_slb_exchange_constraints.m \
complementaryFIRlattice_slb_set_empty_constraints.m \
complementaryFIRlattice_slb_show_constraints.m \
complementaryFIRlattice_slb_update_constraints.m \
complementaryFIRlattice.m \
complementaryFIRlatticeFilter.m \
complementaryFIRlattice2Abcd.m \
minphase.m local_max.m tf2pa.m x2tf.m print_polynomial.m Abcd2tf.m \
H2Asq.m H2T.m H2P.m flt2SD.m x2nextra.m bin2SDul.m SDadders.m \
bin2SD.oct bin2SPT.oct Abcd2H.oct complementaryFIRdecomp.oct \
qroots.m qzsolve.oct SeDuMi_1_3/"

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
cat > test.ok.k_min << 'EOF'
k_min = [    32768,    32768,    32768,    32768, ... 
             32768,    32768,    32768,    32767, ... 
             32766,    32760,    32745,    32709, ... 
             32636,    32519,    32368,    32236, ... 
             32182,    32236,    32368,    32519, ... 
             32636,    32709,    32745,    32760, ... 
             32766,    32767,    32768,    32768, ... 
             32768,    32768,    32768,    32768, ... 
                 0 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.k_min"; fail; fi
cat > test.ok.khat_min << 'EOF'
khat_min = [        0,        0,        0,       -4, ... 
                  -15,      -32,      -80,     -188, ... 
                 -376,     -704,    -1224,    -1972, ... 
                -2936,    -4032,    -5096,    -5880, ... 
                -6174,    -5880,    -5096,    -4033, ... 
                -2936,    -1972,    -1224,     -704, ... 
                 -376,     -184,      -80,      -32, ... 
                  -14,       -4,        0,        0, ... 
                32768 ]'/32768;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.khat_min"; fail; fi
cat > test.ok.cost_min << 'EOF'
16-bit 3-signed-digit(direct-folded)& 73 & 44 \\
16-bit 3-signed-digit(lattice)& 158 & 98 \\
16-bit 3-signed-digit(SOCP-relax) & 156 & 96 \\
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.cost_min"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok.k_min \
     socp_relaxation_schurFIRlattice_gaussian_16_nbits_test_k_min_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.k_min"; fail; fi

diff -Bb test.ok.khat_min \
     socp_relaxation_schurFIRlattice_gaussian_16_nbits_test_khat_min_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.khat_min"; fail; fi

diff -Bb test.ok.cost_min \
     socp_relaxation_schurFIRlattice_gaussian_16_nbits_test_kkhat_min_cost.tab
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.cost_min"; fail; fi


#
# this much worked
#
pass
