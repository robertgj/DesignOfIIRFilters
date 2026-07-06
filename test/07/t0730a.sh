#!/bin/sh

prog=schurOneMR2latticeFilter_test.m

depends="test/schurOneMR2latticeFilter_test.m test_common.m \
tf2schurOneMlattice.m schurOneMscale.m schurOneMR2lattice2Abcd.m \
KW.m p2n60.m svf.m crossWelch.m \
schurOneMR2latticeFilter.oct schurexpand.oct schurdecomp.oct \
qroots.oct Abcd2tf.oct reprand.oct complex_zhong_inverse.oct"

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
# the output should look like this (as for m-file test in t0582a.sh)
#
cat > test.ok << 'EOF'

Testing x=1, Nk=4
stdxx =
   128.61   128.61   127.54   125.84   127.53

stdxxf =
   128.60   128.60   127.53   125.84   127.53

stdxxABCD =
   128.61   128.61   127.53   125.83   127.54

stdxxABCDf =
   128.60   128.61   127.53   125.83   127.54

stdxxABCDap =
   128.61   128.61   127.53   127.54

stdxxABCDapf =
   128.60   128.61   127.53   127.54


Testing x=2, Nk=6
stdxx =
   128.05   128.04   127.27   129.22   127.26   128.12   128.90   128.10

stdxxf =
   128.03   128.02   127.25   129.20   127.25   128.12   128.89   128.10

stdxxABCD =
   128.04   128.04   127.27   129.22   127.24   128.12   128.90   128.10

stdxxABCDf =
   128.02   128.02   127.25   129.20   127.23   128.12   128.89   128.10

stdxxABCDap =
   128.04   128.04   127.27   127.24   128.12   128.10

stdxxABCDapf =
   128.02   128.02   127.25   127.23   128.12   128.10


Testing x=3, Nk=12
stdxx =
 Columns 1 through 8:
   127.70   127.71   127.72   127.75   127.74   128.05   128.14   128.08
 Columns 9 through 16:
   127.94   127.64   127.97   127.95   127.73   127.99   127.98   127.69
 Column 17:
   128.02

stdxxf =
 Columns 1 through 8:
   127.70   127.70   127.72   127.76   127.74   128.05   128.14   128.08
 Columns 9 through 16:
   127.94   127.64   127.96   127.96   127.73   127.99   127.98   127.69
 Column 17:
   128.02

stdxxABCD =
 Columns 1 through 8:
   127.71   127.71   127.73   127.76   127.74   128.06   128.15   128.08
 Columns 9 through 16:
   127.94   127.65   127.96   127.96   127.73   127.99   127.98   127.69
 Column 17:
   128.02

stdxxABCDf =
 Columns 1 through 8:
   127.70   127.71   127.73   127.77   127.74   128.06   128.15   128.08
 Columns 9 through 16:
   127.94   127.64   127.96   127.97   127.73   127.99   127.99   127.69
 Column 17:
   128.02

stdxxABCDap =
 Columns 1 through 8:
   127.71   127.71   127.73   127.74   128.06   128.08   127.94   127.96
 Columns 9 through 12:
   127.96   127.99   127.98   128.02

stdxxABCDapf =
 Columns 1 through 8:
   127.70   127.71   127.73   127.74   128.06   128.08   127.94   127.96
 Columns 9 through 12:
   127.97   127.99   127.99   128.02


Testing x=4, Nk=20
stdxx =
 Columns 1 through 8:
   128.27   128.29   128.41   128.36   128.43   128.04   129.03   128.05
 Columns 9 through 16:
   128.58   128.74   128.59   128.11   128.99   128.12   128.14   128.79
 Columns 17 through 24:
   128.15   128.08   128.79   128.09   128.00   128.93   128.02   127.96
 Columns 25 through 29:
   128.97   127.99   127.95   129.01   127.98

stdxxf =
 Columns 1 through 8:
   128.27   128.29   128.42   128.37   128.44   128.04   129.04   128.05
 Columns 9 through 16:
   128.58   128.75   128.59   128.11   129.00   128.12   128.14   128.80
 Columns 17 through 24:
   128.13   128.09   128.80   128.09   128.00   128.94   128.02   127.96
 Columns 25 through 29:
   128.98   127.99   127.96   129.01   127.98

stdxxABCD =
 Columns 1 through 8:
   128.29   128.28   128.41   128.36   128.42   128.04   129.03   128.05
 Columns 9 through 16:
   128.58   128.74   128.58   128.11   128.99   128.12   128.13   128.79
 Columns 17 through 24:
   128.15   128.09   128.79   128.10   128.01   128.92   128.03   127.96
 Columns 25 through 29:
   128.98   127.99   127.96   129.01   127.99

stdxxABCDf =
 Columns 1 through 8:
   128.29   128.28   128.42   128.36   128.44   128.04   129.04   128.05
 Columns 9 through 16:
   128.58   128.75   128.58   128.12   129.00   128.12   128.13   128.80
 Columns 17 through 24:
   128.14   128.09   128.80   128.09   128.01   128.93   128.02   127.96
 Columns 25 through 29:
   128.98   127.98   127.97   129.02   127.99

stdxxABCDap =
 Columns 1 through 8:
   128.29   128.28   128.41   128.42   128.04   128.05   128.58   128.58
 Columns 9 through 16:
   128.11   128.12   128.13   128.15   128.09   128.10   128.01   128.03
 Columns 17 through 20:
   127.96   127.99   127.96   127.99

stdxxABCDapf =
 Columns 1 through 8:
   128.29   128.28   128.42   128.44   128.04   128.05   128.58   128.58
 Columns 9 through 16:
   128.12   128.12   128.13   128.14   128.09   128.09   128.01   128.02
 Columns 17 through 20:
   127.96   127.98   127.97   127.99

EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"
octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass
