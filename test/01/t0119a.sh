#!/bin/sh

prog=freq_transform_structure_test.m

depends="freq_transform_structure_test.m test_common.m print_polynomial.m \
WISEJ.m tfp2g.m tf2Abcd.m phi2p.m"

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
n = [   0.0856606269,   0.2719271356,   0.5920981128,   0.8867652318, ... 
        1.0177705133,   0.8867665891,   0.5920988330,   0.2719286805, ... 
        0.0856610675 ];
dR = [   1.0000000000,   0.0000000000,   2.0220282628,   0.0000000000, ... 
         1.3768834514,   0.0000000000,   0.3580553746,   0.0000000000, ... 
         0.0507018037 ];
pA = [   1.0000000000,  -0.6750803038,   0.3249196962 ];
nftA = [   0.0310213808,  -0.1427347722,   0.3358494571,  -0.5789404304, ... 
           0.8411349493,  -1.0378711539,   1.1189063355,  -1.1506115463, ... 
           1.1679309472,  -1.1505874690,   1.1188691958,  -1.0378355277, ... 
           0.8411104161,  -0.5789283347,   0.3358455306,  -0.1427341201, ... 
           0.0310213586 ];
dRftA = [   1.0000000000,  -5.9607794999,  19.6055858638, -45.4824478244, ... 
           82.3642995870, -121.8461747719, 151.2808395099, -159.9946419511, ... 
          145.4077522166, -113.8303579435,  76.6787180811, -44.1595990882, ... 
           21.4946269391,  -8.6403605857,   2.7613831404,  -0.6409839374, ... 
            0.0865184912 ];
pB = [   1.0000000000,   0.0000000000,   0.5095254495 ];
nftB = [   0.0184657150,   0.0000000000,   0.0640043680,   0.0000000000, ... 
           0.1255856497,   0.0000000000,   0.1655513802,  -0.0000000000, ... 
           0.1806794929,  -0.0000000000,   0.1655479544,  -0.0000000000, ... 
           0.1255822648,   0.0000000000,   0.0640029930,   0.0000000000, ... 
           0.0184655344 ];
dRftB = [   1.0000000000,   0.0000000000,   5.3828381256,  -0.0000000000, ... 
           13.4664044232,  -0.0000000000,  20.1919456280,  -0.0000000000, ... 
           19.7606633793,   0.0000000000,  12.9060140968,   0.0000000000, ... 
            5.5079456937,   0.0000000000,   1.4144649253,  -0.0000000000, ... 
            0.1701624731 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

