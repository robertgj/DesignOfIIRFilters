#!/bin/sh

prog=tarczynski_deczky1_test.m

depends="test/tarczynski_deczky1_test.m \
test_common.m delayz.m print_polynomial.m WISEJ.m tf2Abcd.m \
print_pole_zero.m tf2x.m zp2x.m qroots.oct"

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
cat > test.ok.N0 << 'EOF'
N0 = [   0.0055559909,  -0.0080358735,  -0.0077648943,   0.0080051819, ... 
         0.0122247801,  -0.0312785708,  -0.0204953814,   0.1933715395, ... 
         0.5531076879,   0.7701315385,   0.6559129849,   0.3398751664, ... 
         0.0919823178 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.N0"; fail; fi

cat > test.ok.D0 << 'EOF'
D0 = [   1.0000000000,   0.1080307848,   1.3823540488,  -0.2775164927, ... 
         0.5013240188,  -0.1970597490,   0.0701389495 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.D0"; fail; fi

cat > test.ok.x0 << 'EOF'
Ux0=0,Vx0=0,Mx0=12,Qx0=6,Rx0=1
x0 = [   0.0055559909, ...
         0.9814589014,   0.9817141646,   0.9851679582,   0.9955021662, ... 
         1.9077285446,   2.2570707338, ...
         2.0737722940,   2.4007484642,   2.8780213990,   1.9108373923, ... 
         0.9957876800,   0.2844955562, ...
         0.3729901749,   0.7418645638,   0.9571006463, ...
         0.8184807870,   1.7389406595,   1.7650335943 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok.x0"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr=tarczynski_deczky1_test

diff -Bb test.ok.N0 $nstr"_N0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.N0"; fail; fi

diff -Bb test.ok.D0 $nstr"_D0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.D0"; fail; fi

diff -Bb test.ok.x0 $nstr"_x0_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok.x0"; fail; fi

#
# this much worked
#
pass
