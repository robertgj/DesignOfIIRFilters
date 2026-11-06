#!/bin/sh

prog=iir_socp_slb_multiband_test.m

depends="test/iir_socp_slb_multiband_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_socp_mmse.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
fixResultNaN.m iirA.m iirE.m iirP.m iirT.m x2zp.m \
phi2p.m tfp2g.m local_max.m tf2x.m zp2x.m x2tf.m xConstraints.m qroots.oct \
"

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
cat > test_x2.ok << 'EOF'
Ux2=2,Vx2=0,Mx2=18,Qx2=20,Rx2=1
x2 = [   0.0433642900, ...
        -1.0008081635,   1.0002579428, ...
         0.9694097002,   0.9698554803,   0.9719286911,   0.9760233365, ... 
         0.9899648118,   0.9914756399,   1.0132817637,   1.0220119396, ... 
         1.0270862923, ...
         0.6796779315,   0.4188085138,   1.0497423497,   1.4759442871, ... 
         0.6389312432,   0.4650861509,   0.8714757105,   1.0152961092, ... 
         1.5278079942, ...
         0.8812844587,   0.8890572058,   0.9374050800,   0.9545170590, ... 
         0.9621630805,   0.9677762035,   0.9795873362,   0.9822006910, ... 
         0.9923070697,   0.9947161233, ...
         1.3893666781,   1.2327086590,   0.5566091019,   1.0432804467, ... 
         0.4694449806,   0.6468396545,   1.0993277061,   1.4140484404, ... 
         0.6299859825,   0.4711462585 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x2.ok"; fail; fi

cat > test_N2.ok << 'EOF'
N2 = [     0.0433642900,    -0.4451090820,     2.3019154063,    -7.8926729601, ... 
          19.9486075237,   -39.1116225263,    60.8272324061,   -74.8933982566, ... 
          70.0773052708,   -41.9514634988,    -2.0206954888,    45.2634973823, ... 
         -71.6265310944,    74.6026536112,   -59.4319111801,    37.5526306167, ... 
         -18.8242703059,     7.3141671074,    -2.0919352145,     0.3958716299, ... 
          -0.0376359548 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N2.ok"; fail; fi

cat > test_D2.ok << 'EOF'
D2 = [     1.0000000000,   -11.2941300511,    64.9778543393,  -251.2545973820, ... 
         729.0480075132, -1682.1574462009,  3195.3200422571, -5108.6797466175, ... 
        6974.3569505765, -8204.6608669118,  8359.9572413216, -7391.0174615094, ... 
        5661.9098552059, -3740.5547288638,  2112.8407543995, -1006.3242799122, ... 
         395.5740583635,  -124.0583149913,    29.3235962039,    -4.6854001013, ... 
           0.3843599831 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_D2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="iir_socp_slb_multiband_test"

diff -Bb test_x2.ok $nstr"_x2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x2.ok"; fail; fi

diff -Bb test_N2.ok $nstr"_N2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N2.ok"; fail; fi

diff -Bb test_D2.ok $nstr"_D2_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_D2.ok"; fail; fi

#
# this much worked
#
pass

