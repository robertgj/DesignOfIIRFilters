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
   128.29   128.28   127.23   125.54   127.23   128.07   125.40   128.07

stdxxf =
   128.29   128.28   127.24   125.53   127.24   128.08   125.38   128.07

stdxxABCD =
   128.28   128.29   127.23   125.54   127.23   128.07   125.40   128.07

stdxxABCDf =
   128.28   128.29   127.25   125.53   127.24   128.08   125.39   128.07

stdxxABCDap =
   128.28   128.29   127.23   127.23   128.07   128.07

stdxxABCDapf =
   128.28   128.29   127.25   127.24   128.08   128.07


Testing x=3, Nk=12
stdxx =
 Columns 1 through 8:
   127.38   127.38   127.09   126.87   127.10   127.63   126.43   127.62
 Columns 9 through 16:
   127.81   125.99   127.81   128.02   126.04   128.02   128.02   126.09
 Column 17:
   128.02

stdxxf =
 Columns 1 through 8:
   127.38   127.38   127.10   126.88   127.10   127.64   126.43   127.62
 Columns 9 through 16:
   127.82   125.99   127.81   128.03   126.04   128.02   128.03   126.08
 Column 17:
   128.02

stdxxABCD =
 Columns 1 through 8:
   127.38   127.38   127.10   126.88   127.09   127.63   126.42   127.63
 Columns 9 through 16:
   127.81   125.99   127.81   128.02   126.04   128.02   128.02   126.09
 Column 17:
   128.03

stdxxABCDf =
 Columns 1 through 8:
   127.38   127.38   127.11   126.88   127.09   127.64   126.42   127.63
 Columns 9 through 16:
   127.82   125.99   127.81   128.03   126.04   128.02   128.03   126.09
 Column 17:
   128.02

stdxxABCDap =
 Columns 1 through 8:
   127.38   127.38   127.10   127.09   127.63   127.63   127.81   127.81
 Columns 9 through 12:
   128.02   128.02   128.02   128.03

stdxxABCDapf =
 Columns 1 through 8:
   127.38   127.38   127.11   127.09   127.64   127.63   127.82   127.81
 Columns 9 through 12:
   128.03   128.02   128.03   128.02


Testing x=4, Nk=20
stdxx =
 Columns 1 through 8:
   129.06   129.04   127.63   128.51   127.59   127.49   126.67   127.44
 Columns 9 through 16:
   128.05   127.10   128.02   127.33   126.55   127.29   127.67   126.19
 Columns 17 through 24:
   127.64   128.16   126.21   128.14   128.01   126.38   128.00   127.96
 Columns 25 through 29:
   126.56   127.94   128.00   126.60   127.98

stdxxf =
 Columns 1 through 8:
   129.07   129.05   127.64   128.53   127.60   127.51   126.69   127.46
 Columns 9 through 16:
   128.07   127.11   128.03   127.35   126.57   127.31   127.69   126.21
 Columns 17 through 24:
   127.66   128.18   126.23   128.15   128.03   126.40   128.01   127.98
 Columns 25 through 29:
   126.59   127.94   128.03   126.62   127.98

stdxxABCD =
 Columns 1 through 8:
   129.04   129.04   127.61   128.50   127.58   127.49   126.66   127.46
 Columns 9 through 16:
   128.05   127.10   128.02   127.33   126.57   127.30   127.67   126.18
 Columns 17 through 24:
   127.64   128.17   126.21   128.15   128.01   126.40   127.99   127.96
 Columns 25 through 29:
   126.57   127.94   128.00   126.60   127.98

stdxxABCDf =
 Columns 1 through 8:
   129.05   129.04   127.62   128.52   127.60   127.50   126.68   127.47
 Columns 9 through 16:
   128.06   127.11   128.03   127.35   126.58   127.32   127.69   126.20
 Columns 17 through 24:
   127.66   128.19   126.23   128.16   128.03   126.42   128.00   127.98
 Columns 25 through 29:
   126.59   127.94   128.02   126.62   127.98

stdxxABCDap =
 Columns 1 through 8:
   129.04   129.04   127.61   127.58   127.49   127.46   128.05   128.02
 Columns 9 through 16:
   127.33   127.30   127.67   127.64   128.17   128.15   128.01   127.99
 Columns 17 through 20:
   127.96   127.94   128.00   127.98

stdxxABCDapf =
 Columns 1 through 8:
   129.05   129.04   127.62   127.60   127.50   127.47   128.06   128.03
 Columns 9 through 16:
   127.35   127.32   127.69   127.66   128.19   128.16   128.03   128.00
 Columns 17 through 20:
   127.98   127.94   128.02   127.98

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
