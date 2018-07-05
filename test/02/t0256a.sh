#!/bin/sh

prog=schurOneMAPlattice_frm_halfband_slb_exchange_constraints_test.m

depends="schurOneMAPlattice_frm_halfband_slb_exchange_constraints_test.m \
test_common.m schurOneMAPlattice_frm_halfband_slb_exchange_constraints.m \
schurOneMAPlattice_frm_halfband_slb_set_empty_constraints.m \
schurOneMAPlattice_frm_halfband_slb_show_constraints.m \
schurOneMAPlattice_frm_halfband_slb_update_constraints.m \
schurOneMAPlattice_frm_halfbandEsq.m schurOneMAPlattice_frm_halfbandT.m \
schurOneMAPlattice_frm_halfbandAsq.m schurOneMAPlatticeP.m \
schurOneMAPlatticeT.m tf2schurOneMlattice.m schurOneMAPlattice2Abcd.m \
Abcd2tf.m tf2pa.m schurOneMscale.m H2Asq.m H2P.m H2T.m \
schurOneMlattice2Abcd.oct schurOneMAPlattice2H.oct spectralfactor.oct \
schurdecomp.oct schurexpand.oct complex_zhong_inverse.oct local_max.m \
qroots.m qzsolve.oct"

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
cat > test.out << 'EOF'
maxiter =  2000
tol =  0.0000050000
verbose = 1
tp =  79
fap =  0.24000
dBap =  0.050000
Wap =  1
ftp =  0.24000
tpr =  0.40000
Wtp =  0.20000
fas =  0.26000
dBas =  45
Was =  100
vR0 before exchange constraints:
au=[ 1 52 167 273 307 371 417 ]
f(au)=[ 0.000000 0.031875 0.103750 0.170000 0.191250 0.231250 0.260000 ](fs=1)
Asqu=[ 0.027949 0.029081 0.023168 0.030270 0.033270 0.028311 -40.369678 ](dB)
tl=[ 288 377 ]
f(tl)=[ 0.179375 0.235000 ](fs=1)
Tl=[ -0.237705 -0.336324 ](Samples)
tu=[ 367 385 ]
f(tu)=[ 0.228750 0.240000 ](fs=1)
Tu=[ 0.255257 1.806723 ](Samples)
vS1 before exchange constraints:
al=[ 1 141 181 274 385 ]
f(al)=[ 0.000000 0.087500 0.112500 0.170625 0.240000 ](fs=1)
Asql=[ -0.083072 -0.082740 -0.050987 -0.051429 -0.104315 ](dB)
au=[ 51 99 169 225 303 370 417 499 625 661 800 ]
f(au)=[ 0.031250 0.061250 0.105000 0.140000 0.188750 0.230625 0.260000 0.311250 0.390000 0.412500 0.499375 ](fs=1)
Asqu=[ 0.038241 0.005328 0.004015 0.019830 0.076819 0.035117 -38.455094 -41.028480 -44.043604 -40.463283 -40.438750 ](dB)
tl=[ 380 ]
f(tl)=[ 0.236875 ](fs=1)
Tl=[ -0.229090 ](Samples)
tu=[ 385 ]
f(tu)=[ 0.240000 ](fs=1)
Tu=[ 0.506281 ](Samples)
Exchanged constraint from vR.tu(385) to vS
exchanged=1
vR2 after exchange constraints:
au=[ 1 52 167 273 307 371 417 ]
f(au)=[ 0.000000 0.031875 0.103750 0.170000 0.191250 0.231250 0.260000 ](fs=1)
Asqu=[ -0.083072 0.038196 0.000786 -0.051426 0.073021 0.034340 -38.455094 ](dB)
tl=[ 288 377 ]
f(tl)=[ 0.179375 0.235000 ](fs=1)
Tl=[ -0.047699 -0.135269 ](Samples)
tu=[ 367 ]
f(tu)=[ 0.228750 ](fs=1)
Tu=[ 0.105826 ](Samples)
vS1 after exchange constraints:
al=[ 1 141 181 274 385 ]
f(al)=[ 0.000000 0.087500 0.112500 0.170625 0.240000 ](fs=1)
Asql=[ -0.083072 -0.082740 -0.050987 -0.051429 -0.104315 ](dB)
au=[ 51 99 169 225 303 370 417 499 625 661 800 ]
f(au)=[ 0.031250 0.061250 0.105000 0.140000 0.188750 0.230625 0.260000 0.311250 0.390000 0.412500 0.499375 ](fs=1)
Asqu=[ 0.038241 0.005328 0.004015 0.019830 0.076819 0.035117 -38.455094 -41.028480 -44.043604 -40.463283 -40.438750 ](dB)
tl=[ 380 ]
f(tl)=[ 0.236875 ](fs=1)
Tl=[ -0.229090 ](Samples)
tu=[ 385 ]
f(tu)=[ 0.240000 ](fs=1)
Tu=[ 0.506281 ](Samples)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat test.out"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.out \
     schurOneMAPlattice_frm_halfband_slb_exchange_constraints_test.diary
if [ $? -ne 0 ]; then echo "Failed diff -Bb test.out"; fail; fi

#
# this much worked
#
pass

