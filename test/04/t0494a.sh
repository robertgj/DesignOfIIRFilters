#!/bin/sh

prog=iir_sqp_slb_fir_lowpass_test.m

depends="test/iir_sqp_slb_fir_lowpass_test.m \
test_common.m print_polynomial.m print_pole_zero.m \
iir_slb.m iir_sqp_mmse.m iir_slb_set_empty_constraints.m \
iir_slb_constraints_are_empty.m iir_slb_show_constraints.m \
iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
armijo_kim.m cl2bp.m fixResultNaN.m iirA.m iirE.m iirT.m iirP.m invSVD.m \
local_max.m showResponseBands.m showResponse.m \
showResponsePassBands.m showZPplot.m sqp_bfgs.m tf2x.m zp2x.m updateWchol.m \
updateWbfgs.m x2tf.m xConstraints.m qroots.m qzsolve.oct"

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
cat > test.d1.ok << 'EOF'
Ud1=0,Vd1=0,Md1=60,Qd1=0,Rd1=1
d1 = [   0.0004974794, ...
         0.4176916098,   0.8298329159,   0.8356660083,   0.8373872614, ... 
         0.8426705217,   0.8543379561,   0.8657487978,   0.8933334101, ... 
         0.9932821523,   0.9933479897,   0.9940514456,   0.9945699403, ... 
         0.9950648249,   0.9962495936,   0.9974506165,   0.9980572799, ... 
         0.9987449190,   1.0000349155,   1.0015671282,   1.0031243488, ... 
         1.0043952697,   1.0057798105,   1.0073920814,   1.0088707902, ... 
         1.0099326262,   1.0105709008,   1.0106938347,   1.4059136265, ... 
         1.4400542521,   2.0807821045, ...
         0.0000079911,   0.0748307905,   0.2249467592,   0.3753562931, ... 
         0.5214427979,   0.6639408764,   0.8078823024,   0.9514604137, ... 
         1.4137892945,   1.5068138094,   1.6045491233,   1.3308022515, ... 
         1.7049302702,   1.8068430934,   1.9097134055,   1.2712429132, ... 
         2.0134905524,   2.1178615769,   2.2227273732,   2.3282693910, ... 
         2.4343906852,   2.5414970925,   2.6488506311,   2.7570559851, ... 
         2.8659759580,   2.9755353922,   3.0849487678,   0.6633174259, ... 
         0.2188633891,   3.1415857256 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.d1.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.d1.ok iir_sqp_slb_fir_lowpass_test_d1_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass
