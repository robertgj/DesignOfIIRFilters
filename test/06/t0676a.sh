#!/bin/sh

prog=schurOneMlatticePipelined_slb_update_constraints_test.m
depends="test/schurOneMlatticePipelined_slb_update_constraints_test.m \
test_common.m \
schurOneMlatticePipelined_slb_update_constraints.m \
schurOneMlatticePipelinedAsq.m \
schurOneMlatticePipelinedT.m \
schurOneMlatticePipelinedP.m \
schurOneMlatticePipelineddAsqdw.m \
schurOneMlatticePipelined2Abcd.m \
schurOneMlatticePipelined_slb_set_empty_constraints.m \
schurOneMlatticePipelined_slb_show_constraints.m \
schurOneMlatticePipelined_slb_constraints_are_empty.m \
tf2schurOneMlattice.m tf2schurOneMlatticePipelined.m \
schurOneMscale.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
local_max.m x2tf.m print_polynomial.m \
Abcd2tf.oct schurdecomp.oct schurexpand.oct Abcd2H.oct Abcd2tf.oct"

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
maxiter = 2000
tol = 5.0000e-06
verbose = 1
fap = 0.1500
dBap = 0.1000
Wap = 1
fas = 0.3000
dBas = 50
Was = 10
ftp = 0.2500
tp = 6
tpr = 0.010000
Wtp = 0.1000
fpp = 0.2500
ppr = 2.0000e-04
Wpp = 0.1000
dpr = 0.080000
Wdp = 0.010000
al=[ 1 301 ]
au=[ 191 601 655 ]
tl=[ 1 246 443 ]
tu=[ 126 355 498 ]
pl=[ 187 402 ]
pu=[ 64 302 477 ]
dl=[ 201 ]
du=[ 132 ]
al=[ 1 301 ]
f(al)=[ 0.000000 0.150000 ](fs=1)
Asql=[ -0.184653 -0.786008 ](dB)
au=[ 191 601 655 ]
f(au)=[ 0.095000 0.300000 0.327000 ](fs=1)
Asqu=[ 0.000041 -39.996706 -45.040025 ](dB)
tl=[ 1 246 443 ]
f(tl)=[ 0.000000 0.122500 0.221000 ](fs=1)
Tl=[ 5.987503 5.987303 5.987335 ](Samples)
tu=[ 126 355 498 ]
f(tu)=[ 0.062500 0.177000 0.248500 ](fs=1)
Tu=[ 6.012534 6.012795 6.008982 ](Samples)
pl=[ 187 402 ]
f(pl)=[ 0.093000 0.200500 ](fs=1)
Pl=[ -1.116479 -2.406357 ](rad./pi)
pu=[ 64 302 477 ]
f(pu)=[ 0.031500 0.150500 0.238000 ](fs=1)
Pu=[ -0.377497 -1.805546 -2.855748 ](rad./pi)
dl=[ 201 ]
f(dl)=[ 0.100000 ](fs=1)
Dl=[ -0.051732 ]
du=[ 132 ]
f(du)=[ 0.065500 ](fs=1)
Du=[ 0.117797 ]
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. 
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.out test.ok
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

