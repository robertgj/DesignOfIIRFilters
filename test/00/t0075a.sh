#!/bin/sh

prog=iir_frm_slb_update_constraints_test.m 

depends="iir_frm_slb_update_constraints_test.m test_common.m \
iir_frm_slb_update_constraints.m iir_frm_slb_show_constraints.m \
iir_frm_struct_to_vec.m iir_frm_vec_to_struct.m \
iir_frm.m iirA.m iirP.m iirT.m  iirdelAdelw.m \
fixResultNaN.m xConstraints.m local_max.m tf2x.m zp2x.m x2tf.m \
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
cat > test.ok << 'EOF'
verbose = 1
tol =  0.000010000
tol =  0.0000010000
constraints_tol =  0.00000010000
maxiter =  5000
verbose = 1
Mmodel =  9
Dmodel =  7
dmask =  20
fap =  0.30000
dBap =  0.10000
Wap =  1
tpr =  1
Wtp =  0.050000
fas =  0.31000
dBas =  40
Was =  50
vS =
  scalar structure containing the fields:
    al =
       156
       201
       218
       241
    au =
         1
        23
        41
        66
        81
       108
       123
       149
       163
       171
       186
       195
       208
       234
       249
       251
       258
       268
       282
       290
       297
       309
       315
       331
       339
       349
       353
       359
       371
       375
       381
       392
       399
    tl =
       173
       184
       195
       206
       218
       229
       240
    tu =
       168
       179
       190
       200
       212
       223
       234

al=[ 156 201 218 241 ]
au=[ 1 23 41 66 81 108 123 149 163 171 186 195 208 234 249 251 258 268 282 290 297 309 315 331 339 349 353 359 371 375 381 392 399 ]
tl=[ 173 184 195 206 218 229 240 ]
tu=[ 168 179 190 200 212 223 234 ]
Current constraints:
al=[ 156 201 218 241 ]
f(al)=[ 0.193750 0.250000 0.271250 0.300000 ](fs=1)
Asql=[ -0.113036 -0.117298 -0.123432 -0.913177 ](dB)
au=[ 1 23 41 66 81 108 123 149 163 171 186 195 208 234 249 251 258 268 282 290 297 309 315 331 339 349 353 359 371 375 381 392 399 ]
f(au)=[ 0.000000 0.027500 0.050000 0.081250 0.100000 0.133750 0.152500 0.185000 0.202500 0.212500 0.231250 0.242500 0.258750 0.291250 0.310000 0.312500 0.321250 0.333750 0.351250 0.361250 0.370000 0.385000 0.392500 0.412500 0.422500 0.435000 0.440000 0.447500 0.462500 0.467500 0.475000 0.488750 0.497500 ](fs=1)
Asqu=[ 0.023313 0.068088 0.056911 0.063322 0.022362 0.057309 0.052935 0.060551 0.072267 0.000651 0.010674 0.079371 0.103211 0.198610 -30.606949 -36.884567 -38.312065 -37.949801 -38.155167 -38.566248 -37.925647 -38.598944 -39.432589 -38.557600 -38.127080 -37.190023 -38.346668 -39.587391 -39.635062 -39.232311 -38.079998 -37.852882 -38.610141 ](dB)
tl=[ 173 184 195 206 218 229 240 ]
f(tl)=[ 0.215000 0.228750 0.242500 0.256250 0.271250 0.285000 0.298750 ](fs=1)
Tl=[ -0.925120 -1.081451 -0.543874 -0.903471 -1.444718 -1.726174 -1.408118 ](Samples)
tu=[ 168 179 190 200 212 223 234 ]
f(tu)=[ 0.208750 0.222500 0.236250 0.248750 0.263750 0.277500 0.291250 ](fs=1)
Tu=[ 0.762132 0.763501 0.932677 0.885758 0.982456 1.277266 1.328132 ](Samples)
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running octave-cli -q " $prog

octave-cli -q $prog > test.out
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi


#
# this much worked
#
pass

