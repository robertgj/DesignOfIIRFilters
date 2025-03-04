% selesnickFIRsymmetric_bandpass_test.m
% Copyright (C) 2020-2025 Robert G. Jenssen

test_common;

delete("selesnickFIRsymmetric_bandpass_test.diary");
delete("selesnickFIRsymmetric_bandpass_test.diary.tmp");
diary selesnickFIRsymmetric_bandpass_test.diary.tmp

strf="selesnickFIRsymmetric_bandpass_test";

%  
% Initialise
%
nplot=4000; 
max_iter=100;
tol=1e-10;
verbose=true;

for k=["a","b","c"]
  
  % Specifications
  if k=="a"
    nf=1600;M=250;deltasl=1e-5;deltap=1e-4;deltasu=1e-5;ftl=0.2;ftu=0.35;
    At=0.5; typeAt=sprintf("%f",At);
  elseif k=="b"
    nf=1600;M=340;deltasl=1e-5;deltap=1e-4;deltasu=1e-5;ftl=0.2;ftu=0.35;
    At=deltasl; typeAt="deltasl";
  else
    nf=1800;M=255;deltasl=1e-5;deltap=1e-4;deltasu=1e-5;ftl=0.2;ftu=0.35;
    At=1-deltap; typeAt="1-deltap";
  endif
  strt=sprintf("Selesnick-Burrus Hofstetter band-pass : \
M=%d,deltasl=%g,deltap=%g,deltasu=%g,ftl=%g,ftu=%g,At=%s",
               M,deltasl,deltap,deltasu,ftl,ftu,typeAt);

  % Filter design
  [hM,fext,fiter,feasible]= ...
  selesnickFIRsymmetric_bandpass(M,deltasl,deltap,deltasu,ftl,ftu,At, ...
                                 nf,max_iter,tol,verbose);
  if feasible==false
    error("hM not feasible");
  endif
  Aext=directFIRsymmetricA(2*pi*fext,hM);
  print_polynomial(fext,"fext","%13.10f");
  print_polynomial(Aext,"Aext","%13.10f");

  % Check transition frequency amplitudes
  wt=[ftl,ftu]*2*pi;
  Atrans=directFIRsymmetricA(wt,hM);
  if any(abs(Atrans-At)>tol)
    error("any(abs(Atrans-At)>tol)");
  endif

  % Check transition frequency amplitude slope
  del=tol;
  AtPdel=directFIRsymmetricA(wt+del,hM);
  AtMdel=directFIRsymmetricA(wt-del,hM);
  diffAt=(AtPdel-AtMdel)/(2*del);
  MM=(M:-1:1)';
  dAdwt=-sum(2*((MM.*hM(1:M)).*ones(size(wt))).*sin(MM.*wt));
  printf("dAdwt=[%g,%g]\n",dAdwt(1),dAdwt(2));

  %
  % Plot solution
  %
  F=0.5*(0:nplot)'/nplot;
  wa=2*pi*F;
  A=directFIRsymmetricA(wa,hM);
  plot(F,20*log10(abs(A)),[ftl,ftu],20*log10(abs([At,At])),"x")
  axis([0 0.5 (20*log10(deltasl)-10) 1]);
  xlabel("Frequency");
  ylabel("Amplitude(dB)");
  grid("on");
  title(strt);
  print(sprintf("%s_hM%s_response",strf,k),"-dpdflatex");
  close

  % Dual plot
  ax=plotyy(F,A,F,A);
  axis(ax(1),[0 0.5 1-(2*deltap) 1+(2*deltap)]);
  axis(ax(2),[0 0.5 -2*deltasl 2*deltasl]);
  title(strt);
  ylabel("Amplitude");
  xlabel("Frequency");
  grid("on");
  print(sprintf("%s_hM%s_dual",strf,k),"-dpdflatex");
  close

  % Plot zeros
  zplane(qroots([hM;flipud(hM(1:(end-1)))]));
  title(strt);
  grid("on");
  print(sprintf("%s_hM%s_zeros",strf,k),"-dpdflatex");
  close

  %
  % Save the results
  %
  fid=fopen(sprintf("%s_hM%s_spec.m",strf,k),"wt");
  fprintf(fid,"M=%d %% Filter order is 2*M\n",M);
  fprintf(fid,"deltasl=%g %% Amplitude lower stop-band peak ripple\n",deltasl);
  fprintf(fid,"deltap=%g %% Amplitude pass-band peak ripple\n",deltap);
  fprintf(fid,"deltasu=%g %% Amplitude upper stop-band peak ripple\n",deltasu);
  fprintf(fid,"ftl=%g %% Amplitude lower transition band frequency\n",ftl);
  fprintf(fid,"ftu=%g %% Amplitude upper transition band frequency\n",ftu);
  fprintf(fid,"At=%s %% Amplitude at transition band frequencies\n",typeAt);
  fprintf(fid,"nf=%d %% Number of frequencies\n",nf);
  fprintf(fid,"tol=%g %% Tolerance on convergence\n",tol);
  fclose(fid);

  print_polynomial(hM,sprintf("hM%s",k),"%15.12f");
  print_polynomial(hM,sprintf("hM%s",k), ...
                   sprintf("%s_hM%s_coef.m",strf,k),"%15.12f");

  eval(sprintf("M_hM%c=M;",k));
  eval(sprintf("deltasl_hM%c=deltasl;",k));
  eval(sprintf("deltap_hM%c=deltap;",k));
  eval(sprintf("deltasu_hM%c=deltasu;",k));
  eval(sprintf("ftl_hM%c=ftl;",k));
  eval(sprintf("ftu_hM%c=ftu;",k));
  eval(sprintf("At_hM%c=At;",k));
  eval(sprintf("nf_hM%c=nf;",k));
  eval(sprintf("hM%c=hM;",k));

endfor

save selesnickFIRsymmetric_bandpass_test.mat  ...
  M_hMa deltasl_hMa deltap_hMa deltasu_hMa ftl_hMa ftu_hMa At_hMa nf_hMa hMa ...
  M_hMb deltasl_hMb deltap_hMb deltasu_hMb ftl_hMb ftu_hMb At_hMb nf_hMb hMb ...
  M_hMc deltasl_hMc deltap_hMc deltasu_hMc ftl_hMc ftu_hMc At_hMc nf_hMc hMc ...
  max_iter tol 

%
% Done
%
diary off
movefile selesnickFIRsymmetric_bandpass_test.diary.tmp ...
         selesnickFIRsymmetric_bandpass_test.diary;

