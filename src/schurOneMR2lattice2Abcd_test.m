% schurOneMR2lattice2Abcd_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

unlink("schurOneMR2lattice2Abcd_test.diary");
unlink("schurOneMR2lattice2Abcd_test.diary.tmp");
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
f{5}.n =  [  0.0052643487,   0.0010152645,   0.0112315300,   0.0176756361, ... 
             0.0374749049,   0.0315707327,   0.0244003070,   0.0070318497, ... 
             0.0055821987,  -0.0173213380,  -0.0611997404,  -0.1005481086, ... 
            -0.0761585492,   0.0243005892,   0.1209546485,   0.1418303699, ... 
             0.0592282968,  -0.0342092936,  -0.0843631441,  -0.0602905531, ... 
            -0.0263491648  ];
f{5}.dR = [  1.0000000000,  -0.0000000000,   1.5669164611,  -0.0000000000, ... 
             1.8068495584,  -0.0000000000,   1.7854838604,  -0.0000000000, ... 
             1.5864042909,  -0.0000000000,   1.1475524994,  -0.0000000000, ... 
             0.7436080016,  -0.0000000000,   0.3996961501,  -0.0000000000, ... 
             0.1852196196,  -0.0000000000,   0.0593087260,  -0.0000000000, ... 
             0.0149083790 ];

tol_eps=10;

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
  if abs(sum(sn)-sum(f{l}.n))>tol_eps*eps
    error("sn differs from n by more than %d*eps",tol_eps);
  endif
  if sum(abs(sdR(1:length(f{l}.dR))-f{l}.dR))>tol_eps*eps
    error("sdR differs from dR by more than %d*eps",tol_eps);
  endif
  [snap,sdRap]=Abcd2tf(Aap,Bap,Cap,Dap);
  if sum(abs(snap-fliplr(f{l}.dR)))>tol_eps*eps
    error("snap differs from fliplr(dR) by more than %d*eps",tol_eps);
  endif
  if sum(abs(sdRap-f{l}.dR))>tol_eps*eps
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
  u=rand(nsamples,1)-0.5;
  u=0.25*u/std(u);
  u=round(u*scale);

  % Filter
  [yABCD,xxABCD]=svf(inv(T)*A*T,inv(T)*B,C*T,D,u,"none");
  [yABCDf,xxABCDf]=svf(inv(T)*A*T,inv(T)*B,C*T,D,u,"round");

  % Check output round-off noise variance
  est_varyd=(1+ng)/12
  varyd=var(yABCD-yABCDf)

  % Check state variable standard deviation
  stdxx=std(xxABCD)

  % Plot frequency response
  nfpts=2048;
  nppts=(0:1023);
  HABCDf=crossWelch(u,yABCDf,nfpts);
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

  % Check output round-off noise variance
  est_varydap=(1+ngap)/12
  varydap=var(yABCDap-yABCDapf)

  % Check state variable standard deviation
  stdxxap=std(xxABCDap)

  % Plot frequency response
  nfpts=2048;
  nppts=(0:1023);
  HABCDapf=crossWelch(u,yABCDapf,nfpts);
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
