#!/bin/sh

prog=schur_retimed_test.m

depends="schur_retimed_test.m test_common.m \
schurdecomp.oct schurNSscale.oct schurexpand.oct \
tf2Abcd.m Abcd2tf.m WISEJ.m tf2schurNSlattice.m KW.m svf.m crossWelch.m"
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
s10 =

   7.3242e-01   3.3058e-01   2.3146e-01   7.8437e-02

s11 =

   6.8085e-01   9.4378e-01   9.7284e-01   3.5138e-01

s20 =

   0.0000e+00  -7.8817e-01   0.0000e+00   4.8630e-01

s00 =

   1.0000e+00   6.1546e-01   1.0000e+00   8.7379e-01

s02 =

  -0.0000e+00   7.8817e-01  -0.0000e+00  -4.8630e-01

s22 =

   1.0000e+00   6.1546e-01   1.0000e+00   8.7379e-01

sn =

 Columns 1 through 6:

   0.0000e+00   0.0000e+00   7.8437e-02   7.1066e-02   6.8570e-03   7.1064e-02

 Columns 7 through 12:

   7.8448e-02   0.0000e+00   2.2332e-19   2.0233e-19   4.1193e-19   5.5786e-19

sdR =

 Columns 1 through 6:

   1.0000e+00  -0.0000e+00  -1.1715e+00  -0.0000e+00   4.8630e-01  -0.0000e+00

 Columns 7 through 12:

   2.8471e-18  -0.0000e+00   1.6676e-18  -0.0000e+00   8.9521e-19  -0.0000e+00

max(abs(sn(3:7)-n'))=0.000000
max(abs(sdR(1:5)-dR'))=0.000000
ngABCD =    7.0879e-01
ngABCDap =    3.0000e+00
est_varyd =    1.4240e-01
varyd =    1.4275e-01
est_varydap =    3.3333e-01
varydap =    3.2847e-01
stdxx =

 Columns 1 through 6:

   1.2942e+02   1.3039e+02   1.2943e+02   1.2828e+02   1.2828e+02   1.3050e+02

 Columns 7 through 11:

   1.2827e+02   1.3063e+02   1.2828e+02   1.2800e+02   1.2800e+02

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

