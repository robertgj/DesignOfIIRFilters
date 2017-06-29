% schurOneMR2lattice2Abcd_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurOneMR2lattice2Abcd_test.diary");
unlink("schurOneMR2lattice2Abcd_test.diary.tmp");
diary schurOneMR2lattice2Abcd_test.diary.tmp

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
f{4}.n =  [   0.0006670162,  -0.0026216897,  -0.0039101141,   0.0111497026, ... 
              0.0259815865,   0.0025532210,  -0.0494964113,  -0.0635004635, ... 
              0.0018793375,   0.1121665241,   0.1805501723,   0.1454782721, ... 
              0.0537002261 ];
f{4}.dR = [   1.0000000000,   0.0000000000,  -1.2500597009,   0.0000000000, ... 
              1.1982389342,   0.0000000000,  -0.8339771575,   0.0000000000, ... 
              0.4191489823,   0.0000000000,  -0.1465319531,   0.0000000000, ... 
              0.0277783569 ]; 
 % Filter from schurOneMlattice_sqp_slb_bandpass_test.m
f{5}.n =  [   0.0023859122,  -0.0015081026,   0.0061648873,   0.0144832636, ... 
              0.0316730381,   0.0279667393,   0.0204984234,   0.0077691540, ... 
              0.0059396642,  -0.0163870947,  -0.0619300123,  -0.0990072266, ... 
             -0.0731114507,   0.0258103302,   0.1174122287,   0.1339936130, ... 
              0.0537010475,  -0.0342726086,  -0.0790579382,  -0.0555016217, ... 
             -0.0236135458 ];
f{5}.dR = [   1.0000000000,  -0.0000000000,   1.5910285875,  -0.0000000000, ... 
              1.8662201415,  -0.0000000000,   1.8395381742,  -0.0000000000, ... 
              1.6256733015,  -0.0000000000,   1.1646841245,  -0.0000000000, ... 
              0.7469684663,  -0.0000000000,   0.3950965740,  -0.0000000000, ... 
              0.1788931112,  -0.0000000000,   0.0545947937,  -0.0000000000, ... 
              0.0134002323 ];

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
  lenffn=length(f{l}.n)
  if (sum(abs(sn(1:lenffn)-f{l}.n))+sum(abs(sn((lenffn+1):end))))>5*eps
    error("sn differs from n by more than 5*eps");
  endif
  lenffdR=length(f{l}.dR)
  if (sum(abs(sdR(1:lenffdR)-f{l}.dR))+ ...
      sum(abs(sdR((lenffdR+1):end))))>13*eps
    error("sdR differs from dR by more than 13*eps");
  endif
  [snap,sdRap]=Abcd2tf(Aap,Bap,Cap,Dap);
  if sum(abs(snap-fliplr(f{l}.dR)))>5*eps
    error("snap differs from fliplr(dR) by more than 5*eps");
  endif
  if sum(abs(sdRap-f{l}.dR))>13*eps
    error("sdRap differs from dR by more than 13*eps");
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
  print(sprintf("schurOneMR2lattice2Abcd_output_response%d",l),"-dpdflatex");
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
  print(sprintf("schurOneMR2lattice2Abcd_allpass_response%d",l),"-dpdflatex");
  close

endfor

%
% Done
%

diary off
movefile schurOneMR2lattice2Abcd_test.diary.tmp schurOneMR2lattice2Abcd_test.diary;
