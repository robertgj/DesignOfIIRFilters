% schurOneMR2lattice2Abcd_test.m
% Copyright (C) 2017-2022 Robert G. Jenssen

test_common;

delete("schurOneMR2lattice2Abcd_test.diary");
delete("schurOneMR2lattice2Abcd_test.diary.tmp");
diary schurOneMR2lattice2Abcd_test.diary.tmp

strf="schurOneMR2lattice2Abcd_test";

%
% Filter polynomials
%

% Alternative filter from schur_retimed_test.m
f{1}.n =  [  1.8650e-01,  2.7266e-01,  1.8650e-01 ];
f{1}.dR = [  1.0000e+00,  0.0000e+00, -3.8742e-01 ];
% Filter from schur_retimed_test.m
f{2}.n =  [  7.8437e-02   7.1066e-02   6.8570e-03   7.1064e-02   7.8448e-02 ];
f{2}.dR = [  1.0000e+00  -0.0000e+00  -1.1715e+00   0.0000e+00   4.8630e-01 ];
% Alternative filter from schur_retimed_test.m
f{3}.n =  [  4.5209e-02   7.3948e-02  -7.4929e-03  -7.7909e-02 ...
            -7.5057e-03   7.3948e-02   4.5215e-02 ];
f{3}.dR = [  1.0000e+00  -0.0000e+00  -1.9955e+00   0.0000e+00 ...
             1.5866e+00  -0.0000e+00  -4.4804e-01 ];
% Filter from decimator_R2_test.m
f{4}.n =  [  0.0155218243,   0.0240308959,  -0.0089315143,  -0.0671762676, ... 
            -0.0733321965,   0.0234771012,   0.1767248129,   0.2765539847, ... 
             0.2532118929,   0.1421835206,   0.0405161645  ];
f{4}.dR = [  1.0000000000,   0.0000000000,  -0.4833140369,   0.0000000000, ... 
             0.4649814803,   0.0000000000,  -0.2543332803,   0.0000000000, ... 
             0.1080615273,   0.0000000000,  -0.0379951893,   0.0000000000, ... 
             0.0053801602 ]; 
% Filter from schurOneMlattice_sqp_slb_bandpass_test.m
f{5}.n =  [  0.0058051915,   0.0012706269,   0.0118334335,   0.0176878978, ... 
             0.0381312659,   0.0319388656,   0.0251518542,   0.0069289127, ... 
             0.0056626625,  -0.0173425626,  -0.0608005653,  -0.1007087591, ... 
            -0.0769181188,   0.0235594241,   0.1211872739,   0.1432972866, ... 
             0.0605790600,  -0.0337599144,  -0.0851805010,  -0.0611581082, ... 
            -0.0269399170];
f{5}.dR = [  1.0000000000,  -0.0000000000,   1.5714300377,  -0.0000000000, ... 
             1.8072457649,  -0.0000000000,   1.7877578723,  -0.0000000000, ... 
             1.5881253280,  -0.0000000000,   1.1504604633,  -0.0000000000, ... 
             0.7458129561,  -0.0000000000,   0.4015652852,  -0.0000000000, ... 
             0.1861402747,  -0.0000000000,   0.0599184246,  -0.0000000000, ... 
             0.0150432836 ];

tol_eps=20;

