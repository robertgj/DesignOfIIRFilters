#!/bin/sh

prog=pop_relaxation_bandpass_OneM_lattice_10_nbits_test.m

depends="pop_relaxation_bandpass_OneM_lattice_10_nbits_test.m \
schurOneMlattice_bandpass_10_nbits_common.m test_common.m \
schurOneMlatticeAsq.m schurOneMlatticeT.m schurOneMlatticeP.m \
schurOneMlatticeEsq.m \
schurOneMlattice_socp_mmse.m \
schurOneMlattice_pop_socp_mmse.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMscale.m schurOneMlattice2tf.m schurOneMlattice_allocsd_Ito.m \
schurOneMlatticeFilter.m tf2schurOneMlattice.m local_max.m print_polynomial.m \
Abcd2tf.m x2nextra.m H2Asq.m H2T.m H2P.m flt2SD.m bin2SDul.m SDadders.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2H.oct schurOneMlattice2Abcd.oct bin2SPT.oct bin2SD.oct \
SeDuMi_1_3/ SparsePOP302/"
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
cat > test.k.ok << 'EOF'
512*k_min = [      0,    336,      0,    264, ... 
                   0,    176,      0,    216, ... 
                   0,    146,      0,    127, ... 
                   0,     74,      0,     52, ... 
                   0,     17,      0,      8 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k2.ok"; fail; fi
cat > test.c.ok << 'EOF'
512*c_min = [     40,     -2,   -144,   -256, ... 
                 -94,     48,    193,    160, ... 
                  15,    -40,    -40,     -8, ... 
                  -2,    -16,    -12,      1, ... 
                  12,      8,      0,     -1, ... 
                   2 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.c.ok \
     pop_relaxation_bandpass_OneM_lattice_10_nbits_test_c_min_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.c.ok"; fail; fi
diff -Bb test.k.ok \
     pop_relaxation_bandpass_OneM_lattice_10_nbits_test_k_min_coef.m

if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.k.ok"; fail; fi

#
# this much worked
#
pass
