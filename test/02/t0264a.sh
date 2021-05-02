#!/bin/sh

prog=schurOneMAPlattice_frm_hilbert_slb_exchange_constraints_test.m

depends="schurOneMAPlattice_frm_hilbert_slb_exchange_constraints_test.m \
test_common.m schurOneMAPlattice_frm_hilbert_slb_exchange_constraints.m \
schurOneMAPlattice_frm_hilbert_slb_set_empty_constraints.m \
schurOneMAPlattice_frm_hilbert_slb_show_constraints.m \
schurOneMAPlattice_frm_hilbert_slb_update_constraints.m \
schurOneMAPlattice_frm_hilbertEsq.m schurOneMAPlattice_frm_hilbertT.m \
schurOneMAPlattice_frm_hilbertAsq.m schurOneMAPlattice_frm_hilbertP.m \
schurOneMAPlatticeP.m schurOneMAPlatticeT.m tf2schurOneMlattice.m \
schurOneMAPlattice2Abcd.m Abcd2tf.m tf2pa.m schurOneMscale.m H2Asq.m H2P.m \
H2T.m local_max.m schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct \
spectralfactor.oct schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct \
qroots.m qzsolve.oct"

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
cat > test.out << 'EOF'
maxiter =  2000
tol =  0.0000050000
verbose = 1
fap =  0.020000
fas =  0.48000
dBap =  0.050000
Wap =  1
ftp =  0.050000
fts =  0.45000
tp =  79
tpr =  0.40000
Wtp =  0.20000
fpp =  0.050000
fps =  0.45000
pp = -1.5708
ppr =  0.0062832
Wpp =  0.20000
vR0 before exchange constraints:
al=[ 28 82 138 241 293 445 497 600 656 710 ]
f(al)=[ 0.036875 0.070625 0.105625 0.170000 0.202500 0.297500 0.330000 0.394375 0.429375 0.463125 ](fs=1)
Asql=[ -0.064865 -0.062496 -0.060287 -0.059367 -0.056984 -0.056984 -0.059367 -0.060287 -0.062496 -0.064865 ](dB)
au=[ 1 63 97 203 318 369 420 535 641 675 737 ]
f(au)=[ 0.020000 0.058750 0.080000 0.146250 0.218125 0.250000 0.281875 0.353750 0.420000 0.441250 0.480000 ](fs=1)
Asqu=[ 0.053725 0.066413 0.060440 0.046300 0.058067 0.055809 0.058067 0.046300 0.060440 0.066413 0.053725 ](dB)
tl=[ 34 608 ]
f(tl)=[ 0.070625 0.429375 ](fs=1)
Tl=[ -0.477117 -0.477117 ](Samples)
tu=[ 23 45 597 619 ]
f(tu)=[ 0.063750 0.077500 0.422500 0.436250 ](fs=1)
Tu=[ 0.226908 0.205907 0.205907 0.226908 ](Samples)
pl=[ 28 381 493 601 ]
f(pl)=[ 0.066875 0.287500 0.357500 0.425000 ](fs=1)
Pl=[ -0.502202 -0.501781 -0.502185 -0.502157 ](rad./pi)
pu=[ 41 149 261 614 ]
f(pu)=[ 0.075000 0.142500 0.212500 0.433125 ](fs=1)
Pu=[ -0.497843 -0.497815 -0.498219 -0.497798 ](rad/pi)
vS1 before exchange constraints:
al=[ 2 39 112 242 369 496 626 699 736 ]
f(al)=[ 0.020625 0.043750 0.089375 0.170625 0.250000 0.329375 0.410625 0.456250 0.479375 ](fs=1)
Asql=[ -0.119693 -0.292031 -0.086228 -0.055323 -0.084320 -0.055323 -0.086228 -0.292031 -0.119693 ](dB)
au=[ 22 74 141 201 266 345 393 472 537 597 664 716 ]
f(au)=[ 0.033125 0.065625 0.107500 0.145000 0.185625 0.235000 0.265000 0.314375 0.355000 0.392500 0.434375 0.466875 ](fs=1)
Asqu=[ 0.334304 0.140680 0.058873 0.029665 0.065516 0.026281 0.026281 0.065516 0.029665 0.058873 0.140680 0.334304 ](dB)
tl=[ 1 65 113 198 321 444 529 577 641 ]
f(tl)=[ 0.050000 0.090000 0.120000 0.173125 0.250000 0.326875 0.380000 0.410000 0.450000 ](fs=1)
Tl=[ -0.481252 -0.479096 -0.299448 -0.293005 -0.574868 -0.293005 -0.299448 -0.479096 -0.481252 ](Samples)
tu=[ 23 158 215 427 484 619 ]
f(tu)=[ 0.063750 0.148125 0.183750 0.316250 0.351875 0.436250 ](fs=1)
Tu=[ 0.604240 0.356614 0.308777 0.308777 0.356614 0.604240 ](Samples)
pl=[ 45 182 237 308 508 635 ]
f(pl)=[ 0.077500 0.163125 0.197500 0.241875 0.366875 0.446250 ](fs=1)
Pl=[ -0.515195 -0.505470 -0.506776 -0.504784 -0.508149 -0.503446 ](rad./pi)
pu=[ 7 134 334 405 460 597 ]
f(pu)=[ 0.053750 0.133125 0.258125 0.302500 0.336875 0.422500 ](fs=1)
Pu=[ -0.496554 -0.491851 -0.495216 -0.493224 -0.494530 -0.484805 ](rad/pi)
Exchanged constraint from vR.tu(23) to vS
exchanged=1
vR2 after exchange constraints:
al=[ 28 82 138 241 293 445 497 600 656 710 ]
f(al)=[ 0.036875 0.070625 0.105625 0.170000 0.202500 0.297500 0.330000 0.394375 0.429375 0.463125 ](fs=1)
Asql=[ 0.144556 0.109820 0.052350 -0.055200 -0.012856 -0.012856 -0.055200 0.052350 0.109820 0.144556 ](dB)
au=[ 1 63 97 203 318 369 420 535 641 675 737 ]
f(au)=[ 0.020000 0.058750 0.080000 0.146250 0.218125 0.250000 0.281875 0.353750 0.420000 0.441250 0.480000 ](fs=1)
Asqu=[ -0.119620 0.080209 -0.022363 0.029156 -0.030243 -0.084320 -0.030243 0.029156 -0.022363 0.080209 -0.119620 ](dB)
tl=[ 34 608 ]
f(tl)=[ 0.070625 0.429375 ](fs=1)
Tl=[ 0.416985 0.416985 ](Samples)
tu=[ 45 597 619 ]
f(tu)=[ 0.077500 0.422500 0.436250 ](fs=1)
Tu=[ -0.003883 -0.003883 0.604240 ](Samples)
pl=[ 28 381 493 601 ]
f(pl)=[ 0.066875 0.287500 0.357500 0.425000 ](fs=1)
Pl=[ -0.508525 -0.497091 -0.505049 -0.485184 ](rad./pi)
pu=[ 41 149 261 614 ]
f(pu)=[ 0.075000 0.142500 0.212500 0.433125 ](fs=1)
Pu=[ -0.514816 -0.494951 -0.502909 -0.491475 ](rad/pi)
vS1 after exchange constraints:
al=[ 2 39 112 242 369 496 626 699 736 ]
f(al)=[ 0.020625 0.043750 0.089375 0.170625 0.250000 0.329375 0.410625 0.456250 0.479375 ](fs=1)
Asql=[ -0.119693 -0.292031 -0.086228 -0.055323 -0.084320 -0.055323 -0.086228 -0.292031 -0.119693 ](dB)
au=[ 22 74 141 201 266 345 393 472 537 597 664 716 ]
f(au)=[ 0.033125 0.065625 0.107500 0.145000 0.185625 0.235000 0.265000 0.314375 0.355000 0.392500 0.434375 0.466875 ](fs=1)
Asqu=[ 0.334304 0.140680 0.058873 0.029665 0.065516 0.026281 0.026281 0.065516 0.029665 0.058873 0.140680 0.334304 ](dB)
tl=[ 1 65 113 198 321 444 529 577 641 ]
f(tl)=[ 0.050000 0.090000 0.120000 0.173125 0.250000 0.326875 0.380000 0.410000 0.450000 ](fs=1)
Tl=[ -0.481252 -0.479096 -0.299448 -0.293005 -0.574868 -0.293005 -0.299448 -0.479096 -0.481252 ](Samples)
tu=[ 23 158 215 427 484 619 ]
f(tu)=[ 0.063750 0.148125 0.183750 0.316250 0.351875 0.436250 ](fs=1)
Tu=[ 0.604240 0.356614 0.308777 0.308777 0.356614 0.604240 ](Samples)
pl=[ 45 182 237 308 508 635 ]
f(pl)=[ 0.077500 0.163125 0.197500 0.241875 0.366875 0.446250 ](fs=1)
Pl=[ -0.515195 -0.505470 -0.506776 -0.504784 -0.508149 -0.503446 ](rad./pi)
pu=[ 7 134 334 405 460 597 ]
f(pu)=[ 0.053750 0.133125 0.258125 0.302500 0.336875 0.422500 ](fs=1)
Pu=[ -0.496554 -0.491851 -0.495216 -0.493224 -0.494530 -0.484805 ](rad/pi)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.out"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.out \
     schurOneMAPlattice_frm_hilbert_slb_exchange_constraints_test.diary
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.out"; fail; fi

#
# this much worked
#
pass

