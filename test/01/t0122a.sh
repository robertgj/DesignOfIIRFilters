#!/bin/sh

prog=ellip5NS_test.m

depends="ellip5NS_test.m test_common.m \
schurexpand.oct schurdecomp.oct schurNSscale.oct \
tf2schurNSlattice.m schurNSlatticeNoiseGain.m schurNSlattice2Abcd.oct \
schurNSlatticeFilter.m KW.m optKW.m tf2Abcd.m svf.m bin2SD.oct crossWelch.m"

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
n =

 Columns 1 through 6:

   6.6160e-03  -2.9674e-02   4.9860e-02  -2.6776e-02  -2.6776e-02   4.9860e-02

 Columns 7 and 8:

  -2.9674e-02   6.6160e-03

d =

 Columns 1 through 6:

   1.0000e+00  -6.4328e+00   1.7948e+01  -2.8137e+01   2.6756e+01  -1.5428e+01

 Columns 7 and 8:

   4.9940e+00  -6.9997e-01

s10 =

 Columns 1 through 6:

   7.7668e-01   8.4822e-01   3.6434e-01   3.8757e-01   8.9744e-02   5.8424e-02

 Column 7:

   6.6160e-03

s11 =

 Columns 1 through 6:

   6.2989e-01   5.2965e-01   9.3127e-01   9.2184e-01   9.9596e-01   9.9829e-01

 Column 7:

   3.0882e-01

s20 =

 Columns 1 through 6:

  -9.5361e-01   9.9916e-01  -9.7369e-01   9.8916e-01  -9.8153e-01   9.6309e-01

 Column 7:

  -6.9997e-01

s00 =

 Columns 1 through 6:

   3.0105e-01   4.0872e-02   2.2788e-01   1.4685e-01   1.9130e-01   2.6917e-01

 Column 7:

   7.1417e-01

s02 =

 Columns 1 through 6:

   9.5361e-01  -9.9916e-01   9.7369e-01  -9.8916e-01   9.8153e-01  -9.6309e-01

 Column 7:

   6.9997e-01

s22 =

 Columns 1 through 6:

   3.0105e-01   4.0872e-02   2.2788e-01   1.4685e-01   1.9130e-01   2.6917e-01

 Column 7:

   7.1417e-01

c =

 Columns 1 through 6:

   8.7941e-02   1.0844e-01   2.2359e-01   1.0313e-01   1.1900e-01   2.7668e-02

 Columns 7 and 8:

   1.8043e-02   6.6160e-03

S =

 Columns 1 through 6:

   1.5141e-05   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
  -4.7961e-05   5.0294e-05   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
   1.2295e-03  -2.3459e-03   1.2305e-03   0.0000e+00   0.0000e+00   0.0000e+00
  -5.2579e-03   1.5419e-02  -1.5548e-02   5.3999e-03   0.0000e+00   0.0000e+00
   3.6374e-02  -1.4054e-01   2.0887e-01  -1.4130e-01   3.6773e-02   0.0000e+00
  -1.8868e-01   9.1514e-01  -1.8063e+00   1.8129e+00  -9.2527e-01   1.9223e-01
   6.8781e-01  -4.0116e+00   9.8867e+00  -1.3174e+01   1.0010e+01  -4.1126e+00
  -6.9997e-01   4.9940e+00  -1.5428e+01   2.6756e+01  -2.8137e+01   1.7948e+01

 Columns 7 and 8:

   0.0000e+00   0.0000e+00
   0.0000e+00   0.0000e+00
   0.0000e+00   0.0000e+00
   0.0000e+00   0.0000e+00
   0.0000e+00   0.0000e+00
   0.0000e+00   0.0000e+00
   7.1417e-01   0.0000e+00
  -6.4328e+00   1.0000e+00

ng =    4.2777e+00
ngap =    1.3000e+01
A =

 Columns 1 through 6:

   9.5361e-01   3.0105e-01   0.0000e+00   0.0000e+00   0.0000e+00   0.0000e+00
  -3.0080e-01   9.5281e-01   4.0872e-02   0.0000e+00   0.0000e+00   0.0000e+00
   1.1981e-02  -3.7950e-02   9.7288e-01   2.2788e-01   0.0000e+00   0.0000e+00
  -2.7735e-03   8.7854e-03  -2.2522e-01   9.6313e-01   1.4685e-01   0.0000e+00
   4.0414e-04  -1.2802e-03   3.2818e-02  -1.4034e-01   9.7089e-01   1.9130e-01
  -7.5858e-05   2.4029e-04  -6.1599e-03   2.6342e-02  -1.8224e-01   9.4531e-01
   1.4840e-05  -4.7007e-05   1.2051e-03  -5.1534e-03   3.5651e-02  -1.8493e-01

 Column 7:

   0.0000e+00
   0.0000e+00
   0.0000e+00
   0.0000e+00
   0.0000e+00
   2.6917e-01
   6.7414e-01

B =

   0.0000e+00
   0.0000e+00
   0.0000e+00
   0.0000e+00
   0.0000e+00
   0.0000e+00
   7.1417e-01

C =

 Columns 1 through 6:

   8.7941e-02   1.0844e-01   2.2359e-01   1.0313e-01   1.1900e-01   2.7668e-02

 Column 7:

   1.8043e-02

D =    6.6160e-03
Cap =

 Columns 1 through 6:

   1.5141e-05  -4.7961e-05   1.2295e-03  -5.2579e-03   3.6374e-02  -1.8868e-01

 Column 7:

   6.8781e-01

Dap =   -6.9997e-01
ngopt =    1.4987e+00
ngoptap =    7.0000e+00
ngdir =    2.4159e+11
ngdirap =    1.8058e+12
est_varyd =    4.3981e-01
varyd =    4.6637e-01
est_varyoptd =    2.0823e-01
varyoptd =    2.1323e-01
est_varydird =    2.0132e+10
varydird =    3.4465e+07
est_varyapd =    1.1667e+00
varyapd =    1.2239e+00
stdxx =

 Columns 1 through 6:

   1.2313e+02   1.2269e+02   1.3024e+02   1.2999e+02   1.3070e+02   1.3078e+02

 Column 7:

   1.2844e+02

stdxxopt =

 Columns 1 through 6:

   1.3056e+02   1.2684e+02   1.2461e+02   1.2921e+02   1.2937e+02   1.2707e+02

 Column 7:

   1.3004e+02

stdxxdir =

 Columns 1 through 6:

   2.0636e+09   2.0639e+09   2.0640e+09   2.0641e+09   2.0641e+09   2.0641e+09

 Column 7:

   2.0641e+09

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

