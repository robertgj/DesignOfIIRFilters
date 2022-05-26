#!/bin/sh

prog=schurOneMAPlattice_frm_slb_update_constraints_test.m
depends="test/schurOneMAPlattice_frm_slb_update_constraints_test.m test_common.m \
schurOneMAPlattice_frm_slb_update_constraints.m \
schurOneMAPlattice_frm_slb_set_empty_constraints.m \
schurOneMAPlattice_frm_slb_show_constraints.m \
schurOneMAPlattice_frm_slb_constraints_are_empty.m \
schurOneMAPlattice_frm.m schurOneMAPlattice_frmAsq.m \
schurOneMAPlattice_frmT.m schurOneMAPlattice_frmP.m \
schurOneMAPlatticeT.m schurOneMAPlatticeP.m \
schurOneMAPlattice2Abcd.m schurOneMscale.m \
tf2schurOneMlattice.m schurOneMlattice2tf.m local_max.m x2tf.m \
print_polynomial.m Abcd2tf.m H2Asq.m H2T.m H2P.m \
schurOneMlattice2Abcd.oct schurdecomp.oct schurexpand.oct \
complex_zhong_inverse.oct schurOneMlattice2H.oct schurOneMAPlattice2H.oct"

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
verbose = 1
tol = 1.0000e-05
tol = 1.0000e-06
ctol = 1.0000e-07
fap = 0.2900
dBap = 0.1000
Wap = 1
Wat = 1
fas = 0.3125
dBas = 40
Was = 50
tpr = 5
Wtp = 0.050000
pp = 0
ppr = 0.062832
Wpp = 0.010000
al=[ 1 66 112 158 200 288 334 379 406 483 558 ]
au=[ 40 83 142 170 240 305 363 387 444 506 528 584 626 643 678 713 730 749 773 806 827 842 880 925 953 975 ]
tl=[ 67 157 290 377 516 ]
tu=[ 56 168 279 389 503 ]
pl=[ 62 285 510 ]
pu=[ 162 382 530 ]
al=[ 1 66 112 158 200 288 334 379 406 483 558 ]
f(al)=[ 0.000000 0.032500 0.055500 0.078500 0.099500 0.143500 0.166500 0.189000 0.202500 0.241000 0.278500 ](fs=1)
Asql=[ -0.166280 -0.606261 -0.388711 -0.406520 -0.121561 -0.356517 -0.371403 -0.201613 -0.277367 -0.463821 -0.394249 ](dB)
au=[ 40 83 142 170 240 305 363 387 444 506 528 584 626 643 678 713 730 749 773 806 827 842 880 925 953 975 ]
f(au)=[ 0.019500 0.041000 0.070500 0.084500 0.119500 0.152000 0.181000 0.193000 0.221500 0.252500 0.263500 0.291500 0.312500 0.321000 0.338500 0.356000 0.364500 0.374000 0.386000 0.402500 0.413000 0.420500 0.439500 0.462000 0.476000 0.487000 ](fs=1)
Asqu=[ 0.152741 0.526248 0.519840 0.053731 0.101852 0.517064 0.522140 0.057651 0.307664 0.292382 0.444994 0.158109 -28.506518 -30.140903 -33.231373 -35.067013 -33.369592 -34.172380 -33.943573 -33.542392 -32.201396 -39.581249 -38.236436 -37.974030 -37.647920 -36.487270 ](dB)
tl=[ 67 157 290 377 516 ]
f(tl)=[ 0.033000 0.078000 0.144500 0.188000 0.257500 ](fs=1)
Tl=[ -4.466519 -4.089191 -3.480709 -3.843033 -4.355179 ](Samples)
tu=[ 56 168 279 389 503 ]
f(tu)=[ 0.027500 0.083500 0.139000 0.194000 0.251000 ](fs=1)
Tu=[ 3.049963 3.188152 3.136445 3.515658 3.484134 ](Samples)
pl=[ 62 285 510 ]
f(pl)=[ 0.030500 0.142000 0.254500 ](fs=1)
Pl=[ -0.073692 -0.083094 -0.112762 ](Samples)
pu=[ 162 382 530 ]
f(pu)=[ 0.080500 0.190500 0.264500 ](fs=1)
Pu=[ 0.082734 0.102211 0.039522 ](Samples)
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

