#!/bin/sh

prog=casc2tf_tf2casc_test.m

depends="casc2tf_tf2casc_test.m test_common.m tf2casc.m casc2tf.m \
qroots.m qzsolve.oct"


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
tol =  0.000000000010000
casc2tf_tf2casc_test.m : a=[]
p =  1
casc2tf_tf2casc_test.m : p=1
p =  1
a = [](0x0)
k =  1
casc2tf_tf2casc_test.m : even n, real poles
a =
  -6
   9
  -4
   4
  -4
   5

k =  4
pp =
      4
    -56
    328
  -1032
   1844
  -1776
    720

casc2tf_tf2casc_test.m : odd n
p =
     6   -60   252  -576   798  -756   552  -240

a =
 Columns 1 through 6:
  -2.0000e+00  -4.0000e+00   4.0000e+00  -4.0000e+00   5.0000e+00   2.5037e-33
 Column 7:
   1.0000e+00

k =  6
pp =
 Columns 1 through 7:
     6.0000   -60.0000   252.0000  -576.0000   798.0000  -756.0000   552.0000
 Column 8:
  -240.0000

casc2tf_tf2casc_test.m : from frm2ndOrderCascade_socp.m
dk =
  -1.2724131
   0.4044775
  -0.2116238
   0.0962459
   0.1991686
  -0.0116871
   0.1872238
   0.0030039
   0.2958810
   0.5601777

d =
   1.00000000000
  -0.80176350140
   0.46058715535
  -0.50283194843
   0.12246631452
   0.02829625253
  -0.00582639252
   0.00480034604
   0.00077645320
  -0.00003098238
  -0.00000076560

pr =
  -0.14794 + 0.73368i
  -0.14794 - 0.73368i
   0.65298 + 0.00000i
   0.61943 + 0.00000i
   0.10581 + 0.29163i
   0.10581 - 0.29163i
  -0.24657 + 0.00000i
  -0.16950 + 0.00000i
   0.04740 + 0.00000i
  -0.01772 + 0.00000i

ans =
   1.00000   0.29588   0.56018

ans =
   1.00000  -1.27241   0.40448

ans =
   1.000000  -0.211624   0.096246

ans =
   1.000000   0.416070   0.041794

ans =
   1.00000000  -0.02967721  -0.00084001

ans =
   1.00000  -1.27241   0.40448

ans =
   1.000000   0.416070   0.041794

ans =
   1.00000000  -0.02967721  -0.00084001

ans =
   1.000000  -0.211624   0.096246

ans =
   1.00000   0.29588   0.56018

dktmp =
  -1.27241307
   0.40447747
   0.41606960
   0.04179368
  -0.02967721
  -0.00084001
  -0.21162383
   0.09624587
   0.29588100
   0.56017774

k =  1
dd =
   1.00000000000
  -0.80176350140
   0.46058715535
  -0.50283194843
   0.12246631452
   0.02829625253
  -0.00582639252
   0.00480034604
   0.00077645320
  -0.00003098238
  -0.00000076560

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

