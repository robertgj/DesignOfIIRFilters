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
x2 = [   0.0410456224, ...
        -1.0009800310,   1.0009479187, ...
         0.9664969263,   0.9693605280,   0.9726389480,   0.9744860779, ... 
         0.9814850934,   0.9821089999,   1.0145460197,   1.0164971645, ... 
         1.0291618391, ...
         0.6785347747,   0.4119770057,   1.0496542294,   1.4824861378, ... 
         0.4304291343,   0.6464506786,   0.8762769990,   1.0074613295, ... 
         1.5354684754, ...
         0.8715587152,   0.8867361949,   0.9416044588,   0.9498522078, ... 
         0.9551365921,   0.9623723008,   0.9787949640,   0.9815315732, ... 
         0.9847497380,   0.9889239390, ...
         1.3817910108,   1.2354836809,   0.5523362867,   0.4194054915, ... 
         1.0461660960,   0.6497231108,   1.0983979154,   1.4136754058, ... 
         0.4687732741,   0.6304589216 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x2.ok"; fail; fi

cat > test_N2.ok << 'EOF'
N2 = [     0.0410456224,    -0.4199168665,     2.1630646413,    -7.3858159689, ... 
          18.5895444809,   -36.2965710643,    56.2173145642,   -68.9192902825, ... 
          64.1460617042,   -38.0005160158,    -2.4982559249,    42.0860157870, ... 
         -66.0318397056,    68.5143696323,   -54.4451565400,    34.3330456681, ... 
         -17.1785267329,     6.6615636907,    -1.9007859456,     0.3585905246, ... 
          -0.0339421962 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N2.ok"; fail; fi

cat > test_D2.ok << 'EOF'
D2 = [     1.0000000000,   -11.2913236335,    64.8792686896,  -250.4088623564, ... 
         724.9426189281, -1668.3218911115,  3159.8516540309, -5035.9884543468, ... 
        6851.6369539666, -8030.7841778394,  8150.8279758136, -7176.1885350477, ... 
        5473.0907718473, -3598.8899519284,  2022.7240034208,  -958.3119743135, ... 
         374.5734299182,  -116.7567272642,    27.4134038948,    -4.3471546144, ... 
           0.3533604853 ]';
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

