#!/bin/sh

prog=freq_transform_structure_test.m

depends="freq_transform_structure_test.m test_common.m print_polynomial.m \
WISEJ.m tfp2g.m tf2Abcd.m phi2p.m"

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
n = [   0.0857526461,   0.2721065334,   0.5924693555,   0.8872367637, ... 
        1.0183181186,   0.8872367931,   0.5924694628,   0.2721066332, ... 
        0.0857528266 ];
dR = [   1.0000000000,   0.0000000000,   2.0227725009,   0.0000000000, ... 
         1.3779306177,   0.0000000000,   0.3584982390,   0.0000000000, ... 
         0.0507148469 ];
pA = [   1.0000000000,  -0.6750803038,   0.3249196962 ];
nftA = [   0.0310691399,  -0.1429827850,   0.3365399551,  -0.5803228783, ... 
           0.8433727076,  -1.0409428427,   1.1226202065,  -1.1547181455, ... 
           1.1721806640,  -1.1547210075,   1.1226251560,  -1.0409485690, ... 
           0.8433778271,  -0.5803264635,   0.3365418486,  -0.1429834664, ... 
           0.0310692688 ];
dRftA = [   1.0000000000,  -5.9609742817,  19.6071021094, -45.4883811355, ... 
           82.3799504526, -121.8771035764, 151.3294170345, -160.0572322481, ... 
          145.4751141328, -113.8913317681,  76.7251708043, -44.1891422758, ... 
           21.5100528061,  -8.6467664134,   2.7634009668,  -0.6414203802, ... 
            0.0865709519 ];
pB = [   1.0000000000,   0.0000000000,   0.5095254495 ];
nftB = [   0.0184999889,   0.0000000000,   0.0641569305,   0.0000000000, ... 
           0.1259336866,   0.0000000000,   0.1660787848,   0.0000000000, ... 
           0.1812803040,   0.0000000000,   0.1660793054,   0.0000000000, ... 
           0.1259343203,   0.0000000000,   0.0641573023,   0.0000000000, ... 
           0.0185000830 ];
dRftB = [   1.0000000000,   0.0000000000,   5.3832598596,   0.0000000000, ... 
           13.4686064541,  -0.0000000000,  20.1970496002,  -0.0000000000, ... 
           19.7674746816,   0.0000000000,  12.9116413264,   0.0000000000, ... 
            5.5108090617,   0.0000000000,   1.4152875318,  -0.0000000000, ... 
            0.1702642899 ];
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

