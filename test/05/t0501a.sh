#!/bin/sh

prog=yalmip_kyp_test.m
depends="yalmip_kyp_test.m test_common.m print_polynomial.m \
directFIRnonsymmetricEsqPW.m"

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
h = [ -0.0034108695,  0.0010656821,  0.0083958304,  0.0094701382, ... 
      -0.0049397359, -0.0289239260, -0.0348237225,  0.0108397127, ... 
       0.1154867474,  0.2402941303,  0.3160027806,  0.2901971472, ... 
       0.1700064568,  0.0221691888, -0.0733262532, -0.0795635290, ... 
      -0.0234226390,  0.0339978165,  0.0483261726,  0.0206544745, ... 
      -0.0151727189, -0.0282779331, -0.0150488896,  0.0055938391, ... 
       0.0145952302,  0.0087919661, -0.0015998513, -0.0062888333, ... 
      -0.0038071695,  0.0005868677,  0.0023846826 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_coef.ok"; fail; fi

cat > test_h_kyp_coef.ok << 'EOF'
h_kyp = [ -0.0034108695,  0.0010656821,  0.0083958304,  0.0094701382, ... 
          -0.0049397359, -0.0289239260, -0.0348237225,  0.0108397127, ... 
           0.1154867474,  0.2402941303,  0.3160027806,  0.2901971472, ... 
           0.1700064568,  0.0221691888, -0.0733262532, -0.0795635290, ... 
          -0.0234226390,  0.0339978165,  0.0483261726,  0.0206544745, ... 
          -0.0151727189, -0.0282779331, -0.0150488896,  0.0055938391, ... 
           0.0145952302,  0.0087919661, -0.0015998513, -0.0062888333, ... 
          -0.0038071695,  0.0005868677,  0.0023846826 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test_h_kyp_coef.ok"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test_h_coef.ok yalmip_kyp_test_h_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_coef.ok"; fail; fi

diff -Bb test_h_kyp_coef.ok yalmip_kyp_test_h_kyp_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb test_h_kyp_coef.ok"; fail; fi

#
# this much worked
#
pass

