#!/bin/sh

prog=bitflip_directFIRsymmetric_bandpass_test.m
depends="bitflip_directFIRsymmetric_bandpass_test.m test_common.m \
bitflip_bandpass_test_common.m \
directFIRsymmetricA.m \
directFIRsymmetricEsqPW.m \
directFIRsymmetric_allocsd_Ito.m \
directFIRsymmetric_allocsd_Lim.m \
print_polynomial.m flt2SD.m SDadders.m x2nextra.m bin2SDul.m \
bin2SD.oct bitflip.oct bin2SPT.oct"

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
cat > test.hM_ex.ok << 'EOF'
hM_ex = [  -0.0004538174,  -0.0114029873,  -0.0194431345,  -0.0069796479, ... 
            0.0215771882,   0.0348545408,   0.0158541332,  -0.0033225166, ... 
            0.0154055974,   0.0414424100,  -0.0021970758,  -0.1162784301, ... 
           -0.1760013118,  -0.0669604509,   0.1451751014,   0.2540400868 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.hM_ex.ok"; fail; fi

cat > test.hM_rd.ok << 'EOF'
hM_rd = [        0,       -3,       -5,       -2, ... 
                 6,        9,        4,       -1, ... 
                 4,       11,       -1,      -30, ... 
               -45,      -17,       37,       65 ]/256;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.hM_rd.ok"; fail; fi

cat > test.hM_bf.ok << 'EOF'
hM_bf = [        0,       -3,       -5,       -2, ... 
                 6,        9,        4,       -1, ... 
                 4,       11,       -1,      -30, ... 
               -45,      -17,       37,       65 ]/256;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.hM_bf.ok"; fail; fi

cat > test.hM_sd.ok << 'EOF'
hM_sd = [        0,       -3,       -5,       -2, ... 
                 6,        9,        4,       -1, ... 
                 4,       12,       -1,      -30, ... 
               -48,      -17,       36,       65 ]/256;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.hM_sd.ok"; fail; fi

cat > test.hM_bfsd.ok << 'EOF'
hM_bfsd = [        0,       -3,       -5,       -2, ... 
                   5,        8,        3,       -1, ... 
                   6,       12,       -1,      -30, ... 
                 -48,      -17,       36,       65 ]/256;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.hM_bfsd.ok"; fail; fi

cat > test.hM_bfsdi.ok << 'EOF'
hM_bfsdi = [        0,       -4,       -5,       -2, ... 
                    8,       10,        4,       -1, ... 
                    4,       10,       -1,      -30, ... 
                  -44,      -16,       36,       64 ]/256;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.hM_bfsdi.ok"; fail; fi

cat > test.hM_bfsdl.ok << 'EOF'
hM_bfsdl = [        0,       -3,       -5,        0, ... 
                    6,        8,        3,       -1, ... 
                    4,       11,        0,      -30, ... 
                  -44,      -17,       37,       64 ]/256;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.hM_bfsdl.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.hM_ex.ok bitflip_directFIRsymmetric_bandpass_test_hM_ex_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.hM_ex.ok"; fail; fi

diff -Bb test.hM_rd.ok bitflip_directFIRsymmetric_bandpass_test_hM_rd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.hM_rd.ok"; fail; fi

diff -Bb test.hM_bf.ok bitflip_directFIRsymmetric_bandpass_test_hM_bf_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.hM_bf.ok"; fail; fi

diff -Bb test.hM_sd.ok bitflip_directFIRsymmetric_bandpass_test_hM_sd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.hM_sd.ok"; fail; fi

diff -Bb test.hM_bfsd.ok bitflip_directFIRsymmetric_bandpass_test_hM_bfsd_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.hM_bfsd.ok"; fail; fi

diff -Bb test.hM_bfsdi.ok \
     bitflip_directFIRsymmetric_bandpass_test_hM_bfsdi_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.hM_bfsdi.ok"; fail; fi

diff -Bb test.hM_bfsdl.ok \
     bitflip_directFIRsymmetric_bandpass_test_hM_bfsdl_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.hM_bfsdl.ok"; fail; fi

#
# this much worked
#
pass

