#!/bin/sh

prog=zolotarev_vlcek_unbehauen_table_iv.max

depends=$prog

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

# If maxima is not found then return the aet code for "pass"
which maxima >/dev/null 2>&1
if test $? -ne 0; then 
    echo SKIPPED ${0#$here"/"} $prog "maxima not found!" ;
    exit 0; 
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
cat > test.ok << 'EOF'
(m+2)*wm*wp*ws-(m+2)^2*wm*wp*ws;
(m+1)^2*(wp*ws+wm*ws+wm*wp)+(m+1)*((-2*wp*ws)-wm*ws+wm*wq-wm*wp);
m^2*(wm*wp*ws-ws-wp-wm)+m*(2*ws-wq+2*wp)-n^2*wm^3;
(m-1)*(wp*ws-wm*wq-1)+(m-1)^2*((-wp*ws)-wm*ws-wm*wp+1)+3*n^2*wm^2;
(m-2)^2*(ws+wp+wm)+(m-2)*((-ws)+wq-wp+wm)-3*n^2*wm;
n^2-(m-3)^2;

EOF
if [ $? -ne 0 ]; then echo "Failed output cat of test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running maxima -b $prog"
maxima -b $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok ${prog//max/out}
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

