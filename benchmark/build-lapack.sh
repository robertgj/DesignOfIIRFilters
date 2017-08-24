#!/bin/bash

# A script to build shared and static versions of the Lapack libraries:
#  1. Assumes the NETLIB source archive lapack-$LPVER.tgz is present
#  2. Under directory lapack-$LPVER, make.inc.example, SRC/Makefile and
#     BLAS/SRC/Makefile are modified with lapack-$LPVER.patch

alias cp=cp

MAKE_OPTS=""
ALL_BUILDS="generic intel haswell nehalem skylake"

# Patch lapack files make.inc.example, SRC/Makefile and BLAS/SRC/Makefile
cat > lapack-$LPVER.patch.uue << 'EOF'
begin 664 lapack-3.6.1.patch
M+2TM(&QA<&%C:RTS+C8N,2]M86ME+FEN8RYE>&%M<&QE"3(P,38M,#8M,3D@
M,#@Z,34Z,3$N,#`P,#`P,#`P("LQ,#`P"BLK*R!L87!A8VLM,RXV+C$N;F5W
M+VUA:V4N:6YC+F5X86UP;&4),C`Q-RTP-2TP-"`Q-3HP,3HT-"XS,38Y-3$R
M,38@*S$P,#`*0$`@+3$V+#$W("LQ-BPQ.2!`0`H@(R`@86YD(&AA;F1L92!T
M:&5S92!Q=6%N=&ET:65S(&%P<')O<')I871E;'DN($%S(&$@8V]N<V5Q=65N
M8V4L(&]N92`*(",@('-H;W5L9"!N;W0@8V]M<&EL92!,05!!0TL@=VET:"!F
M;&%G<R!S=6-H(&%S("UF9G!E+71R87`];W9E<F9L;W<N"B`C"BU&3U)44D%.
M("`](&=F;W)T<F%N(`HM3U!44R`@("`@/2`M3S(@+69R96-U<G-I=F4**T),
M1$]05%,@(#T@+6TV-"`M;71U;F4]:6YT96P@+69024,@+69L=&\]-B`M9F9A
M="UL=&\M;V)J96-T<PHK1D]25%)!3B`@/2!G9F]R=')A;B`M9G)E8W5R<VEV
M92`D*$),1$]05%,I"BM/4%13("`@("`]("U/,B`*($125D]05%,@(#T@)"A/
M4%13*0HM3D]/4%0@("`@/2`M3S`@+69R96-U<G-I=F4*+4Q/041%4B`@(#T@
M9V9O<G1R86X**TY/3U!4("`@(#T@+4\P"BM,3T%$15(@("`]("0H1D]25%)!
M3BD*($Q/041/4%13(#T*(",*(",@($-O;6UE;G0@;W5T('1H92!F;VQL;W=I
M;F<@;&EN92!T;R!I;F-L=61E(&1E<')E8V%T960@<F]U=&EN97,@=&\@=&AE
M"B`C("!,05!!0TL@;&EB<F%R>2X*(",*("--04M%1$504D5#051%1"`](%EE
M<PHK0E5)3$1?1$504D5#051%1"`](%EE<PH@(PH@(R!4:6UE<B!F;W(@=&AE
M(%-%0T].1"!A;F0@1%-%0TY$(')O=71I;F5S"B`C"D!`("TU,BPW("LU-"PW
M($!`"B`C($-#(&ES('1H92!#(&-O;7!I;&5R+"!N;W)M86QL>2!I;G9O:V5D
M('=I=&@@;W!T:6]N<R!#1DQ!1U,N"B`C"B!#0R`](&=C8PHM0T9,04=3(#T@
M+4\S"BM#1DQ!1U,@/2`M3S,@)"A"3$1/4%13*0H@(PH@(R`@5&AE(&%R8VAI
M=F5R(&%N9"!T:&4@9FQA9RAS*2!T;R!U<V4@=VAE;B!B=6EL9&EN9R!A<F-H
M:79E("AL:6)R87)Y*0H@(R`@268@>6]U('-Y<W1E;2!H87,@;F\@<F%N;&EB
M+"!S970@4D%.3$E"(#T@96-H;RX*0$`@+3<T+#<@*S<V+#<@0$`*(",@(&UA
M8VAI;F4M<W!E8VEF:6,L(&]P=&EM:7IE9"!"3$%3(&QI8G)A<GD@<VAO=6QD
M(&)E('5S960@=VAE;F5V97(*(",@('!O<W-I8FQE+BD*(",*+4),05-,24(@
M("`@("`]("XN+RXN+VQI8G)E9F)L87,N80HK0DQ!4TQ)0B`@("`@(#T@+BXO
M+BXO;&EB8FQA<RYA"B!#0DQ!4TQ)0B`@("`@/2`N+B\N+B]L:6)C8FQA<RYA
M"B!,05!!0TM,24(@("`@/2!L:6)L87!A8VLN80H@5$U'3$E"("`@("`@(#T@
M;&EB=&UG;&EB+F$*+2TM(&QA<&%C:RTS+C8N,2]"3$%3+U-20R]-86ME9FEL
M90DR,#$V+3`V+3$Y(#`X.C$U.C$Q+C`P,#`P,#`P,"`K,3`P,`HK*RL@;&%P
M86-K+3,N-BXQ+FYE=R]"3$%3+U-20R]-86ME9FEL90DR,#$W+3`U+3`T(#$U
M.C`R.C,P+C8Q,C0S.3DU-B`K,3`P,`I`0"`M-38L-R`K-38L,3$@0$`*(",C
M(R,C(R,C(R,C(R,C(R,C(R,C(R,C(R,C(R,C(R,C(R,C(R,C(R,C(R,C(R,C
M(R,C(R,C(R,C(R,C(R,C(R,C(R,C(R,C"B`*(&%L;#H@)"A"3$%33$E"*0HM
M(`HK"BML:6)B;&%S+G-O.B`D*$%,3$]"2BD**PDD*$9/4E1204XI("US:&%R
M960@+5=L+"US;VYA;64L)$`@+6\@)$`@)"A!3$Q/0DHI"BL);78@+68@;&EB
M8FQA<RYS;R`N+B\N+B`["BL*(",M+2TM+2TM+2TM+2TM+2TM+2TM+2TM+2TM
M+2TM+2TM+2TM+2TM+2TM+2TM+2TM+2TM+2TM+2TM+2T*(",@($-O;6UE;G0@
M;W5T('1H92!N97AT(#8@9&5F:6YI=&EO;G,@:68@>6]U(&%L<F5A9'D@:&%V
M90H@(R`@=&AE($QE=F5L(#$@0DQ!4RX*+2TM(&QA<&%C:RTS+C8N,2]34D,O
M36%K969I;&4),C`Q-BTP-BTQ.2`P.#HQ-3HQ,2XP,#`P,#`P,#`@*S$P,#`*
M*RLK(&QA<&%C:RTS+C8N,2YN97<O4U)#+TUA:V5F:6QE"3(P,3<M,#4M,#0@
M,34Z,#(Z,30N,C(T-C(P.3,T("LQ,#`P"D!`("TT-30L-B`K-#4T+#$P($!`
M"B`*(&%L;#H@+BXO)"A,05!!0TM,24(I"B`**VQI8FQA<&%C:RYS;SH@)"A!
M3$Q/0DHI("0H04Q,6$]"2BD@)"A$15!214-!5$5$*0HK"20H1D]25%)!3BD@
M+7-H87)E9"`M5VPL+7-O;F%M92PD0"`M;R`D0"`D*$%,3$]"2BD@)"A!3$Q8
M3T)**2`D*$1%4%)%0T%4140I"BL);78@+68@;&EB;&%P86-K+G-O("XN(#L*
M*PH@+BXO)"A,05!!0TM,24(I.B`D*$%,3$]"2BD@)"A!3$Q83T)**2`D*$1%
M4%)%0T%4140I"B`))"A!4D-(*2`D*$%20TA&3$%'4RD@)$`@)"A!3$Q/0DHI
I("0H04Q,6$]"2BD@)"A$15!214-!5$5$*0H@"20H4D%.3$E"*2`D0`H`
`
end
EOF
uudecode lapack-$LPVER.patch.uue
tar -xf lapack-$LPVER.tgz
cd lapack-$LPVER
patch -p1 < ../lapack-$LPVER.patch
cp make.inc.example make.inc
cd ..

# Create directories
mkdir -p lapack
cd lapack
mkdir -p $ALL_BUILDS

# Populate directories
for dir in $ALL_BUILDS ; do
  echo $dir;
  cd $dir;
  cp -Rf ../../lapack-$LPVER .
  cd ..;
done

# Set build options in each directory
for dir in generic intel ; do
  sed -i -e "s/^BLDOPTS\ *=.*/BLDOPTS\ \ = -fPIC -m64 -mtune=$dir/" $dir/lapack-$LPVER/make.inc
done
for dir in haswell nehalem skylake ; do
  sed -i -e "s/^BLDOPTS\ *=.*/BLDOPTS\ \ = -fPIC -march=$dir/" $dir/lapack-$LPVER/make.inc
done

# Build in each directory
for dir in $ALL_BUILDS ; do
  echo $dir ;
  pushd $dir/lapack-$LPVER/BLAS/SRC ;
  make $MAKE_OPTS ;
  make $MAKE_OPTS libblas.so ;
  cd ../../SRC ;
  make $MAKE_OPTS ;
  make $MAKE_OPTS liblapack.so ;
  popd;
done

# Done
cd ..
