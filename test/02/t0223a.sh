#!/bin/sh

prog=bitflip_schurFIRlattice_bandpass_test.m
depends="bitflip_schurFIRlattice_bandpass_test.m test_common.m \
bitflip_bandpass_test_common.m flt2SD.m schurFIRlattice2Abcd.m \
Abcd2tf.m print_polynomial.m x2nextra.m SDadders.m \
bin2SPT.oct bin2SD.oct schurFIRdecomp.oct bitflip.oct"

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
k_ex = [   0.4593466811,   0.0207755511,  -0.4543038955,  -0.5752634543, ... 
          -0.3661751825,   0.1513717747,   0.4876634116,   0.4458838158, ... 
           0.0642635216,  -0.3825130725,  -0.5970105299,  -0.7283202009, ... 
          -0.8093612951,   0.6805119912,  -0.6076281309,   0.2553781860 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_ex.ok"; fail; fi

cat > test.k_rd.ok << 'EOF'
k_rd = [       59,        3,      -58,      -74, ... 
              -47,       19,       62,       57, ... 
                8,      -49,      -76,      -93, ... 
             -104,       87,      -78,       33 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_rd.ok"; fail; fi

cat > test.k_bf.ok << 'EOF'
k_bf = [       63,       10,      -58,      -74, ... 
              -47,       32,       63,       63, ... 
               32,      -49,      -76,      -93, ... 
             -104,       79,      -78,       19 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bf.ok"; fail; fi

cat > test.k_sd.ok << 'EOF'
k_sd = [       60,        3,      -56,      -72, ... 
              -48,       20,       62,       56, ... 
                8,      -48,      -80,      -96, ... 
              -96,       80,      -80,       33 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_sd.ok"; fail; fi

cat > test.k_bfsd.ok << 'EOF'
k_bfsd = [       60,       10,      -56,      -72, ... 
                -48,       33,       63,       63, ... 
                 32,      -48,      -80,      -96, ... 
                -96,       80,      -80,       24 ]/128;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k_bfsd.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.k_ex.ok bitflip_schurFIRlattice_bandpass_test_k_ex_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_ex.ok"; fail; fi
diff -Bb test.k_rd.ok bitflip_schurFIRlattice_bandpass_test_k_rd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_rd.ok"; fail; fi
diff -Bb test.k_bf.ok bitflip_schurFIRlattice_bandpass_test_k_bf_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_bf.ok"; fail; fi
diff -Bb test.k_sd.ok bitflip_schurFIRlattice_bandpass_test_k_sd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_sd.ok"; fail; fi
diff -Bb test.k_bfsd.ok bitflip_schurFIRlattice_bandpass_test_k_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.k_bfsd.ok"; fail; fi

#
# this much worked
#
pass

