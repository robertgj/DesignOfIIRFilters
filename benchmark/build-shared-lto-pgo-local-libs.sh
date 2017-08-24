#!/bin/sh

# Assume these files are present:
#  lapack-3.6.1.tgz
#  lapack-3.6.1.patch
#  lapack-3.7.1.tgz
#  lapack-3.7.1.patch
#  SuiteSparse-4.5.5.tar.gz
#  arpack-ng-master.zip
#  fftw-3.3.6-pl2.tar.gz
#  qhull-2015-src-7.2.0.tgz
#  qrupdate-1.1.2.tar.gz
#  qrupdate-1.1.2.Makeconf
#  glpk-4.63.tar.gz
#  hdf5-1.10.1.tar.gz
#  octave-4.2.1.tar.lz
#  octave-4.2.1.patch

OCTAVE_DIR=/usr/local/octave
OCTAVE_INCLUDE_DIR=$OCTAVE_DIR/include
OCTAVE_LIB_DIR=$OCTAVE_DIR/lib
export LD_LIBRARY_PATH=$OCTAVE_LIB_DIR
export LDFLAGS=-L$OCTAVE_LIB_DIR
OCTAVE_BIN_DIR=$OCTAVE_DIR/bin
export PATH=$PATH:$OCTAVE_BIN_DIR

#
# !?!WARNING!?!
#
# Starting from scratch!
#
rm -Rf $OCTAVE_DIR

#
# Build lapack
#
cat > lapack-3.6.1.patch.uue << 'EOF'
begin 644 lapack-3.6.1.patch
M+2TM(&QA<&%C:RTS+C8N,2]34D,O36%K969I;&4),C`Q-BTP-BTQ.2`P.#HQ
M-3HQ,2XP,#`P,#`P,#`@*S$P,#`**RLK(&QA<&%C:RTS+C8N,2YM;V0O4U)#
M+TUA:V5F:6QE"3(P,3<M,#<M,C<@,C`Z-34Z,3<N-#DY-C$Q-3<Q("LQ,#`P
M"D!`("TT-3@L-B`K-#4X+#D@0$`*(`DD*$%20T@I("0H05)#2$9,04=3*2`D
M0"`D*$%,3$]"2BD@)"A!3$Q83T)**2`D*$1%4%)%0T%4140I"B`))"A204Y,
M24(I("1`"B`**VQI8FQA<&%C:RYS;SH@)"A!3$Q/0DHI("0H04Q,6$]"2BD@
M)"A$15!214-!5$5$*0HK"0DD*$9/4E1204XI("US:&%R960@+5=L+"US;VYA
M;64L)$`@+6\@)$`@)"A!3$Q/0DHI("0H04Q,6$]"2BD@)"A$15!214-!5$5$
M*0HK"B!S:6YG;&4Z("0H4TQ!4U)#*2`D*$133$%34D,I("0H4UA,05-20RD@
M)"A30TQ!55@I("0H04Q,0558*0H@"20H05)#2"D@)"A!4D-(1DQ!1U,I("XN
M+R0H3$%004-+3$E"*2`D*%-,05-20RD@)"A$4TQ!4U)#*2!<"B`))"A36$Q!
M4U)#*2`D*%-#3$%56"D@)"A!3$Q!55@I("0H04Q,6$%56"D*+2TM(&QA<&%C
M:RTS+C8N,2]"3$%3+U-20R]-86ME9FEL90DR,#$V+3`V+3$Y(#`X.C$U.C$Q
M+C`P,#`P,#`P,"`K,3`P,`HK*RL@;&%P86-K+3,N-BXQ+FUO9"]"3$%3+U-2
M0R]-86ME9FEL90DR,#$W+3`W+3(W(#(P.C4T.C0R+C4P,3DX,#0V,R`K,3`P
M,`I`0"`M,30Q+#8@*S$T,2PY($!`"B`))"A!4D-(*2`D*$%20TA&3$%'4RD@
M)$`@)"A!3$Q/0DHI"B`))"A204Y,24(I("1`"B`**VQI8F)L87,N<V\Z("0H
M04Q,3T)**0HK"20H1D]25%)!3BD@+7-H87)E9"`M5VPL+7-O;F%M92PD0"`M
M;R`D0"`D*$%,3$]"2BD**PH@<VEN9VQE.B`D*%-"3$%3,2D@)"A!3$Q"3$%3
M*2`D*%-"3$%3,BD@)"A30DQ!4S,I"B`))"A!4D-(*2`D*$%20TA&3$%'4RD@
M)"A"3$%33$E"*2`D*%-"3$%3,2D@)"A!3$Q"3$%3*2!<"B`))"A30DQ!4S(I
M("0H4T),05,S*0HM+2T@;&%P86-K+3,N-BXQ+VUA:V4N:6YC+F5X86UP;&4)
M,C`Q-BTP-BTQ.2`P.#HQ-3HQ,2XP,#`P,#`P,#`@*S$P,#`**RLK(&QA<&%C
M:RTS+C8N,2YM;V0O;6%K92YI;F,N97AA;7!L90DR,#$W+3`W+3(W(#(P.C4Y
M.C`T+CDS,C(Q-#,R,"`K,3`P,`I`0"`M,38L,3<@*S$V+#$X($!`"B`C("!A
M;F0@:&%N9&QE('1H97-E('%U86YT:71I97,@87!P<F]P<FEA=&5L>2X@07,@
M82!C;VYS97%U96YC92P@;VYE(`H@(R`@<VAO=6QD(&YO="!C;VUP:6QE($Q!
M4$%#2R!W:71H(&9L86=S('-U8V@@87,@+69F<&4M=')A<#UO=F5R9FQO=RX*
M(",*+49/4E1204X@(#T@9V9O<G1R86X@"BU/4%13("`@("`]("U/,B`M9G)E
M8W5R<VEV90HK0DQ$3U!44R`]("UM-C0@+69024,**T]05%,@("`@(#T@+4\R
M"B!$4E9/4%13("`]("0H3U!44RD*+4Y/3U!4("`@(#T@+4\P("UF<F5C=7)S
M:79E"BU,3T%$15(@("`](&=F;W)T<F%N"BM.3T]05"`@("`]("U/,`HK1D]2
M5%)!3B`@/2!G9F]R=')A;B`M9G)E8W5R<VEV92`D*$),1$]05%,I"BM,3T%$
M15(@("`]("0H1D]25%)!3BD*($Q/041/4%13(#T*(",*(",@($-O;6UE;G0@
M;W5T('1H92!F;VQL;W=I;F<@;&EN92!T;R!I;F-L=61E(&1E<')E8V%T960@
M<F]U=&EN97,@=&\@=&AE"B`C("!,05!!0TL@;&EB<F%R>2X*(",*+2--04M%
M1$504D5#051%1"`](%EE<PHK34%+141%4%)%0T%4140@/2!997,*(",*(",@
M5&EM97(@9F]R('1H92!314-/3D0@86YD($1314-.1"!R;W5T:6YE<PH@(PI`
M0"`M-3(L-R`K-3,L-R!`0`H@(R!#0R!I<R!T:&4@0R!C;VUP:6QE<BP@;F]R
M;6%L;'D@:6YV;VME9"!W:71H(&]P=&EO;G,@0T9,04=3+@H@(PH@0T,@/2!G
M8V,*+4-&3$%'4R`]("U/,PHK0T9,04=3(#T@)"A/4%13*2`D*$),1$]05%,I
M"B`C"B`C("!4:&4@87)C:&EV97(@86YD('1H92!F;&%G*',I('1O('5S92!W
M:&5N(&)U:6QD:6YG(&%R8VAI=F4@*&QI8G)A<GDI"B`C("!)9B!Y;W4@<WES
M=&5M(&AA<R!N;R!R86YL:6(L('-E="!204Y,24(@/2!E8VAO+@I`0"`M-S0L
M-R`K-S4L-R!`0`H@(R`@;6%C:&EN92US<&5C:69I8RP@;W!T:6UI>F5D($),
M05,@;&EB<F%R>2!S:&]U;&0@8F4@=7-E9"!W:&5N979E<@H@(R`@<&]S<VEB
M;&4N*0H@(PHM0DQ!4TQ)0B`@("`@(#T@+BXO+BXO;&EB<F5F8FQA<RYA"BM"
M3$%33$E"("`@("`@/2`N+B\N+B]L:6)B;&%S+F$*($-"3$%33$E"("`@("`]
M("XN+RXN+VQI8F-B;&%S+F$*($Q!4$%#2TQ)0B`@("`](&QI8FQA<&%C:RYA
="B!434=,24(@("`@("`@/2!L:6)T;6=L:6(N80H`
`
end
EOF
cat > lapack-3.7.1.patch.uue << 'EOF'
begin 644 lapack-3.7.1.patch
M+2TM(&QA<&%C:RTS+C<N,2]M86ME+FEN8RYE>&%M<&QE"3(P,3<M,#8M,3@@
M,#@Z-#8Z-3,N,#`P,#`P,#`P("LQ,#`P"BLK*R!L87!A8VLM,RXW+C$N;6]D
M+VUA:V4N:6YC+F5X86UP;&4),C`Q-RTP-RTR-R`Q,3HR-SHQ,BXQ-#,P-S`U
M-C(@*S$P,#`*0$`@+3DL-R`K.2PX($!`"B`C("!#0R!I<R!T:&4@0R!C;VUP
M:6QE<BP@;F]R;6%L;'D@:6YV;VME9"!W:71H(&]P=&EO;G,@0T9,04=3+@H@
M(PH@0T,@("`@(#T@9V-C"BU#1DQ!1U,@/2`M3S,**T),1$]05%,@/2`M;38T
M("UF4$E#"BM#1DQ!1U,@/2`M3S(@)"A"3$1/4%13*0H@"B`C("!-;V1I9GD@
M=&AE($9/4E1204X@86YD($]05%,@9&5F:6YI=&EO;G,@=&\@<F5F97(@=&\@
M=&AE(&-O;7!I;&5R"B`C("!A;F0@9&5S:7)E9"!C;VUP:6QE<B!O<'1I;VYS
M(&9O<B!Y;W5R(&UA8VAI;F4N("!.3T]05"!R969E<G,@=&\*0$`@+3$Y+#$U
M("LR,"PQ-2!`0`H@(R`@86YD(&AA;F1L92!T:&5S92!Q=6%N=&ET:65S(&%P
M<')O<')I871E;'DN($%S(&$@8V]N<V5Q=65N8V4L(&]N90H@(R`@<VAO=6QD
M(&YO="!C;VUP:6QE($Q!4$%#2R!W:71H(&9L86=S('-U8V@@87,@+69F<&4M
M=')A<#UO=F5R9FQO=RX*(",*+49/4E1204X@/2!G9F]R=')A;@HM3U!44R`@
M("`]("U/,B`M9G)E8W5R<VEV90HK1D]25%)!3B`](&=F;W)T<F%N("UF<F5C
M=7)S:79E("0H0DQ$3U!44RD**T]05%,@("`@/2`M3S(*($125D]05%,@/2`D
M*$]05%,I"BU.3T]05"`@(#T@+4\P("UF<F5C=7)S:79E"BM.3T]05"`@(#T@
M+4\P"B`*(",@($1E9FEN92!,3T%$15(@86YD($Q/041/4%13('1O(')E9F5R
M('1O('1H92!L;V%D97(@86YD(&1E<VER960*(",@(&QO860@;W!T:6]N<R!F
M;W(@>6]U<B!M86-H:6YE+@H@(PHM3$]!1$52("`@/2!G9F]R=')A;@HK3$]!
M1$52("`@/2`D*$9/4E1204XI"B!,3T%$3U!44R`]"B`*(",@(%1H92!A<F-H
M:79E<B!A;F0@=&AE(&9L86<H<RD@=&\@=7-E('=H96X@8G5I;&1I;F<@86X@
M87)C:&EV90I`0"`M-3DL-R`K-C`L-R!`0`H@(R`@56YC;VUM96YT('1H92!F
M;VQL;W=I;F<@;&EN92!T;R!I;F-L=61E(&1E<')E8V%T960@<F]U=&EN97,@
M:6X*(",@('1H92!,05!!0TL@;&EB<F%R>2X*(",*+2-"54E,1%]$15!214-!
M5$5$(#T@665S"BM"54E,1%]$15!214-!5$5$(#T@665S"B`*(",@($Q!4$%#
M2T4@:&%S('1H92!I;G1E<F9A8V4@=&\@<V]M92!R;W5T:6YE<R!F<F]M('1M
M9VQI8BX*(",@($EF($Q!4$%#2T5?5TE42%]434<@:7,@9&5F:6YE9"P@861D
M('1H;W-E(')O=71I;F5S('1O($Q!4$%#2T4N"BTM+2!L87!A8VLM,RXW+C$O
M4U)#+TUA:V5F:6QE"3(P,3<M,#8M,3@@,#@Z-#8Z-3,N,#`P,#`P,#`P("LQ
M,#`P"BLK*R!L87!A8VLM,RXW+C$N;6]D+U-20R]-86ME9FEL90DR,#$W+3`W
M+3(W(#$Q.C(X.C(W+C@X,3$Y,C@T,2`K,3`P,`I`0"`M-3$Q+#8@*S4Q,2PY
M($!`"B`))"A!4D-(*2`D*$%20TA&3$%'4RD@)$`@)%X*(`DD*%)!3DQ)0BD@
M)$`*(`HK;&EB;&%P86-K+G-O.B`D*$%,3$]"2BD@)"A!3$Q83T)**2`D*$1%
M4%)%0T%4140I"BL))"A&3U)44D%.*2`M<VAA<F5D("U7;"PM<V]N86UE+"1`
M("UO("1`("0H04Q,3T)**2`D*$%,3%A/0DHI("0H1$504D5#051%1"D**PH@
M<VEN9VQE.B`D*%-,05-20RD@)"A$4TQ!4U)#*2`D*%-83$%34D,I("0H4T-,
M0558*2`D*$%,3$%56"D*(`DD*$%20T@I("0H05)#2$9,04=3*2`N+B\D*$Q!
M4$%#2TQ)0BD@)%X*(`DD*%)!3DQ)0BD@+BXO)"A,05!!0TM,24(I"BTM+2!L
M87!A8VLM,RXW+C$O0DQ!4R]34D,O36%K969I;&4),C`Q-RTP-BTQ."`P.#HT
M-CHU,RXP,#`P,#`P,#`@*S$P,#`**RLK(&QA<&%C:RTS+C<N,2YM;V0O0DQ!
M4R]34D,O36%K969I;&4),C`Q-RTP-RTR-R`Q,3HR.#HQ,2XX,S<S-S@W-S`@
M*S$P,#`*0$`@+3$T,2PV("LQ-#$L.2!`0`H@"20H05)#2"D@)"A!4D-(1DQ!
M1U,I("1`("1>"B`))"A204Y,24(I("1`"B`**VQI8F)L87,N<V\Z("0H04Q,
M3T)**0HK"20H1D]25%)!3BD@+7-H87)E9"`M5VPL+7-O;F%M92PD0"`M;R`D
M0"`D*$%,3$]"2BD**PH@<VEN9VQE.B`D*%-"3$%3,2D@)"A!3$Q"3$%3*2`D
M*%-"3$%3,BD@)"A30DQ!4S,I"B`))"A!4D-(*2`D*$%20TA&3$%'4RD@)"A"
B3$%33$E"*2`D7@H@"20H4D%.3$E"*2`D*$),05-,24(I"@``
`
end
EOF
uudecode lapack-3.7.1.patch.uue
rm -Rf lapack-3.7.1
tar -xf lapack-3.7.1.tgz
cd lapack-3.7.1
patch -p1 < ../lapack-3.7.1.patch
cp make.inc.example make.inc
cd BLAS/SRC
make -j 6 libblas.so
mkdir -p $OCTAVE_LIB_DIR
cp libblas.so $OCTAVE_LIB_DIR
cd ../../SRC
make -j 6 liblapack.so
cp liblapack.so $OCTAVE_LIB_DIR
cd ../..

#
# Build arpack-ng
#
rm -Rf arpack-ng-master
unzip arpack-ng-master.zip
cd arpack-ng-master
sh ./bootstrap
./configure --prefix=$OCTAVE_DIR --with-blas=-lblas --with-lapack=-llapack
make -j 6 && make install
cd ..

#
# Build SuiteSparse
#
rm -Rf SuiteSparse
tar -xf SuiteSparse-4.5.5.tar.gz
cd SuiteSparse
make INSTALL=/usr/local/octave OPTIMIZATION=-O2 BLAS=-lblas install
cd ..

#
# Build qrupdate
#
rm -Rf qrupdate-1.1.2
tar -xf qrupdate-1.1.2.tar.gz
cd qrupdate-1.1.2
rm -f Makeconf
cat > Makeconf << 'EOF'
FC=gfortran
FFLAGS=-fimplicit-none -O2 -funroll-loops 
FPICFLAGS=-fPIC

ifeq ($(strip $(PREFIX)),)
  PREFIX=/usr/local
endif

BLAS=-L$(PREFIX)/lib -lblas
LAPACK=-L$(PREFIX)/lib -llapack

VERSION=1.1
MAJOR=1
LIBDIR=lib
DESTDIR=
EOF
make PREFIX=$OCTAVE_DIR solib install
cd ..

#
# Build qhull
#
rm -Rf qhull-2015.2
tar -xf qhull-2015-src-7.2.0.tgz 
cd qhull-2015.2
make DESTDIR=$OCTAVE_DIR new install
cd ..

#
# Build glpk
#
rm -Rf glpk-4.63
tar -xf glpk-4.63.tar.gz
cd glpk-4.63
./configure --prefix=$OCTAVE_DIR
make -j 6 && make install
cd ..

#
# Build fftw
#
rm -Rf fftw-3.3.6-pl2
tar -xf fftw-3.3.6-pl2.tar.gz
cd fftw-3.3.6-pl2
./configure --prefix=$OCTAVE_DIR --enable-shared \
            --with-combined-threads --enable-threads
make -j 6 && make install
cd ..

#
# Build fftw single-precision
#
rm -Rf fftw-3.3.6-pl2
tar -xf fftw-3.3.6-pl2.tar.gz
cd fftw-3.3.6-pl2
./configure --prefix=$OCTAVE_DIR --enable-shared \
            --with-combined-threads --enable-threads --enable-single
make -j 6 && make install
cd ..

#
# Build hdf5
#
rm -Rf hdf5-1.10.1
tar -xf hdf5-1.10.1.tar.gz
cd hdf5-1.10.1
./configure --prefix=$OCTAVE_DIR
make -j 6 && make install
cd ..

#
# Build octave
#

# Unpack octave
cat > octave-4.2.1.patch.uue << 'EOF'
begin 444 octave-4.2.1.patch
M+2TM(&]C=&%V92TT+C(N,2YO<FEG+VQI8F]C=&%V92]S>7-T96TO9FEL92US
M=&%T+F-C"3(P,3<M,#(M,C,@,#4Z,#$Z-34N,#`P,#`P,#`P("LQ,3`P"BLK
M*R!O8W1A=F4M-"XR+C$O;&EB;V-T879E+W-Y<W1E;2]F:6QE+7-T870N8V,)
M,C`Q-RTP-BTR.2`Q-#HU,CHT,RXX-S0Y-C,V-S4@*S$P,#`*0$`@+3$W-"PW
M("LQ-S0L-R!`0`H@("`@("`@("`@('5P9&%T95]I;G1E<FYA;"`H*3L*("`@
M("`@('T*(`HM("`@(&EN;&EN92!F:6QE7W-T870Z.GYF:6QE7W-T870@*"D@
M>R!]"BL@("`@9FEL95]S=&%T.CI^9FEL95]S=&%T("@I('L@?0H@"B`@("`@
M=F]I9`H@("`@(&9I;&5?<W1A=#HZ=7!D871E7VEN=&5R;F%L("AB;V]L(&9O
%<F-E*0H`
`
end
EOF
uudecode octave-4.2.1.patch.uue
rm -Rf octave-4.2.1
tar -xf octave-4.2.1.tar.lz
cd octave-4.2.1
patch -p 1 < ../octave-4.2.1.patch
rm -Rf build
mkdir build
cd build
OPTFLAGS="-m64 -mtune=generic -O2"
export CFLAGS=$OPTFLAGS
export CXXFLAGS=$OPTFLAGS" -std=c++11"
export FFLAGS=$OPTFLAGS
../configure --prefix=$OCTAVE_DIR \
             --disable-java \
             --disable-atomic-refcount \
             --without-fltk \
             --without-qt \
             --without-sndfile \
             --without-portaudio \
             --with-blas=-lblas \
             --with-lapack=-llapack \
             --with-arpack-includedir=$OCTAVE_INCLUDE_DIR \
             --with-arpack-libdir=$OCTAVE_LIB_DIR \
             --with-qrupdate-includedir=$OCTAVE_INCLUDE_DIR \
             --with-qrupdate-libdir=$OCTAVE_LIB_DIR \
             --with-amd-includedir=$OCTAVE_INCLUDE_DIR \
             --with-amd-libdir=$OCTAVE_LIB_DIR \
             --with-camd-includedir=$OCTAVE_INCLUDE_DIR \
             --with-camd-libdir=$OCTAVE_LIB_DIR \
             --with-colamd-includedir=$OCTAVE_INCLUDE_DIR \
             --with-colamd-libdir=$OCTAVE_LIB_DIR \
             --with-ccolamd-includedir=$OCTAVE_INCLUDE_DIR \
             --with-ccolamd-libdir=$OCTAVE_LIB_DIR \
             --with-cholmod-includedir=$OCTAVE_INCLUDE_DIR \
             --with-cholmod-libdir=$OCTAVE_LIB_DIR \
             --with-cxsparse-includedir=$OCTAVE_INCLUDE_DIR \
             --with-cxsparse-libdir=$OCTAVE_LIB_DIR \
             --with-umfpack-includedir=$OCTAVE_INCLUDE_DIR \
             --with-umfpack-libdir=$OCTAVE_LIB_DIR \
             --with-fftw3-includedir=$OCTAVE_INCLUDE_DIR \
             --with-fftw3-libdir=$OCTAVE_LIB_DIR \
             --with-fftw3f-includedir=$OCTAVE_INCLUDE_DIR \
             --with-fftw3f-libdir=$OCTAVE_LIB_DIR \
             --with-hdf5-includedir=$OCTAVE_INCLUDE_DIR \
             --with-hdf5-libdir=$OCTAVE_LIB_DIR \
             --with-glpk-includedir=$OCTAVE_INCLUDE_DIR \
             --with-glpk-libdir=$OCTAVE_LIB_DIR \
             --with-qhull-includedir=$OCTAVE_INCLUDE_DIR \
             --with-qhull-libdir=$OCTAVE_LIB_DIR \
             --with-qhull=$OCTAVE_LIB_DIR/libqhullstatic.a

#
# Generate profile
#
export PGO_GEN_FLAGS="-fprofile-generate"
export PGO_LTO_FLAGS="-fprofile-use -flto=6 -ffat-lto-objects"
make XTRA_CFLAGS=$PGO_GEN_FLAGS XTRA_CXXFLAGS=$PGO_GEN_FLAGS V=1 -j6
find . -name \*.gcda -exec rm -f {} ';'
make check

#
# Use profile
#
find . -name \*.o -exec rm -f {} ';'
find . -name \*.lo -exec rm -f {} ';'
find . -name \*.la -exec rm -f {} ';'
make XTRA_CFLAGS="$PGO_LTO_FLAGS" XTRA_CXXFLAGS="$PGO_LTO_FLAGS" V=1 -j6
make install
cd ../..

#
# Install packages
#
$OCTAVE_BIN_DIR/octave-cli \
    --eval 'pkg install -forge struct optim control signal parallel'
