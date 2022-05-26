#!/bin/sh

prog=mcclellanFIRantisymmetric_flat_differentiator_test.m

depends="test/mcclellanFIRantisymmetric_flat_differentiator_test.m test_common.m \
mcclellanFIRantisymmetric_flat_differentiator.m local_max.m print_polynomial.m"

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
cat > test_hAM56.ok << 'EOF'
hAM56 = [    -0.01531030,    -0.23478643,    -1.76854458,    -8.68730635, ... 
            -31.16393864,   -86.66178531,  -193.57895634,  -355.22831933, ... 
           -543.30151025,  -698.79388338,  -759.55566324,  -698.79388338, ... 
           -543.30151025,  -355.22831933,  -193.57895634,   -86.66178531, ... 
            -31.16393864,    -8.68730635,    -1.76854458,    -0.23478643, ... 
             -0.01531030 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hAM56.ok"; fail; fi

cat > test_hA56.ok << 'EOF'
hA56 = [ -0.000000058404,  0.000001148506, -0.000010149563,  0.000052336619, ... 
         -0.000169228693,  0.000332063601, -0.000295298046, -0.000223058511, ... 
          0.000763598521, -0.000052312773, -0.001620312061,  0.000881430845, ... 
          0.003043012039, -0.002731561660, -0.005347829463,  0.006247801265, ... 
          0.009138187852, -0.012293910355, -0.015574426173,  0.022033779263, ... 
          0.026987242013, -0.037276941813, -0.048841962924,  0.061868445297, ... 
          0.099478627507, -0.106970521253, -0.320625711125, -0.184443018840, ... 
          0.184443018826,  0.320625711170,  0.106970521175, -0.099478627401, ... 
         -0.061868445420,  0.048841963048,  0.037276941705, -0.026987241930, ... 
         -0.022033779319,  0.015574426207,  0.012293910337, -0.009138187844, ... 
         -0.006247801269,  0.005347829465,  0.002731561659, -0.003043012039, ... 
         -0.000881430845,  0.001620312061,  0.000052312773, -0.000763598521, ... 
          0.000223058511,  0.000295298046, -0.000332063601,  0.000169228693, ... 
         -0.000052336619,  0.000010149563, -0.000001148506,  0.000000058404 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hA56.ok"; fail; fi

cat > test_hAM57.ok << 'EOF'
hAM57 = [    -0.00699593,    -0.10941085,    -0.83993933,    -4.20010875, ... 
            -15.31443518,   -43.20558722,   -97.70187367,  -181.06887910, ... 
           -278.95168299,  -360.38502008,  -392.30820638,  -360.38502008, ... 
           -278.95168299,  -181.06887910,   -97.70187367,   -43.20558722, ... 
            -15.31443518,    -4.20010875,    -0.83993933,    -0.10941085, ... 
             -0.00699593 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hAM57.ok"; fail; fi

cat > test_hA57.ok << 'EOF'
hA57 = [ -0.000000026687,  0.000000490000, -0.000003958470,  0.000017980629, ... 
         -0.000047304433,  0.000057983906,  0.000034848673, -0.000205142638, ... 
          0.000104960387,  0.000475677202, -0.000593304133, -0.000865109279, ... 
          0.001806247068,  0.001319859178, -0.004353873501, -0.001749075510, ... 
          0.009179985235,  0.002096147899, -0.017729632353, -0.002508748862, ... 
          0.032351684085,  0.003724726890, -0.057627851331, -0.008372615640, ... 
          0.106138256967,  0.029574595700, -0.239992860846, -0.311662304083, ... 
         -0.000000000023,  0.311662304123,  0.239992860823, -0.029574595697, ... 
         -0.106138256955,  0.008372615619,  0.057627851351, -0.003724726905, ... 
         -0.032351684076,  0.002508748857,  0.017729632355, -0.002096147900, ... 
         -0.009179985234,  0.001749075509,  0.004353873501, -0.001319859178, ... 
         -0.001806247068,  0.000865109279,  0.000593304133, -0.000475677202, ... 
         -0.000104960387,  0.000205142638, -0.000034848673, -0.000057983906, ... 
          0.000047304433, -0.000017980629,  0.000003958470, -0.000000490000, ... 
          0.000000026687 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_hA57.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_hAM56.ok \
mcclellanFIRantisymmetric_flat_differentiator_test_hAM56_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hAM56.ok"; fail; fi

diff -Bb test_hA56.ok \
mcclellanFIRantisymmetric_flat_differentiator_test_hA56_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hA56.ok"; fail; fi

diff -Bb test_hAM57.ok \
mcclellanFIRantisymmetric_flat_differentiator_test_hAM57_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hAM57.ok"; fail; fi

diff -Bb test_hA57.ok \
mcclellanFIRantisymmetric_flat_differentiator_test_hA57_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_hA57.ok"; fail; fi

#
# this much worked
#
pass

