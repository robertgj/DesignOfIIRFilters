#!/bin/sh

prog=tarczynski_ex2_standalone_test.m

depends="tarczynski_ex2_standalone_test.m test_common.m \
WISEJ.m tf2Abcd.m tf2x.m print_polynomial.m print_pole_zero.m"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED $prog
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
cat > test.ok << 'EOF'
Ux0=2,Vx0=2,Mx0=22,Qx0=0,Rx0=2
x0 = [   0.0055318290, ...
        -2.5168138363,  -1.3161006896, ...
        -0.9079557694,  -0.2702604014, ...
         1.3053839613,   1.2801562714,   1.2457015679,   1.3543478806, ... 
         1.3403308282,   1.3017580799,   1.1940442549,   1.0577008496, ... 
         0.8556853308,   0.6295776743,   0.5427305259, ...
         2.8130730290,   2.4936247780,   2.1815996170,   0.2206321191, ... 
         0.6636972247,   1.1146367092,   1.8756711050,   1.6003205057, ... 
         1.5609072986,   1.0945225147,   0.3906921811 ]';
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok tarczynski_ex2_standalone_test_x0_coef.m
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

