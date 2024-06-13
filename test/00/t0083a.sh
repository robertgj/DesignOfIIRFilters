#!/bin/sh

prog=parallel_allpass_slb_update_constraints_test.m 

depends="test/parallel_allpass_slb_update_constraints_test.m test_common.m \
parallel_allpass_slb_update_constraints.m \
parallel_allpass_slb_show_constraints.m \
parallel_allpassAsq.m parallel_allpassT.m parallel_allpassP.m \
allpassP.m allpassT.m local_max.m tf2a.m a2tf.m qroots.m qzsolve.oct"

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
maxiter = 2000
polyphase = 0
difference = 1
K = 2
Ra = 1
Rb = 1
fasl = 0.050000
fapl = 0.1000
fapu = 0.2000
fasu = 0.2500
dBap = 0.1000
dBas = 40
Wap = 1
Watl = 1.0000e-03
Watu = 1.0000e-03
Wasl = 1000
Wasu = 1000
ftpl = 0.1200
ftpu = 0.1800
td = 16
tdr = 0.040000
Wtp = 10
fppl = 0.1150
fppu = 0.1850
pd = 1.5000
pdr = 2.0000e-04
Wpp = 2000
vS.al=[ 225 301 381 ]
vS.au=[ 35 101 206 256 348 398 544 ]
vS.tl=[ 1 35 96 121 ]
vS.tu=[ 13 65 ]
vS.pl=[ 1 32 93 ]
vS.pu=[ 58 141 ]
al=[ 225 301 381 ]
f(al)=[ 0.112000 0.150000 0.190000 ](fs=1)
Asql=[ -0.169575 -0.107265 -0.204076 ](dB)
au=[ 35 101 206 256 348 398 544 ]
f(au)=[ 0.017000 0.050000 0.102500 0.127500 0.173500 0.198500 0.271500 ](fs=1)
Asqu=[ -33.738054 -34.874613 -0.000177 -0.000008 -0.000004 -0.000446 -35.087919 ](dB)
tl=[ 1 35 96 121 ]
f(tl)=[ 0.120000 0.137000 0.167500 0.180000 ](fs=1)
Tl=[ 15.951239 15.955897 15.963670 15.964071 ](Samples)
tu=[ 13 65 ]
f(tu)=[ 0.126000 0.152000 ](fs=1)
Tu=[ 16.025280 16.059551 ](Samples)
pl=[ 1 32 93 ]
f(pl)=[ 0.115000 0.130500 0.161000 ](fs=1)
Pl=[ -2.180882 -2.676167 -3.652707 ](rad./pi)
pu=[ 58 141 ]
f(pu)=[ 0.143500 0.185000 ](fs=1)
Pu=[ -3.091418 -4.419282 ](rad./pi)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"

octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

