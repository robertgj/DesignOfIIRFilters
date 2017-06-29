#!/bin/sh

prog=ellip5OneM_test.m

depends="ellip5OneM_test.m test_common.m \
schurexpand.oct schurdecomp.oct schurOneMscale.m \
tf2schurOneMlattice.m schurOneMlatticeNoiseGain.m schurOneMlattice2Abcd.oct \
schurOneMlatticeFilter.m KW.m bin2SD.oct crossWelch.m"

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
fc =    5.0000e-02
k =

  -9.6570e-01   9.9059e-01  -9.8048e-01   9.6197e-01  -6.9606e-01

epsilon =

   1.0000e+00   1.0000e+00   1.0000e+00   1.0000e+00   1.0000e+00

p =

   5.7977e-01   4.3892e+00   3.0185e-01   3.0407e+00   4.2333e-01

c =

   4.0899e-01   3.0904e-02   4.9245e-01   1.1925e-02   4.8374e-02   7.3595e-03

S =

   1.3705e-03   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
  -5.0972e-03   5.2783e-03   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   3.8194e-02  -7.4119e-02   3.8557e-02   0.0000e+00   0.0000e+00   0.0000e+00
  -1.9229e-01   5.6391e-01  -5.6748e-01   1.9612e-01   0.0000e+00   0.0000e+00
   6.9068e-01  -2.7025e+00   4.0505e+00  -2.7547e+00   7.1799e-01   0.0000e+00
  -6.9606e-01   3.6326e+00  -7.6908e+00   8.2614e+00  -4.5064e+00   1.0000e+00

ng =    2.5504e+00
ngap =    9.0000e+00
est_varyd =    2.9587e-01
varyd =    2.8319e-01
est_varyapd =    8.3333e-01
varyapd =    7.9628e-01
stdxf =

   1.2992e+02   1.2897e+02   1.3023e+02   1.3042e+02   1.2856e+02

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

