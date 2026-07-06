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
ngds=0.5451, est_varydsd=0.2650, varydsd=0.2399, max_ydsf=264, max_xxdsf=173
ngNBids=0.3829, est_varydsid=0.2110, varydsid=0.2420, max_ydsif=264, max_xxdsif=345
ngs=0.5597, est_varysd=0.2699, varysd=0.2716, max_ysf=264, max_xxsf=173
roundNBis = [ 10, 10 ]';
ngNBis=0.4665, est_varysid=0.2388, varysid=0.2716, max_ysif=264, max_xxsif=173
pow2p = [ 1.0000, 1.0000 ];
ngp=0.5597, est_varypd=0.2699, varypd=0.1803, max_ypf=264, max_xxpf=224
pow2palt = [ 1.0000, 1.0000 ];
ngpalt=0.5597, est_varypaltd=0.2699, varypaltd=0.1803, max_ypaltf=264, max_xxpaltf=224

NN=3
roundNBids = [  9, 10, 11 ]';
ngds=1.4269, est_varydsd=0.5590, varydsd=0.3927, max_ydsf=270, max_xxdsf=218
ngNBids=1.0397, est_varydsid=0.4299, varydsid=0.5208, max_ydsif=271, max_xxdsif=437
ngs=0.9011, est_varysd=0.3837, varysd=0.3847, max_ysf=269, max_xxsf=218
roundNBis = [  9, 10, 10 ]';
ngNBis=0.7425, est_varysid=0.3308, varysid=0.4789, max_ysif=270, max_xxsif=214
pow2p = [ 1.0000, 2.0000, 1.0000 ];
ngp=0.9011, est_varypd=0.3837, varypd=0.5726, max_ypf=268, max_xxpf=213
pow2palt = [ 0.5000, 1.0000, 0.5000 ];
ngpalt=0.9011, est_varypaltd=0.3837, varypaltd=0.2052, max_ypaltf=269, max_xxpaltf=427

NN=4
roundNBids = [  9, 10, 10, 10 ]';
ngds=7.3039, est_varydsd=2.5180, varydsd=0.9236, max_ydsf=291, max_xxdsf=236
ngNBids=5.3956, est_varydsid=1.8819, varydsid=1.6875, max_ydsif=291, max_xxdsif=234
ngs=1.2514, est_varysd=0.5005, varysd=0.4906, max_ysf=291, max_xxsf=247
roundNBis = [  9, 10, 10, 10 ]';
ngNBis=1.1463, est_varysid=0.4654, varysid=0.6297, max_ysif=293, max_xxsif=246
pow2p = [ 1.0000, 1.0000, 0.5000, 1.0000 ];
ngp=1.2514, est_varypd=0.5005, varypd=0.7232, max_ypf=292, max_xxpf=312
pow2palt = [ 0.5000, 1.0000, 0.2500, 0.5000 ];
ngpalt=1.2514, est_varypaltd=0.5005, varypaltd=0.2890, max_ypaltf=291, max_xxpaltf=357

NN=5
roundNBids = [  8, 10, 11, 11, ... 
               10 ]';
ngds=73.8469, est_varydsd=24.6990, varydsd=3.8006, max_ydsf=284, max_xxdsf=258
ngNBids=48.4604, est_varydsid=16.2368, varydsid=11.4049, max_ydsif=281, max_xxdsif=512
ngs=1.6039, est_varysd=0.6180, varysd=0.6223, max_ysf=282, max_xxsf=257
roundNBis = [ 10, 10, 10, 10, ... 
              10 ]';
ngNBis=1.5474, est_varysid=0.5991, varysid=0.6223, max_ysif=282, max_xxsif=257
pow2p = [ 1.0000, 2.0000, 0.2500, 0.5000, ... 
          1.0000 ];
ngp=1.6039, est_varypd=0.6180, varypd=0.4869, max_ypf=280, max_xxpf=303
pow2palt = [ 1.0000, 1.0000, 0.2500, 0.5000, ... 
             1.0000 ];
ngpalt=1.6039, est_varypaltd=0.6180, varypaltd=0.3897, max_ypaltf=280, max_xxpaltf=404

NN=6
roundNBids = [  8, 10, 11, 11, ... 
               11, 10 ]';
ngds=1500.0998, est_varydsd=500.1166, varydsd=30.1028, max_ydsf=283, max_xxdsf=255
ngNBids=822.9828, est_varydsid=274.4109, varydsid=90.5296, max_ydsif=301, max_xxdsif=498
ngs=1.9569, est_varysd=0.7356, varysd=0.7301, max_ysf=291, max_xxsf=265
roundNBis = [ 10, 10, 10, 10, ... 
              10, 10 ]';
ngNBis=1.8698, est_varysid=0.7066, varysid=0.7301, max_ysif=291, max_xxsif=265
pow2p = [ 2.0000, 2.0000, 0.2500, 0.5000, ... 
          2.0000, 1.0000 ];
ngp=1.9569, est_varypd=0.7356, varypd=0.9922, max_ypf=291, max_xxpf=348
pow2palt = [ 1.0000, 2.0000, 0.1250, 0.2500, ... 
             1.0000, 0.5000 ];
ngpalt=1.9569, est_varypaltd=0.7356, varypaltd=0.3572, max_ypaltf=291, max_xxpaltf=493
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
