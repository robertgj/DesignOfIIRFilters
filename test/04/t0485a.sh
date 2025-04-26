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
x2 = [   0.0431912271, ...
        -0.9998575856,   0.9963938666, ...
         0.9648834973,   0.9686915224,   0.9817932250,   0.9838463404, ... 
         0.9947940502,   0.9973416586,   0.9988047204,   1.0003251084, ... 
         1.0070541557, ...
         0.4364897217,   0.6552203283,   1.4748858861,   0.4575408332, ... 
         0.6379274214,   0.8680952078,   1.0531935881,   1.0861673621, ... 
         1.5310066473, ...
         0.8924733587,   0.8925154580,   0.9434458331,   0.9585655794, ... 
         0.9759390748,   0.9790381576,   0.9834902521,   0.9914989917, ... 
         0.9927006442,   0.9961339179, ...
         1.2312628148,   1.3795416802,   0.5550460298,   0.4741824803, ... 
         1.1065172225,   0.6328802515,   1.4142059128,   0.4711107033, ... 
         0.6306916494,   1.0941906499 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_x2.ok"; fail; fi

cat > test_N2.ok << 'EOF'
N2 = [     0.0431912271,    -0.4372208705,     2.2338127281,    -7.5774403512, ... 
          18.9691975118,   -36.8676771746,    56.8671003003,   -69.4443402121, ... 
          64.3719109891,   -37.9102926504,    -2.7481372883,    42.2888789335, ... 
         -66.0808303155,    68.4468932874,   -54.3645666755,    34.3055079362, ... 
         -17.1996118165,     6.6941506967,    -1.9208317884,     0.3652631887, ... 
          -0.0349529264 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_N2.ok"; fail; fi

cat > test_D2.ok << 'EOF'
D2 = [     1.0000000000,   -11.2870463436,    65.0254563167,  -252.1501624008, ... 
         734.5471064397, -1703.0655371872,  3253.0020999071, -5232.7568899411, ... 
        7190.8975794849, -8518.6719721315,  8743.8320615346, -7789.8345787897, ... 
        6015.1178890896, -4006.8350320187,  2282.6778955478, -1096.8888753591, ... 
         435.1566586550,  -137.7846526724,    32.8953708153,    -5.3113903151, ... 
           0.4404950207 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_D2.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog" 

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_x2.ok iir_socp_slb_multiband_test_x2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_x2.ok"; fail; fi

diff -Bb test_N2.ok iir_socp_slb_multiband_test_N2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_N2.ok"; fail; fi

diff -Bb test_D2.ok iir_socp_slb_multiband_test_D2_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_D2.ok"; fail; fi

#
# this much worked
#
pass

