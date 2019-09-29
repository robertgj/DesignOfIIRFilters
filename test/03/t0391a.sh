#!/bin/sh

prog=johanssonOneMlatticeEsq_test.m

depends="johanssonOneMlatticeEsq_test.m test_common.m \
johanssonOneMlatticeEsq.m johanssonOneMlatticeAzp.m \
tf2schurOneMlattice.m schurOneMscale.m schurOneMAPlatticeP.m \
schurOneMAPlattice2Abcd.m H2P.m \
schurOneMlattice2Abcd.oct schurdecomp.oct schurOneMAPlattice2H.oct \
schurexpand.oct qzsolve.oct complex_zhong_inverse.oct"

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
# the output should look like this
#
cat > test.ok << 'EOF'
nchk=[1, napl-1,napl,napl+1,nasl-1,nasl,nasl+1, ...
       nasu-1,nasu,nasu+1,napu-1,napu,napu+1,nf+1];
nchk=[ 1 150 151 152 200 201 202  ... 
         250 251 252 300 301 302 501 ];
wa(nchk)=[ 0 0.149 0.15 0.151 0.199 0.2 0.201  ... 
             0.249 0.25 0.251 0.299 0.3 0.301 0.5 ]*2*pi;
Ad(nchk)=[ 1 1 1 0 0 0 0  ... 
             0 0 0 0 1 1 1 ];
Wa(nchk)=[ 1 1 1 0 0 1 1  ... 
             1 1 0 0 1 1 1 ];
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave-cli -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

