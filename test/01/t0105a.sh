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

   7.3258e-01   3.3067e-01   2.3146e-01   7.8474e-02

s11 =

   6.8068e-01   9.4375e-01   9.7284e-01   3.5138e-01

s20 =

   0.0000e+00  -7.8816e-01   0.0000e+00   4.8629e-01

s00 =

   1.0000e+00   6.1547e-01   1.0000e+00   8.7380e-01

s02 =

  -0.0000e+00   7.8816e-01  -0.0000e+00  -4.8629e-01

s22 =

   1.0000e+00   6.1547e-01   1.0000e+00   8.7380e-01

sn =

 Columns 1 through 6:

   0.0000e+00   0.0000e+00   7.8474e-02   7.1067e-02   6.8431e-03   7.1089e-02

 Columns 7 through 12:

   7.8411e-02   7.8900e-18   1.0076e-17   1.6329e-17   1.6733e-17   1.4973e-17

sdR =

 Columns 1 through 6:

   1.0000e+00  -0.0000e+00  -1.1714e+00  -0.0000e+00   4.8629e-01  -0.0000e+00

 Columns 7 through 12:

  -1.1337e-17  -0.0000e+00   6.8571e-18  -0.0000e+00   5.9222e-18  -0.0000e+00

max(abs(sn(3:7)-n'))=0.000000
max(abs(sdR(1:5)-dR'))=0.000000
ngABCD =    7.0875e-01
ngABCDap =    3.0000e+00
est_varyd =    1.4240e-01
varyd =    1.4228e-01
est_varydap =    3.3333e-01
varydap =    3.2866e-01
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

