#!/bin/sh

prog=zolotarev_vlcek_unbehauen_table_v.max

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
which maxima
if test $? -ne 0; then 
    echo SKIPPED $descr "maxima not found!" ; exit 0; 
fi

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

(n-m+3)*(n+m-3);
2*((-(m-2)*ws)+(m-2)^2*ws+(m-2)*wq-(m-2)*wp+(m-2)^2*wp-3*n^2*wm+(m-2)*wm+(m-2)^2*wm);
4*(m-1)*wp*ws-4*(m-1)^2*wp*ws-4*(m-1)^2*wm*ws-4*(m-1)*wm*wq-4*(m-1)^2*wm*wp+12*n^2*wm^2+3*n^2-3*(m-1)^2;
4*(2*m^2*wm*wp*ws+m^2*ws+m^2*wp-2*n^2*wm^3-3*n^2*wm+m^2*wm);
(-4*(m+1)^2*wp*ws)-4*(m+1)*wp*ws-4*(m+1)^2*wm*ws+4*(m+1)*wm*wq-4*(m+1)^2*wm*wp+12*n^2*wm^2+3*n^2-3*(m+1)^2;
2*((m+2)^2*ws+(m+2)*ws-(m+2)*wq+(m+2)^2*wp+(m+2)*wp-3*n^2*wm+(m+2)^2*wm-(m+2)*wm);
(n-m-3)*(n+m+3);
0;
EOF
if [ $? -ne 0 ]; then echo "Failed output cat of test.ok"; fail; fi

#
# run and see if the results match
#
echo "Running maxima -b " $prog
maxima -b $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok ${prog//max/out}
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.ok"; fail; fi

#
# this much worked
#
pass

