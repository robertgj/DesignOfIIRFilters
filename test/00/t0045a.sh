#!/bin/sh

prog=fixResultNaN_test.m

depends="fixResultNaN_test.m \
test_common.m print_polynomial.m print_pole_zero.m fixResultNaN.m"
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
X = NaN
X =    0.0000e+00
X =

   1.0000e+00          NaN   2.0000e+00

X =

   1.0000e+00   0.0000e+00   2.0000e+00

X =

   1.0000e+00          NaN   2.0000e+00
          NaN   3.0000e+00   4.0000e+00

X =

   1.0000e+00   0.0000e+00   2.0000e+00
   0.0000e+00   3.0000e+00   4.0000e+00

X =

ans(:,:,1) =

          NaN   1.0000e+00   1.0000e+00
   1.0000e+00   1.0000e+00   1.0000e+00
   1.0000e+00          NaN   1.0000e+00

ans(:,:,2) =

   1.0000e+00   1.0000e+00   1.0000e+00
   1.0000e+00   1.0000e+00   1.0000e+00
   1.0000e+00   1.0000e+00   1.0000e+00

ans(:,:,3) =

   1.0000e+00          NaN   1.0000e+00
   1.0000e+00   1.0000e+00   1.0000e+00
   1.0000e+00   1.0000e+00   1.0000e+00

X =

ans(:,:,1) =

   0.0000e+00   1.0000e+00   1.0000e+00
   1.0000e+00   1.0000e+00   1.0000e+00
   1.0000e+00   0.0000e+00   1.0000e+00

ans(:,:,2) =

   1.0000e+00   1.0000e+00   1.0000e+00
   1.0000e+00   1.0000e+00   1.0000e+00
   1.0000e+00   1.0000e+00   1.0000e+00

ans(:,:,3) =

   1.0000e+00   0.0000e+00   1.0000e+00
   1.0000e+00   1.0000e+00   1.0000e+00
   1.0000e+00   1.0000e+00   1.0000e+00

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

