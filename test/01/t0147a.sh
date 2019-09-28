#!/bin/sh

prog=pq2blockKWopt_test.m

depends="pq2blockKWopt_test.m test_common.m \
butter2pq.m pq2blockKWopt.m pq2svcasc.m svcasc2Abcd.m KW.m optKW.m optKW2.m \
Abcd2tf.m"

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
Testing Butterworth low-pass filter: N=1, fc=0.2, delta=1.0
ngcasc=0.250000
ngopt=0.250000
Testing Butterworth low-pass filter: N=1, fc=0.2, delta=4.0
ngcasc=0.250000
ngopt=0.250000
Testing Butterworth high-pass filter: N=1, fc=0.2, delta=1.0
ngcasc=0.250000
ngopt=0.250000
Testing Butterworth high-pass filter: N=1, fc=0.2, delta=4.0
ngcasc=0.250000
ngopt=0.250000
Testing Butterworth low-pass filter: N=2, fc=0.2, delta=1.0
ngcasc=0.375000
ngopt=0.375000
Testing Butterworth low-pass filter: N=2, fc=0.2, delta=4.0
ngcasc=0.375000
ngopt=0.375000
Testing Butterworth high-pass filter: N=2, fc=0.2, delta=1.0
ngcasc=0.375000
ngopt=0.375000
Testing Butterworth high-pass filter: N=2, fc=0.2, delta=4.0
ngcasc=0.375000
ngopt=0.375000
Testing Butterworth low-pass filter: N=3, fc=0.2, delta=1.0
ngcasc=0.492851
ngopt=0.470495
Testing Butterworth low-pass filter: N=3, fc=0.2, delta=4.0
ngcasc=0.492851
ngopt=0.470495
Testing Butterworth high-pass filter: N=3, fc=0.2, delta=1.0
ngcasc=0.492851
ngopt=0.470495
Testing Butterworth high-pass filter: N=3, fc=0.2, delta=4.0
ngcasc=0.492851
ngopt=0.470495
Testing Butterworth low-pass filter: N=4, fc=0.2, delta=1.0
ngcasc=0.620998
ngopt=0.555541
Testing Butterworth low-pass filter: N=4, fc=0.2, delta=4.0
ngcasc=0.620998
ngopt=0.555541
Testing Butterworth high-pass filter: N=4, fc=0.2, delta=1.0
ngcasc=0.620998
ngopt=0.555541
Testing Butterworth high-pass filter: N=4, fc=0.2, delta=4.0
ngcasc=0.620998
ngopt=0.555541
Testing Butterworth low-pass filter: N=5, fc=0.2, delta=1.0
ngcasc=0.773210
ngopt=0.635414
Testing Butterworth low-pass filter: N=5, fc=0.2, delta=4.0
ngcasc=0.773210
ngopt=0.635414
Testing Butterworth high-pass filter: N=5, fc=0.2, delta=1.0
ngcasc=0.773210
ngopt=0.635414
Testing Butterworth high-pass filter: N=5, fc=0.2, delta=4.0
ngcasc=0.773210
ngopt=0.635414
Testing Butterworth low-pass filter: N=6, fc=0.2, delta=1.0
ngcasc=0.932077
ngopt=0.712132
Testing Butterworth low-pass filter: N=6, fc=0.2, delta=4.0
ngcasc=0.932077
ngopt=0.712132
Testing Butterworth high-pass filter: N=6, fc=0.2, delta=1.0
ngcasc=0.932077
ngopt=0.712132
Testing Butterworth high-pass filter: N=6, fc=0.2, delta=4.0
ngcasc=0.932077
ngopt=0.712132
Testing Butterworth low-pass filter: N=7, fc=0.2, delta=1.0
ngcasc=1.127115
ngopt=0.786704
Testing Butterworth low-pass filter: N=7, fc=0.2, delta=4.0
ngcasc=1.127115
ngopt=0.786704
Testing Butterworth high-pass filter: N=7, fc=0.2, delta=1.0
ngcasc=1.127115
ngopt=0.786704
Testing Butterworth high-pass filter: N=7, fc=0.2, delta=4.0
ngcasc=1.127115
ngopt=0.786704
Testing Butterworth low-pass filter: N=8, fc=0.2, delta=1.0
ngcasc=1.339326
ngopt=0.859728
Testing Butterworth low-pass filter: N=8, fc=0.2, delta=4.0
ngcasc=1.339326
ngopt=0.859728
Testing Butterworth high-pass filter: N=8, fc=0.2, delta=1.0
ngcasc=1.339326
ngopt=0.859728
Testing Butterworth high-pass filter: N=8, fc=0.2, delta=4.0
ngcasc=1.339326
ngopt=0.859728
Testing Butterworth low-pass filter: N=9, fc=0.2, delta=1.0
ngcasc=1.604386
ngopt=0.931582
Testing Butterworth low-pass filter: N=9, fc=0.2, delta=4.0
ngcasc=1.604386
ngopt=0.931582
Testing Butterworth high-pass filter: N=9, fc=0.2, delta=1.0
ngcasc=1.604386
ngopt=0.931582
Testing Butterworth high-pass filter: N=9, fc=0.2, delta=4.0
ngcasc=1.604386
ngopt=0.931582
Testing Butterworth low-pass filter: N=10, fc=0.2, delta=1.0
ngcasc=1.906128
ngopt=1.002514
Testing Butterworth low-pass filter: N=10, fc=0.2, delta=4.0
ngcasc=1.906128
ngopt=1.002514
Testing Butterworth high-pass filter: N=10, fc=0.2, delta=1.0
ngcasc=1.906128
ngopt=1.002514
Testing Butterworth high-pass filter: N=10, fc=0.2, delta=4.0
ngcasc=1.906128
ngopt=1.002514
Testing Butterworth low-pass filter: N=11, fc=0.2, delta=1.0
ngcasc=2.287087
ngopt=1.072699
Testing Butterworth low-pass filter: N=11, fc=0.2, delta=4.0
ngcasc=2.287087
ngopt=1.072699
Testing Butterworth high-pass filter: N=11, fc=0.2, delta=1.0
ngcasc=2.287087
ngopt=1.072699
Testing Butterworth high-pass filter: N=11, fc=0.2, delta=4.0
ngcasc=2.287087
ngopt=1.072699
Testing Butterworth low-pass filter: N=12, fc=0.2, delta=1.0
ngcasc=2.737933
ngopt=1.142265
Testing Butterworth low-pass filter: N=12, fc=0.2, delta=4.0
ngcasc=2.737933
ngopt=1.142265
Testing Butterworth high-pass filter: N=12, fc=0.2, delta=1.0
ngcasc=2.737933
ngopt=1.142265
Testing Butterworth high-pass filter: N=12, fc=0.2, delta=4.0
ngcasc=2.737933
ngopt=1.142265
Testing Butterworth low-pass filter: N=13, fc=0.2, delta=1.0
ngcasc=3.311736
ngopt=1.211310
Testing Butterworth low-pass filter: N=13, fc=0.2, delta=4.0
ngcasc=3.311736
ngopt=1.211310
Testing Butterworth high-pass filter: N=13, fc=0.2, delta=1.0
ngcasc=3.311736
ngopt=1.211310
Testing Butterworth high-pass filter: N=13, fc=0.2, delta=4.0
ngcasc=3.311736
ngopt=1.211310
Testing Butterworth low-pass filter: N=14, fc=0.2, delta=1.0
ngcasc=4.011908
ngopt=1.279911
Testing Butterworth low-pass filter: N=14, fc=0.2, delta=4.0
ngcasc=4.011908
ngopt=1.279911
Testing Butterworth high-pass filter: N=14, fc=0.2, delta=1.0
ngcasc=4.011908
ngopt=1.279911
Testing Butterworth high-pass filter: N=14, fc=0.2, delta=4.0
ngcasc=4.011908
ngopt=1.279911
Testing Butterworth low-pass filter: N=15, fc=0.2, delta=1.0
ngcasc=4.909201
ngopt=1.348125
Testing Butterworth low-pass filter: N=15, fc=0.2, delta=4.0
ngcasc=4.909201
ngopt=1.348125
Testing Butterworth high-pass filter: N=15, fc=0.2, delta=1.0
ngcasc=4.909201
ngopt=1.348125
Testing Butterworth high-pass filter: N=15, fc=0.2, delta=4.0
ngcasc=4.909201
ngopt=1.348125
Testing Butterworth low-pass filter: N=16, fc=0.2, delta=1.0
ngcasc=6.029720
ngopt=1.416003
Testing Butterworth low-pass filter: N=16, fc=0.2, delta=4.0
ngcasc=6.029720
ngopt=1.416003
Testing Butterworth high-pass filter: N=16, fc=0.2, delta=1.0
ngcasc=6.029720
ngopt=1.416003
Testing Butterworth high-pass filter: N=16, fc=0.2, delta=4.0
ngcasc=6.029720
ngopt=1.416003
Testing Butterworth low-pass filter: N=17, fc=0.2, delta=1.0
ngcasc=7.474773
ngopt=1.483583
Testing Butterworth low-pass filter: N=17, fc=0.2, delta=4.0
ngcasc=7.474773
ngopt=1.483583
Testing Butterworth high-pass filter: N=17, fc=0.2, delta=1.0
ngcasc=7.474773
ngopt=1.483583
Testing Butterworth high-pass filter: N=17, fc=0.2, delta=4.0
ngcasc=7.474773
ngopt=1.483583
Testing Butterworth low-pass filter: N=18, fc=0.2, delta=1.0
ngcasc=9.310519
ngopt=1.550898
Testing Butterworth low-pass filter: N=18, fc=0.2, delta=4.0
ngcasc=9.310519
ngopt=1.550898
Testing Butterworth high-pass filter: N=18, fc=0.2, delta=1.0
ngcasc=9.310519
ngopt=1.550898
Testing Butterworth high-pass filter: N=18, fc=0.2, delta=4.0
ngcasc=9.310519
ngopt=1.550898
Testing Butterworth low-pass filter: N=19, fc=0.2, delta=1.0
ngcasc=11.691753
ngopt=1.617975
Testing Butterworth low-pass filter: N=19, fc=0.2, delta=4.0
ngcasc=11.691753
ngopt=1.617975
Testing Butterworth high-pass filter: N=19, fc=0.2, delta=1.0
ngcasc=11.691753
ngopt=1.617975
Testing Butterworth high-pass filter: N=19, fc=0.2, delta=4.0
ngcasc=11.691753
ngopt=1.617975
Testing Butterworth low-pass filter: N=20, fc=0.2, delta=1.0
ngcasc=14.755383
ngopt=1.684839
Testing Butterworth low-pass filter: N=20, fc=0.2, delta=4.0
ngcasc=14.755383
ngopt=1.684839
Testing Butterworth high-pass filter: N=20, fc=0.2, delta=1.0
ngcasc=14.755383
ngopt=1.684839
Testing Butterworth high-pass filter: N=20, fc=0.2, delta=4.0
ngcasc=14.755383
ngopt=1.684839
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

