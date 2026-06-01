#!/bin/sh

prog=state_variable_unequal_state_length_test.m

depends="test/state_variable_unequal_state_length_test.m test_common.m \
tf2schurOneMlattice.m schurOneMscale.m KW.m p2n60.m svf.m tf2Abcd.m \
print_polynomial.m \
schurOneMlatticeFilter.oct schurOneMlattice2Abcd.oct \
schurexpand.oct schurdecomp.oct \
reprand.oct qroots.oct complex_zhong_inverse.oct"

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
# the output should look like this (as for m-file test in t0582a.sh)
#
cat > test.ok << 'EOF'

NN=1
roundNBids = [ 10 ];
ngds=0.2500, est_varydsd=0.1667, varydsd=0.1667, max_ydsf=255, max_xxdsf=130
ngNBids=0.2500, est_varydsid=0.1667, varydsid=0.1667, max_ydsif=255, max_xxdsif=130
ngs=0.2500, est_varysd=0.1667, varysd=0.1667, max_ysf=255, max_xxsf=130
roundNBis = [ 10 ];
ngNBis=0.2500, est_varysid=0.1667, varysid=0.1667, max_ysif=255, max_xxsif=130
pow2p = [ 1.0000 ];
ngp=0.2500, est_varypd=0.1667, varypd=0.1422, max_ypf=255, max_xxpf=156
pow2palt = [ 1.0000 ];
ngpalt=0.2500, est_varypaltd=0.1667, varypaltd=0.1422, max_ypaltf=255, max_xxpaltf=156

NN=2
roundNBids = [  9, 11 ]';
ngds=0.5451, est_varydsd=0.2650, varydsd=0.2394, max_ydsf=276, max_xxdsf=178
ngNBids=0.3829, est_varydsid=0.2110, varydsid=0.2416, max_ydsif=276, max_xxdsif=355
ngs=0.5597, est_varysd=0.2699, varysd=0.2699, max_ysf=276, max_xxsf=178
roundNBis = [ 10, 10 ]';
ngNBis=0.4665, est_varysid=0.2388, varysid=0.2699, max_ysif=276, max_xxsif=178
pow2p = [ 1.0000, 1.0000 ];
ngp=0.5597, est_varypd=0.2699, varypd=0.1798, max_ypf=275, max_xxpf=228
pow2palt = [ 1.0000, 1.0000 ];
ngpalt=0.5597, est_varypaltd=0.2699, varypaltd=0.1798, max_ypaltf=275, max_xxpaltf=228

NN=3
roundNBids = [  9, 10, 11 ]';
ngds=1.4269, est_varydsd=0.5590, varydsd=0.3911, max_ydsf=302, max_xxdsf=226
ngNBids=1.0397, est_varydsid=0.4299, varydsid=0.5134, max_ydsif=302, max_xxdsif=452
ngs=0.9011, est_varysd=0.3837, varysd=0.3851, max_ysf=302, max_xxsf=227
roundNBis = [  9, 10, 10 ]';
ngNBis=0.7425, est_varysid=0.3308, varysid=0.4762, max_ysif=303, max_xxsif=228
pow2p = [ 1.0000, 2.0000, 1.0000 ];
ngp=0.9011, est_varypd=0.3837, varypd=0.5768, max_ypf=302, max_xxpf=220
pow2palt = [ 0.5000, 1.0000, 0.5000 ];
ngpalt=0.9011, est_varypaltd=0.3837, varypaltd=0.2041, max_ypaltf=303, max_xxpaltf=442

NN=4
roundNBids = [  9, 10, 10, 10 ]';
ngds=7.3039, est_varydsd=2.5180, varydsd=0.9219, max_ydsf=314, max_xxdsf=250
ngNBids=5.3956, est_varydsid=1.8819, varydsid=1.6717, max_ydsif=316, max_xxdsif=251
ngs=1.2514, est_varysd=0.5005, varysd=0.5002, max_ysf=316, max_xxsf=285
roundNBis = [  9, 10, 10, 10 ]';
ngNBis=1.1463, est_varysid=0.4654, varysid=0.6340, max_ysif=316, max_xxsif=286
pow2p = [ 1.0000, 1.0000, 0.5000, 1.0000 ];
ngp=1.2514, est_varypd=0.5005, varypd=0.7157, max_ypf=316, max_xxpf=358
pow2palt = [ 0.5000, 1.0000, 0.2500, 0.5000 ];
ngpalt=1.2514, est_varypaltd=0.5005, varypaltd=0.2888, max_ypaltf=317, max_xxpaltf=382

NN=5
roundNBids = [  8, 10, 11, 11, ... 
               10 ]';
ngds=73.8469, est_varydsd=24.6990, varydsd=3.7682, max_ydsf=343, max_xxdsf=300
ngNBids=48.4604, est_varydsid=16.2368, varydsid=11.4225, max_ydsif=346, max_xxdsif=608
ngs=1.6039, est_varysd=0.6180, varysd=0.6156, max_ysf=347, max_xxsf=307
roundNBis = [ 10, 10, 10, 10, ... 
               10 ]';
ngNBis=1.5474, est_varysid=0.5991, varysid=0.6156, max_ysif=347, max_xxsif=307
pow2p = [ 1.0000, 2.0000, 0.2500, 0.5000, ... 
          1.0000 ];
ngp=1.6039, est_varypd=0.6180, varypd=0.4887, max_ypf=346, max_xxpf=324
pow2palt = [ 1.0000, 1.0000, 0.2500, 0.5000, ... 
             1.0000 ];
ngpalt=1.6039, est_varypaltd=0.6180, varypaltd=0.4042, max_ypaltf=347, max_xxpaltf=503

NN=6
roundNBids = [  8, 10, 11, 11, ... 
               11, 10 ]';
ngds=1500.0998, est_varydsd=500.1166, varydsd=30.3512, max_ydsf=348, max_xxdsf=301
ngNBids=822.9828, est_varydsid=274.4109, varydsid=92.7330, max_ydsif=332, max_xxdsif=572
ngs=1.9569, est_varysd=0.7356, varysd=0.7350, max_ysf=341, max_xxsf=299
roundNBis = [ 10, 10, 10, 10, ... 
               10, 10 ]';
ngNBis=1.8698, est_varysid=0.7066, varysid=0.7350, max_ysif=341, max_xxsif=299
pow2p = [ 2.0000, 2.0000, 0.2500, 0.5000, ... 
          2.0000, 1.0000 ];
ngp=1.9569, est_varypd=0.7356, varypd=0.9953, max_ypf=342, max_xxpf=361
pow2palt = [ 1.0000, 2.0000, 0.1250, 0.2500, ... 
             1.0000, 0.5000 ];
ngpalt=1.9569, est_varypaltd=0.7356, varypaltd=0.3504, max_ypaltf=339, max_xxpaltf=535
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"
octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass
