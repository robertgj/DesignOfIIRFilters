% schurOneMR2latticeFilter_test.m
% Copyright (C) 2025 Robert G. Jenssen
%
% Test cases for the Schur one-multiplier R=2 lattice filter 

test_common;

strf="schurOneMR2latticeFilter_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

%
% Design prototype lattice filters
%

% Filter from schur_retimed_test.m
f{1}.n = [  7.8437e-02   7.1066e-02   6.8570e-03   7.1064e-02   7.8448e-02 ];
f{1}.d = [  1.0000e+00  -0.0000e+00  -1.1715e+00   0.0000e+00   4.8630e-01 ];

% Alternative filter from schur_retimed_test.m
f{2}.n = [  4.5209e-02   7.3948e-02  -7.4929e-03  -7.7909e-02 ...
           -7.5057e-03   7.3948e-02   4.5215e-02 ];
f{2}.d = [  1.0000e+00  -0.0000e+00  -1.9955e+00   0.0000e+00 ...
            1.5866e+00  -0.0000e+00  -4.4804e-01 ];

% Filter from decimator_R2_test.m
f{3}.n = [  0.0155218243,   0.0240308959,  -0.0089315143,  -0.0671762676, ... 
           -0.0733321965,   0.0234771012,   0.1767248129,   0.2765539847, ... 
            0.2532118929,   0.1421835206,   0.0405161645,   0.0000000000, ...
            0.0000000000 ];
f{3}.d = [  1.0000000000,   0.0000000000,  -0.4833140369,   0.0000000000, ... 
            0.4649814803,   0.0000000000,  -0.2543332803,   0.0000000000, ... 
            0.1080615273,   0.0000000000,  -0.0379951893,   0.0000000000, ... 
            0.0053801602 ];

% Filter from schurOneMlattice_sqp_slb_bandpass_test.m
f{4}.n = [  0.0058051915,   0.0012706269,   0.0118334335,   0.0176878978, ... 
            0.0381312659,   0.0319388656,   0.0251518542,   0.0069289127, ... 
            0.0056626625,  -0.0173425626,  -0.0608005653,  -0.1007087591, ... 
           -0.0769181188,   0.0235594241,   0.1211872739,   0.1432972866, ... 
            0.0605790600,  -0.0337599144,  -0.0851805010,  -0.0611581082, ... 
           -0.0269399170];
f{4}.d = [  1.0000000000,  -0.0000000000,   1.5714300377,  -0.0000000000, ... 
            1.8072457649,  -0.0000000000,   1.7877578723,  -0.0000000000, ... 
            1.5881253280,  -0.0000000000,   1.1504604633,  -0.0000000000, ... 
            0.7458129561,  -0.0000000000,   0.4015652852,  -0.0000000000, ... 
            0.1861402747,  -0.0000000000,   0.0599184246,  -0.0000000000, ... 
            0.0150432836 ];

for x=1:length(f),

  n=f{x}.n;
  d=f{x}.d;  
  Nk=length(f{x}.d)-1;
  printf("\nTesting x=%d, Nk=%d\n",x,Nk);
  
  % Define the Schur lattice filter
  [k,epsilon,~,c]=tf2schurOneMlattice(n,d);
  p=ones((3*Nk/2)-1,1);
  [A,B,C,D,Aap,Bap,Cap,Dap]=schurOneMR2lattice2Abcd(k,epsilon,c);
  
  % Sanity checks
  [nn,dd]=Abcd2tf(A,B,C,D);
  if max(abs(nn((Nk+2):end))) > eps
    error("max(abs(nn((Nk+2) to end))) > eps");
  endif
  if max(abs(dd((Nk+2):end))) > eps
    error("max(abs(dd((Nk+2) to end))) > eps");
  endif
  if max(abs(nn(1:(Nk+1))-n)) > eps
    error("max(abs(nn(1 to (Nk+1))-n)) > eps");
  endif 
  if max(abs(dd(1:(Nk+1))-d)) > eps
    error("max(abs(dd(1 to (Nk+1))-d)) > eps");
  endif
  
  [nnap,ddap]=Abcd2tf(Aap,Bap,Cap,Dap);
  if max(abs(nnap((Nk+2):end))) > eps
    error("max(abs(nnap((Nk+2) to end))) > eps");
  endif
  if max(abs(ddap((Nk+2):end))) > eps
    error("max(abs(ddap((Nk+2) to end))) > eps");
  endif
  if max(abs(nnap(1:(Nk+1))-fliplr(d))) > eps
    error("max(abs(nnap(1 to (Nk+1))-fliplr(d))) > eps");
  endif 
  if max(abs(ddap(1:(Nk+1))-d)) > eps
    error("max(abs(ddap(1 to (Nk+1))-d)) > eps");
  endif

  % Scale the ABCD and AapBapCapDap state variable filters
  [K,~]=KW(A,B,C,D);
  delta=1;
  t=delta*sqrt(diag(K));
  T=diag(t);
  invT=diag(1./t);
  A=invT*A*T;
  B=invT*B;
  C=C*T;
  [Kap,~]=KW(Aap,Bap,Cap,Dap);
  tap=delta*sqrt(diag(Kap));
  Tap=diag(tap);
  invTap=diag(1./tap);
  Aap=invTap*Aap*Tap;
  Bap=invTap*Bap;
  Cap=Cap*Tap;

  % Use the ABCD scaling in the pipelined Schur lattice implementation
  p=t(:)';
  
  % Make a quantised noise signal
  nbits=10;
  scale=2^(nbits-1);
  nsamples=2^14;
  n60=p2n60(d);
  u=reprand(n60+nsamples,1)-0.5;
  u=0.25*u/std(u);
  u=round(u*scale);
  
  % Run the filter
  ynd=filter(n,d,u);
  [yap y xx]=schurOneMR2latticeFilter(k,epsilon,p,c,u,"none");
  [yapf yf xxf]=schurOneMR2latticeFilter(k,epsilon,p,c,u,"round");
  [yABCD,xxABCD]=svf(A,B,C,D,u,"none");
  [yABCDf,xxABCDf]=svf(A,B,C,D,u,"round");
  [yABCDap,xxABCDap]=svf(Aap,Bap,Cap,Dap,u,"none");
  [yABCDapf,xxABCDapf]=svf(Aap,Bap,Cap,Dap,u,"round");

  % Remove initial transient
  Rn60=(n60+1):length(u);
  u=u(Rn60);
  ynd=ynd(Rn60);
  y=y(Rn60);
  yf=yf(Rn60);
  yap=yap(Rn60);
  yapf=yapf(Rn60);
  yABCD=yABCD(Rn60);
  yABCDf=yABCDf(Rn60);
  yABCDap=yABCDap(Rn60);
  yABCDapf=yABCDapf(Rn60);

  % Sanity checks
  if max(abs(y-ynd)) > 2000*eps
    error("max(abs(y-ynd))(%g*eps) > 2000*eps",max(abs(y-ynd)/eps));
  endif
  if max(abs(y-yABCD)) > 2000*eps
    error("max(abs(y-yABCD))(%g*eps) > 2000*eps",max(abs(y-yABCD))/eps);
  endif
  if max(abs(yap-yABCDap)) > 2000*eps
    error("max(abs(yap-yABCDap))(%g*eps) > 2000*eps", ...
            max(abs(yap-yABCDap))/eps);
  endif
  if max(abs(yf-yABCDf)) > 2000*eps
    error("max(abs(yf-yABCDf))(%g*eps) > 2000*eps",max(abs(yf-yABCDf))/eps);
  endif
  if max(abs(yapf-yABCDapf)) > 2000*eps
    error("max(abs(yapf-yABCDapf))(%g*eps) > 2000*eps", ...
          max(abs(yapf-yABCDapf))/eps);
  endif
  
  % Check state variable std. deviation
  stdxx=std(xx(Rn60,:))
  stdxxf=std(xxf(Rn60,:))
  stdxxABCD=std(xxABCD(Rn60,:))
  stdxxABCDf=std(xxABCDf(Rn60,:))
  stdxxABCDap=std(xxABCDap(Rn60,:))
  stdxxABCDapf=std(xxABCDapf(Rn60,:))

  % Calculate frequency response for the ABCD and Schur lattice implementations
  nfpts=2^12;
  nppts=(0:((nfpts/2)-1));
  fnppts=nppts*0.5/nppts(end);
  Hnd=freqz(n,d,2*pi*fnppts);
  H=crossWelch(u,y,nfpts);
  HABCD=crossWelch(u,yABCD,nfpts);
  Hap=crossWelch(u,yap,nfpts);
  HABCDap=crossWelch(u,yABCDap,nfpts);
  Hf=crossWelch(u,yf,nfpts);
  HABCDf=crossWelch(u,yABCDf,nfpts);
  Hapf=crossWelch(u,yapf,nfpts);
  HABCDapf=crossWelch(u,yABCDapf,nfpts);

  % Plot
  plot(nppts/nfpts,20*log10(abs([H(:),Hap(:)])))
  axis([0 0.5 -80 5])
  grid("on");
  xlabel("Frequency")
  ylabel("Amplitude(dB)")
  print(sprintf("%s_response_%d",strf,Nk),"-dpdflatex");
  close

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
