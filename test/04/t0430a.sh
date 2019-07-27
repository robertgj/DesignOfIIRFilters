#!/bin/sh

prog=zahradnik_halfband_test.m

depends="zahradnik_halfband_test.m test_common.m print_polynomial.m \
zahradnik_halfband.m"

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
h_distinct = [   0.0000000862,  -0.0000002229,   0.0000005035,  -0.0000010082, ... 
                 0.0000018614,  -0.0000032360,   0.0000053672,  -0.0000085669, ... 
                 0.0000132410,  -0.0000199086,   0.0000292221,  -0.0000419897, ... 
                 0.0000591991,  -0.0000820413,   0.0001119360,  -0.0001505569, ... 
                 0.0001998569,  -0.0002620936,   0.0003398541,  -0.0004360807, ... 
                 0.0005540965,  -0.0006976345,   0.0008708686,  -0.0010784529, ... 
                 0.0013255704,  -0.0016179984,   0.0019621986,  -0.0023654417, ... 
                 0.0028359849,  -0.0033833242,   0.0040185559,  -0.0047548999, ... 
                 0.0056084627,  -0.0065993670,   0.0077534508,  -0.0091048836, ... 
                 0.0107003069,  -0.0126056168,   0.0149175609,  -0.0177846311, ... 
                 0.0214472536,  -0.0263218218,   0.0331967545,  -0.0437646044, ... 
                 0.0624311330,  -0.1053604747,   0.3180615310,   0.5000000000 ];
EOF
if [ $? -ne 0 ]; then echo "Failed cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok zahradnik_halfband_test_fp_0_225_as_140_coef.m 
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

