#!/bin/sh

prog=scs_pnorm_test.m

depends="test/scs_pnorm_test.m test_common.m print_polynomial.m"

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

# If scs.m does not exist then return the aet code for "pass"
octave --no-gui -q --eval 'if ~exist("scs.m"), error("Not found");endif;'
if  test $? -ne 0 ; then 
    echo SKIPPED $prog scs.m not found! ; exit 0; 
fi

mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
for file in $depends;do \
  cp -R src/$file $tmp; \
  if [ $? -ne 0 ]; then echo "Failed cp "$file; fail; fi \
done
cd $tmp
if [ $? -ne 0 ]; then echo "Failed cd"; fail; fi

#
# the output should look like this
#
cat > test.dir_pobj.ok << 'EOF'
dir_info.pobj = [ 96.3349843 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.dir_pobj.ok"; fail; fi

cat > test.indir_pobj.ok << 'EOF'
indir_info.pobj = [ 96.3348210 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.indir_pobj.ok"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

nstr="scs_pnorm_test"

diff -Bb test.dir_pobj.ok $nstr"_dir_info_pobj_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.dir_pobj.ok"; fail; fi

diff -Bb test.indir_pobj.ok $nstr"_indir_info_pobj_coef.m"
if [ $? -ne 0 ]; then echo "Failed diff -Bb of test.indir_pobj.ok"; fail; fi

#
# this much worked
#
pass
