#!/bin/sh

prog=schurOneMPAlattice_slb_exchange_constraints_test.m
depends="schurOneMPAlattice_slb_exchange_constraints_test.m test_common.m \
schurOneMPAlattice_slb_exchange_constraints.m \
schurOneMPAlattice_slb_update_constraints.m \
schurOneMPAlatticeAsq.m schurOneMPAlatticeT.m schurOneMPAlatticeP.m \
schurOneMPAlatticeEsq.m \
schurOneMPAlattice_slb_set_empty_constraints.m \
schurOneMPAlattice_slb_show_constraints.m \
schurOneMPAlattice_slb_constraints_are_empty.m \
schurOneMscale.m tf2schurOneMlattice.m schurOneMAPlattice2Abcd.m \
local_max.m print_polynomial.m H2Asq.m H2T.m H2P.m \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct"

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
maxiter =  2000
tol =    5.0000e-06
verbose = 1
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
Pl=[ -1.012924 -11.200626 -12.645780 ](Samples)
pu=[ 84 ]
f(pu)=[ 0.041500 ](fs=1)
Pu=[ -2.997700 ](Samples)
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
Pl=[ -0.941382 -4.626417 -8.166838 -11.345803 ](Samples)
pu=[ 78 179 273 346 ]
f(pu)=[ 0.038500 0.089000 0.136000 0.172500 ](fs=1)
Pu=[ -2.779811 -6.428826 -9.825041 -12.463280 ](Samples)
Exchanged constraint from vR.al(301) to vS
vR1 after exchange constraints:
al=[ 148 ]
f(al)=[ 0.073500 ](fs=1)
Asql=[ -0.946105 ](dB)
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
Pl=[ -1.013617 -11.201199 -12.644210 ](Samples)
pu=[ 84 ]
f(pu)=[ 0.041500 ](fs=1)
Pu=[ -2.996719 ](Samples)
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
Pl=[ -0.941382 -4.626417 -8.166838 -11.345803 ](Samples)
pu=[ 78 179 273 346 ]
f(pu)=[ 0.038500 0.089000 0.136000 0.172500 ](fs=1)
Pu=[ -2.779811 -6.428826 -9.825041 -12.463280 ](Samples)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match. Suppress m-file warnings
#
echo "Running octave-cli -q " $prog
echo "warning('off');" >> .octaverc

octave-cli -q $prog >test.out 
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.out test.ok
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

