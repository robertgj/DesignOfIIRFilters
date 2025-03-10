#!/bin/sh

prog=directFIRnonsymmetric_kyp_union_bandpass_test.m

depends="test/directFIRnonsymmetric_kyp_union_bandpass_test.m test_common.m delayz.m \
print_polynomial.m qroots.oct"

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
cat > test_h_coef.ok << 'EOF'
h = [  0.0013632645,  0.0022335917, -0.0002767357,  0.0046002267, ... 
       0.0090332904, -0.0062651251, -0.0210712899, -0.0048452416, ... 
       0.0091097793, -0.0074584534,  0.0115576550,  0.0775167609, ... 
       0.0372321044, -0.1393050276, -0.1730310888,  0.0786134723, ... 
       0.2684974324,  0.0824048925, -0.2041650324, -0.1762236110, ... 
       0.0520761361,  0.1176136604,  0.0212375028, -0.0136525957, ... 
       0.0139318625, -0.0134420220, -0.0501748668, -0.0147547375, ... 
       0.0308529904,  0.0198922501, -0.0024833509,  0.0019097685, ... 
       0.0023300276, -0.0108088687, -0.0097969336,  0.0032323910, ... 
       0.0055850420,  0.0005626893,  0.0007256611,  0.0018957491, ... 
      -0.0012853422 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.m "; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok directFIRnonsymmetric_kyp_union_bandpass_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.m"; fail; fi

#
# this much worked
#
pass

