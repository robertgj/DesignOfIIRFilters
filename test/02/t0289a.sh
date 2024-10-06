#!/bin/sh

prog=schurOneMlattice_socp_slb_bandpass_test.m

depends="test/schurOneMlattice_socp_slb_bandpass_test.m \
../tarczynski_bandpass_R1_test_N0_coef.m \
../tarczynski_bandpass_R1_test_D0_coef.m \
test_common.m \
schurOneMlatticeAsq.m \
schurOneMlatticeT.m \
schurOneMlatticeP.m \
schurOneMlatticedAsqdw.m \
schurOneMlatticeEsq.m \
schurOneMlattice_slb.m \
schurOneMlattice_slb_constraints_are_empty.m \
schurOneMlattice_socp_mmse.m \
schurOneMlattice_slb_exchange_constraints.m \
schurOneMlattice_slb_set_empty_constraints.m \
schurOneMlattice_slb_show_constraints.m \
schurOneMlattice_slb_update_constraints.m \
schurOneMscale.m \
tf2schurOneMlattice.m \
schurOneMlattice2tf.m \
local_max.m tf2pa.m x2tf.m print_polynomial.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
qroots.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMlattice2H.oct qzsolve.oct Abcd2tf.oct"

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
cat > test.k3.ok << 'EOF'
k3 = [  -0.8649336912,   0.9764379935,  -0.6803194064,   0.7708807139, ... 
        -0.5815699756,   0.8267115946,  -0.6627666248,   0.7490278100, ... 
        -0.6030217661,   0.5169136865,  -0.2424923606,   0.0683833285, ... 
        -0.0074114729,   0.0006611643,  -0.0004870601,  -0.0120761728, ... 
        -0.0165964280,   0.0107928172,  -0.0097025145,  -0.0031015771 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.k3.ok"; fail; fi

cat > test.epsilon3.ok << 'EOF'
epsilon3 = [  1,  1,  1, -1, ... 
             -1,  1,  1, -1, ... 
             -1, -1,  1, -1, ... 
              1, -1,  1,  1, ... 
              1, -1,  1,  1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.epsilon3.ok"; fail; fi

cat > test.p3.ok << 'EOF'
p3 = [   0.3239840932,   1.2038763138,   0.1314457076,   0.3013590191, ... 
         0.8378147926,   0.4309384428,   0.1327287481,   0.2947239118, ... 
         0.7780382173,   0.3871814733,   0.6860924437,   0.8786906219, ... 
         0.9409811350,   0.9479812278,   0.9486082065,   0.9490703482, ... 
         0.9606015325,   0.9766786048,   0.9872772216,   0.9969032179 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.p3.ok"; fail; fi

cat > test.c3.ok << 'EOF'
c3 = [  -0.1071383259,  -0.0890335121,  -0.8022430970,  -0.6235675257, ... 
         0.0324401806,   0.9273948619,   1.4095201898,  -0.6446366300, ... 
        -0.1764181500,  -0.0152946412,   0.0168409489,  -0.0201976681, ... 
        -0.0127670201,   0.0206671981,   0.0302066961,   0.0109780753, ... 
        -0.0023090276,   0.0028383384,   0.0076917166,   0.0021599294, ... 
        -0.0087101657 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.c3.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.k3.ok schurOneMlattice_socp_slb_bandpass_test_k3_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of k3.coef"; fail; fi

diff -Bb test.epsilon3.ok schurOneMlattice_socp_slb_bandpass_test_epsilon3_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of epsilon3.coef"; fail; fi

diff -Bb test.p3.ok schurOneMlattice_socp_slb_bandpass_test_p3_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of p3.coef"; fail; fi

diff -Bb test.c3.ok schurOneMlattice_socp_slb_bandpass_test_c3_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb of c3.coef"; fail; fi

#
# this much worked
#
pass
