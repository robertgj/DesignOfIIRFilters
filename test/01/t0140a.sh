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
   2.7761e+01
   4.0826e+01
   4.8634e+01
   5.0046e+01
   5.4532e+01
   7.6479e+01
   8.7080e+01
   8.7767e+01
   1.2468e+02
   1.8546e+02
   2.0309e+02
   2.0863e+02
   2.9939e+02
   3.5543e+02
   3.5249e+02
   3.6802e+02
   4.0095e+02
   3.9254e+02
   3.6865e+02
   3.5325e+02
   3.5324e+02
   3.5638e+02
   3.6516e+02
   3.7031e+02
   3.6967e+02
   3.4754e+02
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

