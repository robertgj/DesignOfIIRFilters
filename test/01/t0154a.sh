#!/bin/sh

prog=svcasc2noise_example_test.m

depends="svcasc2noise_example_test.m test_common.m \
svcasc2noise.m butter2pq.m pq2svcasc.m pq2blockKWopt.m \
svcasc2Abcd.m KW.m optKW2.m optKW.m svcascf.m svf.m crossWelch.m"

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

Butterworth low-pass filter with N=20, fc=0.100000
xbits =
   1   1   1   1   1   1  -0  -0   0   0

parcellfun: 0/5 jobs doneparcellfun: 0/5 jobs doneparcellfun: 0/5 jobs doneparcellfun: 0/5 jobs doneparcellfun: 0/5 jobs doneparcellfun: 1/5 jobs doneparcellfun: 2/5 jobs doneparcellfun: 3/5 jobs doneparcellfun: 4/5 jobs doneparcellfun: 5/5 jobs done
stdydirf =
 Columns 1 through 8:
   350.30   676.11   915.00   900.59   760.01   532.86   352.74   231.00
 Columns 9 and 10:
   159.57   119.32

stdxx1dirf =
 Columns 1 through 8:
   63.838   64.133   66.489   66.030   68.010   65.967   65.025   64.667
 Columns 9 and 10:
   65.595   66.575

stdxx2dirf =
 Columns 1 through 8:
   63.839   64.136   66.490   66.031   68.015   65.967   65.031   64.667
 Columns 9 and 10:
   65.606   66.593

varyddirf =  65.502
est_varyddirf =  90.674
stdyboptf =
 Columns 1 through 8:
   350.90   682.65   908.47   911.26   760.12   545.83   361.62   236.50
 Columns 9 and 10:
   161.40   120.24

stdxx1boptf =
 Columns 1 through 8:
   63.834   64.837   65.687   67.650   67.485   69.474   67.229   66.440
 Columns 9 and 10:
   66.252   66.591

stdxx2boptf =
 Columns 1 through 8:
   63.898   64.753   65.938   66.939   67.925   67.807   66.755   66.271
 Columns 9 and 10:
   66.384   67.126

varydboptf =  20.351
est_varydboptf =  21.937
stdyboptfx =
 Columns 1 through 8:
   351.00   682.79   908.57   911.35   760.18   545.89   361.70   236.56
 Columns 9 and 10:
   161.41   120.26

stdxx1boptfx =
 Columns 1 through 8:
   127.694   129.685   131.373   135.320   134.984   138.968    67.252    66.445
 Columns 9 and 10:
    66.262    66.596

stdxx2boptfx =
 Columns 1 through 8:
   127.824   129.532   131.891   133.894   135.864   135.629    66.773    66.289
 Columns 9 and 10:
    66.388    67.139

varydboptfx =  6.3163
est_varydboptfx =  7.4054
est_varydGoptf =  2.2740
varydGoptf =  2.3447
stdyGoptf =  113.94
stdxxGoptf =
 Columns 1 through 8:
   64.044   63.685   63.943   61.626   61.488   63.515   63.726   63.838
 Columns 9 through 16:
   62.331   64.453   64.243   62.790   63.669   62.624   62.608   63.724
 Columns 17 through 20:
   64.064   63.038   64.052   65.497


Butterworth high-pass filter with N=20, fc=0.100000
xbits =
   1   1   1   1   1   1  -0  -0   0   0

parcellfun: 0/5 jobs doneparcellfun: 0/5 jobs doneparcellfun: 0/5 jobs doneparcellfun: 0/5 jobs doneparcellfun: 0/5 jobs doneparcellfun: 1/5 jobs doneparcellfun: 2/5 jobs doneparcellfun: 3/5 jobs doneparcellfun: 4/5 jobs doneparcellfun: 5/5 jobs done
stdydirf =
 Columns 1 through 8:
   416.66   724.34   940.75   981.65   804.54   612.41   452.57   339.10
 Columns 9 and 10:
   270.54   230.61

stdxx1dirf =
 Columns 1 through 8:
   63.838   62.562   62.796   65.297   62.861   63.224   64.225   64.630
 Columns 9 and 10:
   65.003   64.855

stdxx2dirf =
 Columns 1 through 8:
   63.839   62.564   62.796   65.297   62.861   63.225   64.225   64.631
 Columns 9 and 10:
   65.004   64.857

varyddirf =  61.327
est_varyddirf =  81.968
stdyboptf =
 Columns 1 through 8:
   417.18   750.87   984.71   984.38   837.66   630.23   461.24   344.44
 Columns 9 and 10:
   272.38   231.62

stdxx1boptf =
 Columns 1 through 8:
   63.973   65.177   65.832   65.745   66.306   65.530   65.750   65.883
 Columns 9 and 10:
   65.366   65.252

stdxx2boptf =
 Columns 1 through 8:
   63.954   65.119   64.774   66.748   66.601   66.472   65.240   65.876
 Columns 9 and 10:
   65.551   65.050

varydboptf =  20.341
est_varydboptf =  21.574
stdyboptfx =
 Columns 1 through 8:
   416.84   749.99   983.52   983.29   836.94   629.77   461.04   344.37
 Columns 9 and 10:
   272.37   231.62

stdxx1boptfx =
 Columns 1 through 8:
   127.808   130.166   131.476   131.320   132.467   130.909    65.697    65.853
 Columns 9 and 10:
    65.342    65.248

stdxx2boptfx =
 Columns 1 through 8:
   127.766   130.040   129.344   133.307   133.035   132.786    65.166    65.841
 Columns 9 and 10:
    65.523    65.036

varydboptfx =  7.2464
est_varydboptfx =  7.5025
est_varydGoptf =  2.3417
varydGoptf =  2.2568
stdyGoptf =  228.44
stdxxGoptf =
 Columns 1 through 8:
   63.789   63.956   63.776   63.797   64.070   64.045   63.827   63.397
 Columns 9 through 16:
   63.762   64.063   63.817   63.968   64.211   63.996   64.142   64.220
 Columns 17 through 20:
   63.889   63.702   64.019   63.800

EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.out"; fail; fi

#
# this much worked
#
pass
