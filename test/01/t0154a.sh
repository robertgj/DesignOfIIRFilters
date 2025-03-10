#!/bin/sh

prog=svcasc2noise_example_test.m

depends="test/svcasc2noise_example_test.m test_common.m \
svcasc2noise.m butter2pq.m pq2svcasc.m pq2blockKWopt.m \
svcasc2Abcd.m KW.m optKW2.m optKW.m svcascf.m svf.m crossWelch.m \
p2n60.m qroots.oct"

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
cat > test.ok << 'EOF'

Butterworth low-pass filter with N=20, fc=0.100000, n60=311
xbits =
   1   1   1   1   1   1   0   0   0   0

stdydirf =
 Columns 1 through 8:
   351.15   677.66   916.88   902.34   761.64   533.99   353.34   231.13
 Columns 9 and 10:
   159.38   119.02

stdxx1dirf =
 Columns 1 through 8:
   64.009   64.287   66.630   66.161   68.158   66.111   65.145   64.721
 Columns 9 and 10:
   65.538   66.424

stdxx2dirf =
 Columns 1 through 8:
   64.009   64.293   66.631   66.161   68.152   66.110   65.143   64.719
 Columns 9 and 10:
   65.538   66.425

varyddirf = 65.307
est_varyddirf = 90.674
stdyboptf =
 Columns 1 through 8:
   351.75   684.24   910.32   913.07   761.84   547.06   362.29   236.67
 Columns 9 and 10:
   161.19   119.90

stdxx1boptf =
 Columns 1 through 8:
   64.067   65.027   65.844   67.799   67.630   69.644   67.376   66.539
 Columns 9 and 10:
   66.238   66.457

stdxx2boptf =
 Columns 1 through 8:
   64.095   64.920   66.077   67.075   68.069   67.963   66.879   66.328
 Columns 9 and 10:
   66.302   66.939

varydboptf = 19.937
est_varydboptf = 21.937
stdyboptfx =
 Columns 1 through 8:
   351.82   684.30   910.39   913.11   761.85   547.06   362.33   236.70
 Columns 9 and 10:
   161.22   119.96

stdxx1boptfx =
 Columns 1 through 8:
   128.150   130.053   131.684   135.611   135.269   139.298    67.387    66.540
 Columns 9 and 10:
    66.245    66.476

stdxx2boptfx =
 Columns 1 through 8:
   128.207   129.854   132.165   134.157   136.143   135.926    66.887    66.338
 Columns 9 and 10:
    66.314    66.974

varydboptfx = 6.4295
est_varydboptfx = 7.4054
est_varydGoptf = 2.2979
varydGoptf = 2.3840
stdyGoptf = 114.86
stdxxGoptf =
 Columns 1 through 8:
   65.043   63.582   64.119   63.671   64.271   64.155   63.926   62.379
 Columns 9 through 16:
   63.186   62.650   64.594   64.637   64.615   63.505   63.794   63.880
 Columns 17 through 20:
   63.893   63.113   64.394   65.773


Butterworth high-pass filter with N=20, fc=0.100000, n60=279
xbits =
   1   1   1   1   1   1   0   0   0   0

stdydirf =
 Columns 1 through 8:
   417.59   726.29   943.50   984.52   807.15   614.30   453.79   339.75
 Columns 9 and 10:
   270.89   230.80

stdxx1dirf =
 Columns 1 through 8:
   63.949   62.710   62.947   65.460   63.046   63.422   64.453   64.868
 Columns 9 and 10:
   65.235   65.056

stdxx2dirf =
 Columns 1 through 8:
   63.949   62.715   62.947   65.465   63.046   63.422   64.454   64.867
 Columns 9 and 10:
   65.233   65.051

varyddirf = 61.497
est_varyddirf = 81.968
stdyboptf =
 Columns 1 through 8:
   418.25   753.23   988.09   987.71   840.65   632.34   462.57   345.15
 Columns 9 and 10:
   272.75   231.82

stdxx1boptf =
 Columns 1 through 8:
   64.148   65.386   66.044   65.975   66.542   65.783   65.998   66.112
 Columns 9 and 10:
   65.542   65.377

stdxx2boptf =
 Columns 1 through 8:
   64.104   65.316   64.973   66.967   66.833   66.721   65.490   66.119
 Columns 9 and 10:
   65.756   65.203

varydboptf = 20.499
est_varydboptf = 21.574
stdyboptfx =
 Columns 1 through 8:
   417.91   752.39   986.87   986.60   839.88   631.85   462.36   345.07
 Columns 9 and 10:
   272.72   231.81

stdxx1boptfx =
 Columns 1 through 8:
   128.152   130.590   131.898   131.773   132.927   131.404    65.940    66.076
 Columns 9 and 10:
    65.517    65.368

stdxx2boptfx =
 Columns 1 through 8:
   128.059   130.439   129.743   133.733   133.498   133.267    65.414    66.076
 Columns 9 and 10:
    65.723    65.184

varydboptfx = 7.2192
est_varydboptfx = 7.5025
est_varydGoptf = 2.3504
varydGoptf = 2.3733
stdyGoptf = 228.67
stdxxGoptf =
 Columns 1 through 8:
   63.922   63.728   64.051   63.784   64.106   64.041   64.328   64.354
 Columns 9 through 16:
   63.964   64.298   64.304   64.157   64.238   64.173   63.689   64.240
 Columns 17 through 20:
   63.683   64.114   64.106   63.755

EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.out"; fail; fi

#
# this much worked
#
pass
