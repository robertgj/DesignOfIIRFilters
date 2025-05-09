#!/bin/sh

prog=schurOneMlatticePipelined_slb_exchange_constraints_test.m
depends="test/schurOneMlatticePipelined_slb_exchange_constraints_test.m test_common.m \
schurOneMlatticePipelined_slb_exchange_constraints.m \
schurOneMlatticePipelined_slb_update_constraints.m \
schurOneMlatticePipelinedAsq.m \
schurOneMlatticePipelinedT.m \
schurOneMlatticePipelinedP.m \
schurOneMlatticePipelinedEsq.m \
schurOneMlatticePipelineddAsqdw.m \
schurOneMlatticePipelined2Abcd.m schurOneMscale.m \
schurOneMlatticePipelined_slb_set_empty_constraints.m \
schurOneMlatticePipelined_slb_show_constraints.m \
schurOneMlatticePipelined_slb_constraints_are_empty.m \
tf2schurOneMlattice.m \
tf2schurOneMlatticePipelined.m \
local_max.m x2tf.m print_polynomial.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
schurdecomp.oct schurexpand.oct Abcd2H.oct Abcd2tf.oct"

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
tpr = 5.0000e-03
Wtp = 0.1000
fpp = 0.2500
ppr = 0.050000
Wpp = 0.1000
dpr = 0.1000
Wdp = 0.010000
vR2 before exchange constraints:
al=[ 301 ]
f(al)=[ 0.150000 ](fs=1)
Asql=[ -0.205474 ](dB)
au=[ 1 158 280 601 746 1000 ]
f(au)=[ 0.000000 0.078500 0.139500 0.300000 0.372500 0.499500 ](fs=1)
Asqu=[ 0.006737 0.033485 0.091361 -36.422596 -43.060968 -41.720245 ](dB)
tu=[ 311 ]
f(tu)=[ 0.155000 ](fs=1)
Tu=[ 16.779261 ](Samples)
pl=[ 501 ]
f(pl)=[ 0.250000 ](fs=1)
Pl=[ -5.847682 ](rad./pi)
dl=[ 201 ]
f(dl)=[ 0.100000 ](fs=1)
Dl=[ -0.146248 ]
du=[ 123 ]
f(du)=[ 0.061000 ](fs=1)
Du=[ 0.071346 ]
vS7 before exchange constraints:
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
dl=[ 201 ]
f(dl)=[ 0.100000 ](fs=1)
Dl=[ -0.051732 ]
du=[ 132 ]
f(du)=[ 0.065500 ](fs=1)
Du=[ 0.117797 ]
Exchanged constraint from vR.al(301) to vS
vR7 after exchange constraints:
au=[ 1 158 280 601 746 1000 ]
f(au)=[ 0.000000 0.078500 0.139500 0.300000 0.372500 0.499500 ](fs=1)
Asqu=[ -0.184653 -0.026100 -0.457340 -39.996706 -58.593204 -74.559669 ](dB)
tu=[ 311 ]
f(tu)=[ 0.155000 ](fs=1)
Tu=[ 6.003168 ](Samples)
pl=[ 501 ]
f(pl)=[ 0.250000 ](fs=1)
Pl=[ -2.999890 ](rad./pi)
dl=[ 201 ]
f(dl)=[ 0.100000 ](fs=1)
Dl=[ -0.051732 ]
du=[ 123 ]
f(du)=[ 0.061000 ](fs=1)
Du=[ 0.116289 ]
vS7 after exchange constraints:
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

