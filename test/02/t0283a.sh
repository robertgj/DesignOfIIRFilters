#!/bin/sh

prog=complementaryFIRlattice_socp_slb_bandpass_test.m

depends="complementaryFIRlattice_socp_slb_bandpass_test.m test_common.m \
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
complementaryFIRlattice.m complementaryFIRlattice2Abcd.m minphase.m \
local_max.m tf2pa.m x2tf.m print_polynomial.m Abcd2tf.m H2Asq.m H2T.m H2P.m \
Abcd2H.oct complementaryFIRdecomp.oct qroots.m qzsolve.oct SeDuMi_1_3/"

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
cat > test.ok.k2 << 'EOF'
k2 = [   0.9969831139,   0.9969895357,   0.9970315994,   0.9970118953, ... 
         0.9969788826,   0.9969480091,   0.9968839642,   0.9969770914, ... 
         0.9882152183,   0.9308844640,   0.9759336628,   0.9802783953, ... 
         0.8896151485,   0.9639768857,   0.9969829907,   0.9839228777, ... 
         0.0903565889 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.k2"; fail; fi

cat > test.ok.khat2 << 'EOF'
khat2 = [  -0.0021120379,   0.0094498350,   0.0344582322,   0.0297338835, ... 
           -0.0012620299,   0.0207739541,   0.0908277627,   0.0566317682, ... 
           -0.1728219186,  -0.3743031067,  -0.2321810109,   0.2134347967, ... 
            0.4637645738,   0.2776739384,  -0.0785613137,  -0.1960779182, ... 
            0.9968663442 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.khat2"; fail; fi

#
# run and see if the results match. 
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog >test.out 
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok.k2 complementaryFIRlattice_socp_slb_bandpass_test_k2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.k2"; fail; fi

diff -Bb test.ok.khat2 \
     complementaryFIRlattice_socp_slb_bandpass_test_khat2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.khat2"; fail; fi


#
# this much worked
#
pass
