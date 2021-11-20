#!/bin/sh

prog="dgesvd_test"
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

# If /usr/lib64/atlas does not exist then return the aet code for "pass"
if ! test -d /usr/lib64/atlas ; then 
    echo SKIPPED $prog /usr/lib64/atlas not found! ; exit 0; 
fi
# If /usr/lib64/liblapack.so.3 does not exist then return the aet code for "pass"
if ! test -f /usr/lib64/liblapack.so.3 ; then 
    echo SKIPPED $prog /usr/lib64/liblapack.so.3 not found! ; exit 0; 
fi
# If /usr/lib64/libblas.so.3 does not exist then return the aet code for "pass"
if ! test -f /usr/lib64/libblas.so.3 ; then 
    echo SKIPPED $prog /usr/lib64/libblas.so.3 not found! ; exit 0; 
fi

mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
cd $tmp
if [ $? -ne 0 ]; then echo "Failed cd"; fail; fi

#
# Test files
#
cat > B1.BIN.UUE << 'EOF'
begin 664 B1.BIN
M*AP%^EO#>C^GZ0ZYR$0Y/_EA%@/.H54_ZUND&\J?8;^@U"R!IMV!OSNF&S3\
MV7^_DWH+69<ZB;\I1PHT7@>2OQ]`F&LV"Y._]8>S:6N)G;_B%O7-?66./^[(
MQ<RA09(_L>D.N<A$.3\"UME.H-%V/UG3WTOI:VT__%)96`Y:;;^YA?*XZCZ,
MOV52UD<EN'"_\VCWD7I)@K^6UD9?-WZ-O]3_H92#?I._H*;4%)@9E;\?]UC0
ML#:'/X+;_9-.-I$_^F$6`\ZA53]<T]]+Z6MM/W,P\1A0FIT_[BQRZ;H-BK^M
M-Q$ES'VAOX7(N^N._HJ_HM,`LZT$EK^OB^>PUK:CO_^<K%<F-JF_&!RX)6`A
ME;]L.B1N]9F>/[M@;-%5P*<_ZUND&\J?8;\!4UE8#EIMO_$L<NFZ#8J_0O::
M64Z[IS_E3*'`)TZGO]='L8I:HYF_2$"Z,KW#G;]C!?9X&:2AO\CYH#<!5*&_
M1(J&<A]<H#^(;O*6!AZA/S@/\K?RG:$_H-0L@:;=@;^\A?*XZCZ,OZLW$27,
M?:&_Y4RAP"=.I[_UW=NG_(S0/W[+SN,J]K*_#@O($33RK;_&O_*NG>FLOX+W
M.#^-(;&_/$YNJH5DQC_S/8+P.?BJ/]AXO5825K`_>Z8;-/S9?[]U4M9');AP
MOYW(N^N._HJ_X4>QBEJCF;^-R\[C*O:ROX)FA\(]"2!`9UM)@Y.N`T"<S;YX
MESSUOWJ$0_!D)`'`]$&V^T-L%\`PW[B$NQ[)/^&@G"PA0_X_FGH+69<ZB;_Q
M:/>1>DF"OZW3`+.M!):_3D"Z,KW#G;\:"\@1-/*MOV1;28.3K@-`ZP<]/*K(
M#$!TNLXV`J'M/](3\23?>?2_N+2'Y<3"!\#`%H'^86H%P)[O^E%+6^,_+D<*
M-%X'DK^6UD9?-WZ-OZV+Y[#6MJ._9`7V>!FDH;_/O_*NG>FLOYW-OGB7//6_
M>+K.-@*A[3]:.+7G`>D40+5*W'@'4!!`3G!U$_Z/\#\H]U:N`)D-P-A`\9>%
ML1/`)D"8:S8+D[_2_Z&4@WZ3O_^<K%<F-JF_R_F@-P%4H;]_]S@_C2&QOWJ$
M0_!D)`'`TQ/Q)-]Y]+^V2MQX!U`00$^/H=@);"5`WS[PW31N`4#-^Z^SE(_?
MOU`-S/)"\R'`^X>S:6N)G;^?IM04F!F5OQL<N"5@(96_2HJ&<A]<H#]`3FZJ
MA63&/_-!MOM#;!?`M;2'Y<3"!\!9<'43_H_P/]T^\-TT;@%`$*Z?"-88%D"<
MRRJ/)4'=/Z%B=;$FKOV_XQ;US7UECC\B]UC0L#:'/VXZ)&[UF9X_AV[RE@8>
MH3\"/H+P.?BJ/T#?N(2['LD_P!:!_F%J!<`N]U:N`)D-P,?[K[.4C]^_Q,LJ
MCR5!W3\DLA[+/^X10/8BG]\B2/H_[,C%S*%!DC]_V_V33C:1/[Q@;-%5P*<_
M-P_RM_*=H3_:>+U6$E:P/]R@G"PA0_X_F._Z44M;XS_70/&7A;$3P%`-S/)"
;\R'`FF)UL2:N_;_N(I_?(DCZ/UJ)'RN&=B!`
`
end
EOF
if [ $? -ne 0 ]; then echo "Failed output cat B1.BIN.UUE"; fail; fi
uudecode B1.BIN.UUE
if [ $? -ne 0 ]; then echo "Failed uudecode B1.BIN.UUE"; fail; fi

cat > dgesvd_test.f << 'EOF'
*     COMPILE WITH:
*       gfortran -o dgesvd_test src/dgesvd_test.f -L/usr/lib64/atlas -ltatlas
*
*     RUN WITH:
*       for l in `seq 1 100`;do
*         LD_PRELOAD="/usr/lib64/atlas/libtatlas.so" \
*         ./dgesvd_test ;
*       done
*
*     OR:
*       for l in `seq 1 100`;do
*         LD_PRELOAD="/usr/lib64/libblas.so:/usr/lib64/liblapack.so" \
*         ./dgesvd_test ;
*       done

      INTEGER          N, SIZEOFDOUBLE, LWORK
      PARAMETER        ( N=12, SIZEOFDOUBLE=8, LWORK=1000 )
      INTEGER          INFO
      DOUBLE PRECISION A( N, N ), U( N, N ), VT( N, N ), S( N ),
     $                 WORK( LWORK )
      EXTERNAL         DGESVD

      OPEN(UNIT=10,FILE="B1.BIN",FORM="UNFORMATTED",STATUS="OLD",
     $ ACCESS="DIRECT", RECL=N*N*SIZEOFDOUBLE )
      READ (10,REC=1) A

      CALL DGESVD( 'A', 'A', N, N, A, N, S, U, N, VT, N,
     $             WORK, LWORK, INFO )

      IF( INFO.GT.0 ) THEN
         WRITE(*,*)'SVD did not converge'
         STOP
      END IF
      
      WRITE(*,9999) ( U( N, N ) )
 9999 FORMAT( F20.17 )

      STOP
      END
EOF
if [ $? -ne 0 ]; then echo "Failed output cat dgesvd_test.f"; fail; fi

#
# Previously, with atlas-3.10.2-16.fc26, lapack-3.6.1-4.fc26 and
# gfortran from gcc-7.1.1-3.fc26, the libtatlas output varied randomly
# as either 0.14709002182060249 or 0.14709002182060266.
# This appears to be fixed with the current atlas-3.10.3-10.fc32,
# lapack-3.9.0-3.fc32 and gfortran from gcc-10.2.1-1.fc32.
#

#
# the ATLAS output should look like this
#
cat > test.atlas.ok << 'EOF'
 0.14709002182061778
EOF

gfortran -Wall -o dgesvd_test_atlas dgesvd_test.f /usr/lib64/atlas/libtatlas.so.3
if [ $? -ne 0 ]; then \
    echo "Failed to compile dgesvd_test.f with libtatlas"; fail; fi

echo "ldd dgesvd_test_atlas" > test.atlas.ldd
ldd dgesvd_test_atlas >> test.atlas.ldd

for k in `seq 1 100`;do \
              ./dgesvd_test_atlas >test.atlas.out.$k ; \
    if [ $? -ne 0 ]; then echo "Failed running with libtatlas "$k; fail; fi ; \

    diff -Bb test.atlas.ok test.atlas.out.$k ; \
    if [ $? -ne 0 ]; then echo "Failed diff -Bb test.atlas.ok "$k ; fail ; fi ; \
done


#
# the system BLAS output should look like this
#
cat > test.sysblas.ok << 'EOF'
 0.14709002182060862
EOF

gfortran -Wall -o dgesvd_test_sysblas dgesvd_test.f \
         /usr/lib64/libblas.so.3 /usr/lib64/liblapack.so.3
if [ $? -ne 0 ]; then \
    echo "Failed to compile dgesvd_test.f with system libblas"; fail; fi

echo "ldd dgesvd_test_sysblas" > test.sysblas.ldd 
ldd dgesvd_test_sysblas >> test.sysblas.ldd

for k in `seq 1 100`;do \
    ./dgesvd_test_sysblas 2&>/dev/null >test.sysblas.out.$k;\
    if [ $? -ne 0 ]; then echo "Failed running with system libblas "$k;fail;fi;\

    diff -Bb test.sysblas.ok test.sysblas.out.$k ; \
    if [ $? -ne 0 ]; then echo "Failed diff -Bb test.sysblas.ok "$k;fail;fi;\
done

#
# the octave-6.3.0 BLAS output should look like this
#
cat > test.blas.ok << 'EOF'
 0.14709002182060862
EOF

gfortran -Wall -o dgesvd_test_blas dgesvd_test.f \
         -L/usr/local/octave-6.4.0/lib -lblas -llapack
if [ $? -ne 0 ]; then \
    echo "Failed to compile dgesvd_test.f with libblas"; fail; fi

echo "LD_LIBRARY_PATH=/usr/local/octave-6.4.0/lib ldd dgesvd_test_blas" \
     > test.blas.ldd
LD_LIBRARY_PATH=/usr/local/octave-6.4.0/lib ldd dgesvd_test_blas >> test.blas.ldd

for k in `seq 1 100`;do \
    LD_LIBRARY_PATH=/usr/local/octave-6.4.0/lib \
                   ./dgesvd_test_blas >test.blas.out.$k ; \
    if [ $? -ne 0 ]; then echo "Failed running with libblas "$k; fail; fi ; \

    diff -Bb test.blas.ok test.blas.out.$k ; \
    if [ $? -ne 0 ]; then echo "Failed diff -Bb test.blas.ok "$k ; fail ; fi ; \
done

#
# this much worked
#
pass