for l=1:length(f)
  
  %
  % Find the corresponding Schur one-multiplier lattice filter
  %

  % Schur one-multiplier decomposition
  [k,epsilon,p,c] = tf2schurOneMlattice(f{l}.n,f{l}.dR);

  % Retimed Schur lattice
  [A,B,C,D,Aap,Bap,Cap,Dap]=schurOneMR2lattice2Abcd(k,epsilon,c)

  % Compare the retimed Schur lattice transfer functions to the originals 
  [sn,sdR]=Abcd2tf(A,B,C,D);
  while abs(sn(1)) < tol_eps*eps, sn = sn(2:end); endwhile
  if max(abs(sn(1:length(f{l}.n))-f{l}.n))>tol_eps*eps
    error("sn differs from n by more than %d*eps",tol_eps);
  endif 
  if max(abs(sdR(1:length(f{l}.dR))-f{l}.dR))>tol_eps*eps
    error("sdR differs from dR by more than %d*eps",tol_eps);
  endif
  [snap,sdRap]=Abcd2tf(Aap,Bap,Cap,Dap);
  if max(abs(snap-fliplr(f{l}.dR)))>tol_eps*eps
    error("snap differs from fliplr(dR) by more than %d*eps",tol_eps);
  endif
  if max(abs(sdRap-f{l}.dR))>tol_eps*eps
    error("sdRap differs from dR by more than %d*eps",tol_eps);
  endif

  %
  % Find the output noise gain due to roundoff noise at the states
  %

  % Tapped filter noise gain
  [K W]=KW(A,B,C,D);
  delta=1;
  T=delta*diag(sqrt(diag(K)));
  selectX=(sum(A~=0,2)+(B~=0))>1;
  ng=sum(diag(K).*diag(W).*selectX)

  % All-pass noise gain
  [Kap Wap]=KW(Aap,Bap,Cap,Dap);
  Tap=delta*diag(sqrt(diag(Kap)));
  selectXap=(sum(Aap~=0,2)+(Bap~=0))>1;
  ngap=sum(diag(Kap).*diag(Wap).*selectXap)

  %
  % Simulate the Schur retimed lattice with state scaling
  %

  % Make a quantised noise signal with standard deviation 0.25*2^nbits
  nbits=10;
  scale=2^(nbits-1);
  nsamples=2^14;
  rand("seed",0xdeadbeef);
  n60=p2n60(f{l}.dR)
  u=rand(n60+nsamples,1)-0.5;
  u=0.25*u/std(u);
  u=round(u*scale);

  % Filter
  [yABCD,xxABCD]=svf(inv(T)*A*T,inv(T)*B,C*T,D,u,"none");
  [yABCDf,xxABCDf]=svf(inv(T)*A*T,inv(T)*B,C*T,D,u,"round");

  % Remove initial transient
  Rn60=(n60+1):length(u);
  ub=u(Rn60);
  yABCD=yABCD(Rn60);
  xxABCD=xxABCD(Rn60,:);
  yABCDf=yABCDf(Rn60);
  xxABCDf=xxABCDf(Rn60,:);

  % Check output round-off noise variance
  est_varyd=(1+ng)/12
  varyd=var(yABCD-yABCDf)

  % Check state variable standard deviation
  stdxx=std(xxABCD)

  % Plot frequency response
  nfpts=2048;
  nppts=(0:1023);
  HABCDf=crossWelch(ub,yABCDf,nfpts);
  plot(nppts/nfpts,20*log10(abs(HABCDf)));
  xlabel("Frequency");
  ylabel("Amplitude(dB)");
  axis([0 0.5 -60 5]);
  grid("on");
  print(sprintf("%s_output_response%d",strf,l),"-dpdflatex");
  close

  % All-pass filter
  [yABCDap,xxABCDap]=svf(inv(Tap)*Aap*Tap,inv(Tap)*Bap,Cap*Tap,Dap,u,"none");
  [yABCDapf,xxABCDapf]=svf(inv(Tap)*Aap*Tap,inv(Tap)*Bap,Cap*Tap,Dap,u,"round");

  % Remove initial transient
  yABCDap=yABCDap(Rn60);
  xxABCDap=xxABCDap(Rn60,:);
  yABCDapf=yABCDapf(Rn60);
  xxABCDapf=xxABCDapf(Rn60,:);

  % Check output round-off noise variance
  est_varydap=(1+ngap)/12
  varydap=var(yABCDap-yABCDapf)

  % Check state variable standard deviation
  stdxxap=std(xxABCDap)

  % Plot frequency response
  nfpts=2048;
  nppts=(0:1023);
  HABCDapf=crossWelch(ub,yABCDapf,nfpts);
  plot(nppts/nfpts,20*log10(abs(HABCDapf)));
  xlabel("Frequency");
  ylabel("Amplitude(dB)");
  axis([0 0.5 -0.2 0.2]);
  grid("on");
  print(sprintf("%s_allpass_response%d",strf,l),"-dpdflatex");
  close

endfor

%
% Done
%

diary off
movefile schurOneMR2lattice2Abcd_test.diary.tmp ...
         schurOneMR2lattice2Abcd_test.diary;
