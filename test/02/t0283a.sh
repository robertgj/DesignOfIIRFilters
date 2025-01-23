#!/bin/sh

prog=complementaryFIRlattice_socp_slb_bandpass_hilbert_test.m

depends="test/complementaryFIRlattice_socp_slb_bandpass_hilbert_test.m \
test_common.m \
../iir_sqp_slb_fir_17_bandpass_test_d1_coef.m \
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
complementaryFIRlattice2Abcd.m \
complementaryFIRlatticeFilter.m \
local_max.m x2tf.m print_polynomial.m Abcd2tf.m H2Asq.m H2T.m H2P.m \
direct_form_scale.m qroots.m \
minphase.oct Abcd2H.oct complementaryFIRdecomp.oct qzsolve.oct"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED ${0#$here"/"} $prog 1>&2
        cd $here
        #rm -rf $tmp
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
cat > test_k2_coef.m << 'EOF'
k2 = [   0.9839340410,   0.9836437301,   0.9837528750,   0.9836733039, ... 
         0.9836205528,   0.9838047149,   0.9839595218,   0.9833746547, ... 
         0.9843749538,   0.9666769676,   0.9697456292,   0.9838800206, ... 
         0.9155055404,   0.9508963402,   0.9838903931,   0.9841992240, ... 
         0.1379388179 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_k2_coef.m"; fail; fi

cat > test_khat2_coef.m << 'EOF'
khat2 = [  -0.0200057134,  -0.0297782272,   0.0241816868,   0.0662147111, ... 
            0.0584640431,   0.0428830867,   0.0780160128,   0.0811604589, ... 
           -0.1307279783,  -0.4598802268,  -0.4604848476,   0.0637948061, ... 
            0.5554670407,   0.4787434520,   0.0461566547,  -0.1794756291, ... 
            0.9833693675 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_khat2_coef.m"; fail; fi

cat > test_Nh2_coef.m << 'EOF'
Nh2 = [   0.0925818258,   0.0624654575,  -0.0682339974,  -0.2097877442, ... 
         -0.2037346996,  -0.0119898586,   0.1961665537,   0.1994981937, ... 
          0.0605911008,  -0.0873720167,  -0.0927559992,  -0.0264363290, ... 
          0.0027356922,  -0.0151200981,  -0.0232821492,   0.0112543148, ... 
          0.0134197360 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Nh2_coef.m"; fail; fi

cat > test_Ng2_coef.m << 'EOF'
Ng2 = [   0.6600182084,  -0.4296071220,   0.2932325905,   0.4896141807, ... 
          0.2792502054,   0.0194183051,  -0.0855293094,  -0.0688383852, ... 
         -0.0372433513,  -0.0266855160,  -0.0166559986,   0.0044896197, ... 
          0.0185775263,   0.0141135524,   0.0017725970,  -0.0040739951, ... 
         -0.0018824082 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_Ng2_coef.m"; fail; fi


#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="complementaryFIRlattice_socp_slb_bandpass_hilbert_test"

for coef in k2 khat2 Nh2 Ng2 ; do
    diff -bBw test_$coef"_coef.m" $nstr"_"$coef"_coef.m"
    if [ $? -ne 0 ]; then echo "Failed for $coef"; fail; fi
done

#
# this much worked
#
pass
