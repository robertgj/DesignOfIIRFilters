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
n = [   0.0857558491,   0.2721121021,   0.5924781150,   0.8872464553, ... 
        1.0183246276,   0.8872420487,   0.5924714022,   0.2721078093, ... 
        0.0857534478 ];
dR = [   1.0000000000,   0.0000000000,   2.0227991524,   0.0000000000, ... 
         1.3779731739,   0.0000000000,   0.3585196752,   0.0000000000, ... 
         0.0507170923 ];
pA = [   1.0000000000,  -0.6750803038,   0.3249196962 ];
nftA = [   0.0310707168,  -0.1429905110,   0.3365591425,  -0.5803543240, ... 
           0.8434087375,  -1.0409676729,   1.1226171401,  -1.1546805329, ... 
           1.1721171182,  -1.1546506392,   1.1225668157,  -1.0409119221, ... 
           0.8433612560,  -0.5803220628,   0.3365419385,  -0.1429840428, ... 
           0.0310694368 ];
dRftA = [   1.0000000000,  -5.9609815318,  19.6071589274, -45.4886056768, ... 
           82.3805503975, -121.8783083579, 151.3313459521, -160.0597734791, ... 
          145.4779196531, -113.8939468962,  76.7272328967, -44.1905090787, ... 
           21.5108039888,  -8.6470996717,   2.7635155487,  -0.6414482230, ... 
            0.0865747973 ];
pB = [   1.0000000000,   0.0000000000,   0.5095254495 ];
nftB = [   0.0185008839,   0.0000000000,   0.0641596386,   0.0000000000, ... 
           0.1259361516,   0.0000000000,   0.1660765967,   0.0000000000, ... 
           0.1812728613,   0.0000000000,   0.1660714507,   0.0000000000, ... 
           0.1259301085,   0.0000000000,   0.0641562326,   0.0000000000, ... 
           0.0185000005 ];
dRftB = [   1.0000000000,   0.0000000000,   5.3832764012,  -0.0000000000, ... 
           13.4686948703,  -0.0000000000,  20.1972606041,  -0.0000000000, ... 
           19.7677662935,   0.0000000000,  12.9118927452,   0.0000000000, ... 
            5.5109441568,   0.0000000000,   1.4153293556,  -0.0000000000, ... 
            0.1702700843 ];
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

