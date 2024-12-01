#!/bin/sh

prog=schurOneMPAlattice_slb_exchange_constraints_test.m
depends="test/schurOneMPAlattice_slb_exchange_constraints_test.m test_common.m \
schurOneMPAlattice_slb_exchange_constraints.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMPAlatticeAsq.m schurOneMPAlatticeT.m schurOneMPAlatticeP.m \
schurOneMPAlatticedAsqdw.m schurOneMPAlatticeEsq.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMscale.m tf2schurOneMlattice.m schurOneMAPlattice2Abcd.m \
local_max.m print_polynomial.m H2Asq.m H2T.m H2P.m H2dAsqdw.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct"

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
fdp = 0.1500
vR0 before exchange constraints:
al=[ 148 301 ]
f(al)=[ 0.073500 0.150000 ](fs=1)
Asql=[ -0.510871 -3.042037 ](dB)
au=[ 1 225 401 439 ]
f(au)=[ 0.000000 0.112000 0.200000 0.219000 ](fs=1)
Asqu=[ 0.000000 -0.000006 -30.392258 -39.549602 ](dB)
tl=[ 55 ]
f(tl)=[ 0.027000 ](fs=1)
Tl=[ 11.479110 ](Samples)
tu=[ 1 351 ]
f(tu)=[ 0.000000 0.175000 ](fs=1)
Tu=[ 11.523894 11.532802 ](Samples)
pl=[ 29 311 351 ]
f(pl)=[ 0.014000 0.155000 0.175000 ](fs=1)
Pl=[ -0.322424 -3.565270 -4.025277 ](rad./pi)
pu=[ 84 ]
f(pu)=[ 0.041500 ](fs=1)
Pu=[ -0.954198 ](rad./pi)
dl=[ 107 297 ]
f(dl)=[ 0.053000 0.148000 ](fs=1)
Dl=[ -0.520083 -3.526330 ]
du=[ 192 ]
f(du)=[ 0.095500 ](fs=1)
Du=[ 0.723269 ]
vS1 before exchange constraints:
al=[ 153 301 ]
f(al)=[ 0.076000 0.150000 ](fs=1)
Asql=[ -0.954397 -3.000000 ](dB)
au=[ 1 234 401 424 482 566 624 723 847 ]
f(au)=[ 0.000000 0.116500 0.200000 0.211500 0.240500 0.282500 0.311500 0.361000 0.423000 ](fs=1)
Asqu=[ -0.000000 -0.000027 -39.999943 -39.887187 -39.999947 -39.936088 -39.836621 -39.905580 -40.712387 ](dB)
tl=[ 52 154 250 333 ]
f(tl)=[ 0.025500 0.076500 0.124500 0.166000 ](fs=1)
Tl=[ 11.460000 11.460000 11.460000 11.460000 ](Samples)
tu=[ 1 103 203 295 351 ]
f(tu)=[ 0.000000 0.051000 0.101000 0.147000 0.175000 ](fs=1)
Tu=[ 11.540000 11.540000 11.540000 11.540000 11.540000 ](Samples)
pl=[ 27 129 227 315 ]
f(pl)=[ 0.013000 0.064000 0.113000 0.157000 ](fs=1)
Pl=[ -0.299651 -1.472634 -2.599585 -3.611481 ](rad./pi)
pu=[ 78 179 273 346 ]
f(pu)=[ 0.038500 0.089000 0.136000 0.172500 ](fs=1)
Pu=[ -0.884841 -2.046359 -3.127408 -3.967185 ](rad./pi)
dl=[ 110 298 ]
f(dl)=[ 0.054500 0.148500 ](fs=1)
Dl=[ -0.945374 -3.891545 ]
du=[ 198 ]
f(du)=[ 0.098500 ](fs=1)
Du=[ 1.221333 ]
Exchanged constraint from vR.dl(297) to vS
vR1 after exchange constraints:
al=[ 148 301 ]
f(al)=[ 0.073500 0.150000 ](fs=1)
Asql=[ -0.946105 -3.000000 ](dB)
au=[ 1 225 401 439 ]
f(au)=[ 0.000000 0.112000 0.200000 0.219000 ](fs=1)
Asqu=[ -0.000000 -0.031842 -39.999943 -45.402173 ](dB)
tl=[ 55 ]
f(tl)=[ 0.027000 ](fs=1)
Tl=[ 11.460529 ](Samples)
tu=[ 1 351 ]
f(tu)=[ 0.000000 0.175000 ](fs=1)
Tu=[ 11.540000 11.540000 ](Samples)
pl=[ 29 311 351 ]
f(pl)=[ 0.014000 0.155000 0.175000 ](fs=1)
Pl=[ -0.322644 -3.565452 -4.024777 ](rad./pi)
pu=[ 84 ]
f(pu)=[ 0.041500 ](fs=1)
Pu=[ -0.953885 ](rad./pi)
dl=[ 107 ]
f(dl)=[ 0.053000 ](fs=1)
Dl=[ -0.939049 ]
du=[ 192 ]
f(du)=[ 0.095500 ](fs=1)
Du=[ 1.190089 ]
vS1 after exchange constraints:
al=[ 153 301 ]
f(al)=[ 0.076000 0.150000 ](fs=1)
Asql=[ -0.954397 -3.000000 ](dB)
au=[ 1 234 401 424 482 566 624 723 847 ]
f(au)=[ 0.000000 0.116500 0.200000 0.211500 0.240500 0.282500 0.311500 0.361000 0.423000 ](fs=1)
Asqu=[ -0.000000 -0.000027 -39.999943 -39.887187 -39.999947 -39.936088 -39.836621 -39.905580 -40.712387 ](dB)
tl=[ 52 154 250 333 ]
f(tl)=[ 0.025500 0.076500 0.124500 0.166000 ](fs=1)
Tl=[ 11.460000 11.460000 11.460000 11.460000 ](Samples)
tu=[ 1 103 203 295 351 ]
f(tu)=[ 0.000000 0.051000 0.101000 0.147000 0.175000 ](fs=1)
Tu=[ 11.540000 11.540000 11.540000 11.540000 11.540000 ](Samples)
pl=[ 27 129 227 315 ]
f(pl)=[ 0.013000 0.064000 0.113000 0.157000 ](fs=1)
Pl=[ -0.299651 -1.472634 -2.599585 -3.611481 ](rad./pi)
pu=[ 78 179 273 346 ]
f(pu)=[ 0.038500 0.089000 0.136000 0.172500 ](fs=1)
Pu=[ -0.884841 -2.046359 -3.127408 -3.967185 ](rad./pi)
dl=[ 110 297 298 ]
f(dl)=[ 0.054500 0.148000 0.148500 ](fs=1)
Dl=[ -0.945374 -3.889782 -3.891545 ]
du=[ 198 ]
f(du)=[ 0.098500 ](fs=1)
Du=[ 1.221333 ]
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

