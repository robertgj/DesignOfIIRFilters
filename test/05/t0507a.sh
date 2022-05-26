#!/bin/sh

prog=sedumi_minphase_test.m
depends="test/sedumi_minphase_test.m sedumi_minphase_test_data.mat \
test_common.m print_polynomial.m qroots.m qzsolve.oct"

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
h = [  -0.0250529614,  -0.0615245917,  -0.1194647520,  -0.1795474725, ... 
       -0.2257795083,  -0.2343934857,  -0.1961429870,  -0.1171209625, ... 
       -0.0206280599,   0.0605021892,   0.1001957012,   0.0890891848, ... 
        0.0398942991,  -0.0190842796,  -0.0589696455,  -0.0628882367, ... 
       -0.0342748067,   0.0075955704,   0.0391250882,   0.0450187411, ... 
        0.0258121856,  -0.0044862332,  -0.0278356361,  -0.0322696838, ... 
       -0.0181924404,   0.0037539641,   0.0201511177,   0.0225090116, ... 
        0.0118427845,  -0.0036317698,  -0.0143700865,  -0.0148710610, ... 
       -0.0068198992,   0.0035793233,   0.0100035421,   0.0091401547, ... 
        0.0033652581,  -0.0032574344,  -0.0065744572,  -0.0050511369, ... 
       -0.0013155381,   0.0026835981,   0.0040041822,   0.0023434011, ... 
        0.0009293160,  -0.0031668619,  -0.0035436739,   0.0016761890 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -bB test_h_coef.ok sedumi_minphase_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.ok"; fail; fi

#
# this much worked
#
pass

