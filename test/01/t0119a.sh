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
n = [   0.0857568152,   0.2721145193,   0.5924846845,   0.8872535581, ... 
        1.0183340513,   0.8872481652,   0.5924753910,   0.2721095013, ... 
        0.0857535866 ];
dR = [   1.0000000000,   0.0000000000,   2.0227980017,   0.0000000000, ... 
         1.3779616183,   0.0000000000,   0.3585127058,   0.0000000000, ... 
         0.0507189123 ];
pA = [   1.0000000000,  -0.6750803038,   0.3249196962 ];
nftA = [   0.0310713069,  -0.1429939256,   0.3365704195,  -0.5803821151, ... 
           0.8434639752,  -1.0410575357,   1.1227385461,  -1.1548180834, ... 
           1.1722476163,  -1.1547528294,   1.1226313910,  -1.0409432241, ... 
           0.8433712999,  -0.5803229117,   0.3365409803,  -0.1429835693, ... 
           0.0310693511 ];
dRftA = [   1.0000000000,  -5.9609807304,  19.6071520550, -45.4885752242, ... 
           82.3804583073, -121.8780989712, 151.3309702659, -160.0592293244, ... 
          145.4772759663, -113.8933243029,  76.7267439962, -44.1902047756, ... 
           21.5106614425,  -8.6470555925,   2.7635103801,  -0.6414502728, ... 
            0.0865755916 ];
pB = [   1.0000000000,   0.0000000000,   0.5095254495 ];
nftB = [   0.0185015012,  -0.0000000000,   0.0641631926,  -0.0000000000, ... 
           0.1259461114,   0.0000000000,   0.1660930004,   0.0000000000, ... 
           0.1812898422,   0.0000000000,   0.1660823435,   0.0000000000, ... 
           0.1259341112,   0.0000000000,   0.0641568653,  -0.0000000000, ... 
           0.0185000092 ];
dRftB = [   1.0000000000,   0.0000000000,   5.3832734433,  -0.0000000000, ... 
           13.4686769092,  -0.0000000000,  20.1972129108,  -0.0000000000, ... 
           19.7676958785,   0.0000000000,  12.9118315875,   0.0000000000, ... 
            5.5109139830,  -0.0000000000,   1.4153222837,  -0.0000000000, ... 
            0.1702697239 ];
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

