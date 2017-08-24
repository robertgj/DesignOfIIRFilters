#!/bin/sh

prog=schurFIRlatticeFilter_test.m

depends="schurFIRlatticeFilter_test.m test_common.m schurFIRlatticeFilter.m \
schurFIRdecomp.oct crossWelch.m"

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
   8.0050e+00
   1.1474e+01
   1.9994e+01
   3.6625e+01
   5.7057e+01
   4.1527e+01
   5.9125e+01
   5.7324e+01
   5.7320e+01
   8.1896e+01
   9.2606e+01
   9.3372e+01
   1.2796e+02
   1.9303e+02
   2.0852e+02
   2.1345e+02
   3.0524e+02
   3.6279e+02
   3.5926e+02
   3.6741e+02
   4.0747e+02
   3.9859e+02
   3.6899e+02
   3.5449e+02
   3.5413e+02
   3.5553e+02
   3.6670e+02
   3.7177e+02
   3.7161e+02
   3.4910e+02
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

