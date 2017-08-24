#!/bin/bash

# Assumes lapack-$LPVER.tgz and octave-4.2.1.tar.lz are in the current directory

# Disable CPU frequency scaling:
# for c in `seq 0 7` ; do
#   echo "4500000">/sys/devices/system/cpu/cpu$c/cpufreq/scaling_min_freq ;
#   echo "performance">/sys/devices/system/cpu/cpu$c/cpufreq/scaling_governor ;
# done ; 

# Show system information
uname -r
grep -m1 -A7 vendor_id /proc/cpuinfo
sudo cpupower -c all frequency-info
dnf list installed kernel* gcc* atlas* openblas* gsl* blas* lapack* \
    | egrep -v metadata | awk '{print $1 "\t\t" $2}'

# Build local versions of the lapack and blas libraries
export LPVER=3.6.1
source ./build-lapack.sh
export LAPACK_DIR=`pwd`/lapack/generic/lapack-$LPVER

# Unpack Octave
export OCTAVEVER=4.2.1
cat > octave-$OCTAVEVER.patch.uue << 'EOF'
begin 666 octave-4.2.1.patch
M+2TM(&]C=&%V92TT+C(N,2YO;&0O;&EB;V-T879E+W-Y<W1E;2]F:6QE+7-T
M870N8V,),C`Q-RTP,BTR,R`P-3HP,3HU-2XP,#`P,#`P,#`@*S$Q,#`**RLK
M(&]C=&%V92TT+C(N,2]L:6)O8W1A=F4O<WES=&5M+V9I;&4M<W1A="YC8PDR
M,#$W+3`X+3`S(#$S.C,T.C(P+C`P-3`P,#4U,"`K,3`P,`I`0"`M,3<T+#<@
M*S$W-"PW($!`"B`@("`@("`@("`@=7!D871E7VEN=&5R;F%L("@I.PH@("`@
M("`@?0H@"BT@("`@:6YL:6YE(&9I;&5?<W1A=#HZ?F9I;&5?<W1A="`H*2![
M('T**R`@("!F:6QE7W-T870Z.GYF:6QE7W-T870@*"D@>R!]"B`*("`@("!V
M;VED"B`@("`@9FEL95]S=&%T.CIU<&1A=&5?:6YT97)N86P@*&)O;VP@9F]R
M8V4I"BTM+2!O8W1A=F4M-"XR+C$N;VQD+VQI8F]C=&%V92]N=6UE<FEC+W-C
M:'5R+F-C"3(P,3<M,#(M,C,@,#4Z,#$Z-34N,#`P,#`P,#`P("LQ,3`P"BLK
M*R!O8W1A=F4M-"XR+C$O;&EB;V-T879E+VYU;65R:6,O<V-H=7(N8V,),C`Q
M-RTP."TP,R`Q,SHS-#HT."XW,#`V.#,S,#(@*S$P,#`*0$`@+3$P,BPW("LQ
M,#(L-R!`0`H@("`@("`@:68@*&]R9%]C:&%R(#T]("=!)R!\?"!O<F1?8VAA
M<B`]/2`G1"<@?'P@;W)D7V-H87(@/3T@)V$G('Q\(&]R9%]C:&%R(#T]("=D
M)RD*("`@("`@("`@<V]R="`]("=3)SL*(`HM("`@("`@=F]L871I;&4@9&]U
M8FQE7W-E;&5C=&]R('-E;&5C=&]R(#T@,#L**R`@("`@("!D;W5B;&5?<V5L
M96-T;W(@<V5L96-T;W(@/2`P.PH@("`@("`@:68@*&]R9%]C:&%R(#T]("=!
M)R!\?"!O<F1?8VAA<B`]/2`G82<I"B`@("`@("`@('-E;&5C=&]R(#T@<V5L
M96-T7V%N83QD;W5B;&4^.PH@("`@("`@96QS92!I9B`H;W)D7V-H87(@/3T@
M)T0G('Q\(&]R9%]C:&%R(#T]("=D)RD*0$`@+3$X.2PW("LQ.#DL-R!`0`H@
M("`@("`@:68@*&]R9%]C:&%R(#T]("=!)R!\?"!O<F1?8VAA<B`]/2`G1"<@
M?'P@;W)D7V-H87(@/3T@)V$G('Q\(&]R9%]C:&%R(#T]("=D)RD*("`@("`@
M("`@<V]R="`]("=3)SL*(`HM("`@("`@=F]L871I;&4@9FQO871?<V5L96-T
M;W(@<V5L96-T;W(@/2`P.PHK("`@("`@(&9L;V%T7W-E;&5C=&]R('-E;&5C
M=&]R(#T@,#L*("`@("`@(&EF("AO<F1?8VAA<B`]/2`G02<@?'P@;W)D7V-H
M87(@/3T@)V$G*0H@("`@("`@("!S96QE8W1O<B`]('-E;&5C=%]A;F$\9FQO
M870^.PH@("`@("`@96QS92!I9B`H;W)D7V-H87(@/3T@)T0G('Q\(&]R9%]C
M:&%R(#T]("=D)RD*0$`@+3(W-BPW("LR-S8L-R!`0`H@("`@("`@:68@*&]R
M9%]C:&%R(#T]("=!)R!\?"!O<F1?8VAA<B`]/2`G1"<@?'P@;W)D7V-H87(@
M/3T@)V$G('Q\(&]R9%]C:&%R(#T]("=D)RD*("`@("`@("`@<V]R="`]("=3
M)SL*(`HM("`@("`@=F]L871I;&4@8V]M<&QE>%]S96QE8W1O<B!S96QE8W1O
M<B`](#`["BL@("`@("`@8V]M<&QE>%]S96QE8W1O<B!S96QE8W1O<B`](#`[
M"B`@("`@("!I9B`H;W)D7V-H87(@/3T@)T$G('Q\(&]R9%]C:&%R(#T]("=A
M)RD*("`@("`@("`@<V5L96-T;W(@/2!S96QE8W1?86YA/$-O;7!L97@^.PH@
M("`@("`@96QS92!I9B`H;W)D7V-H87(@/3T@)T0G('Q\(&]R9%]C:&%R(#T]
M("=D)RD*0$`@+3,X-"PW("LS.#0L-R!`0`H@("`@("`@:68@*&]R9%]C:&%R
M(#T]("=!)R!\?"!O<F1?8VAA<B`]/2`G1"<@?'P@;W)D7V-H87(@/3T@)V$G
M('Q\(&]R9%]C:&%R(#T]("=D)RD*("`@("`@("`@<V]R="`]("=3)SL*(`HM
M("`@("`@=F]L871I;&4@9FQO871?8V]M<&QE>%]S96QE8W1O<B!S96QE8W1O
M<B`](#`["BL@("`@("`@9FQO871?8V]M<&QE>%]S96QE8W1O<B!S96QE8W1O
M<B`](#`["B`@("`@("!I9B`H;W)D7V-H87(@/3T@)T$G('Q\(&]R9%]C:&%R
M(#T]("=A)RD*("`@("`@("`@<V5L96-T;W(@/2!S96QE8W1?86YA/$9L;V%T
M0V]M<&QE>#X["B`@("`@("!E;'-E(&EF("AO<F1?8VAA<B`]/2`G1"<@?'P@
1;W)D7V-H87(@/3T@)V0G*0H`
`
end
EOF
uudecode octave-$OCTAVEVER.patch.uue
tar -xf octave-$OCTAVEVER.tar.lz
cd octave-$OCTAVEVER
patch -p 1 < ../octave-$OCTAVEVER.patch
cd ..

# Build the benchmark versions
for BUILD in dbg static static-lto static-pgo static-lto-pgo \
                 shared shared-lto shared-pgo shared-lto-pgo ;
do
    #
    echo "Building" $BUILD
    #
    OCTAVE_DIR=`pwd`/octave-$OCTAVEVER ;
    OCTAVE_INSTALL_DIR=`pwd`/octave-$BUILD
    OCTAVE_PACKAGE_DIR=$OCTAVE_INSTALL_DIR/share/octave/packages 
    OCTAVE_PACKAGES=$OCTAVE_INSTALL_DIR/share/octave/octave_packages 
    mkdir -p build-$BUILD
    #
    cd build-$BUILD
    #
    rm -Rf *
    #
    source ../build-$BUILD.sh
    #
    make install
    # 
    echo "pkg prefix $OCTAVE_PACKAGE_DIR $OCTAVE_PACKAGE_DIR ; \
          pkg local_list $OCTAVE_PACKAGES ;" > .octaverc
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval \
'texi_macros_file("/dev/null");pkg install -forge struct optim control signal'
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval "pkg list"
    $OCTAVE_INSTALL_DIR/bin/octave-cli --eval "__octave_config_info__"
    #
    echo "Testing " $BUILD
    #
    for file in iir_sqp_slb_bandpass_test.m \
      test_common.m print_polynomial.m print_pole_zero.m \
      iir_slb.m iir_sqp_mmse.m iir_slb_show_constraints.m \
      iir_slb_update_constraints.m iir_slb_exchange_constraints.m \
      iir_slb_constraints_are_empty.m iir_slb_set_empty_constraints.m \
      Aerror.m Terror.m armijo_kim.m cl2bp.m fixResultNaN.m \
      iirA.m iirE.m iirP.m iirT.m iir_sqp_octave.m invSVD.m \
      local_max.m local_peak.m showResponseBands.m showResponse.m \
      showResponsePassBands.m showZPplot.m sqp_bfgs.m tf2x.m updateWchol.m \
      updateWbfgs.m x2tf.m xConstraints.m ; do
        cp -f ../../src/$file . 
    done

    for k in `seq 1 10`; do \
      LD_PRELOAD=$LAPACK_DIR"/liblapack.so:"$LAPACK_DIR"/libblas.so" \
        $OCTAVE_INSTALL_DIR/bin/octave-cli iir_sqp_slb_bandpass_test.m
      mv iir_sqp_slb_bandpass_test.diary iir_sqp_slb_bandpass_test.diary.$BUILD.$k
    done
    grep Elapsed iir_sqp_slb_bandpass_test.diary.$BUILD.* | \
      awk -v build_var=$BUILD '{elapsed=elapsed+$4;}; \
      END {printf("iir_sqp_slb_bandpass_test %s elapsed=%g\n",build_var,elapsed/10);}'
    #
    cd ..
    #    
done

# Now do library benchmarking
source ./library-benchmark.sh

# Done
