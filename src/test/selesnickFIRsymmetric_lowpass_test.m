% selesnickFIRsymmetric_lowpass_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen

test_common;

delete("selesnickFIRsymmetric_lowpass_test.diary");
delete("selesnickFIRsymmetric_lowpass_test.diary.tmp");
diary selesnickFIRsymmetric_lowpass_test.diary.tmp

strf="selesnickFIRsymmetric_lowpass_test";

%  
% Initialise
%
nplot=4000;
maxiter=100;
tol=1e-10;
verbose=true;

%
% Filter design
%

% Failing specification: no extremal points in (0,ft] (M=11 is successful)
nf=200;M=10;deltap=1e-3;deltas=1e-4;ft=0.15;At=deltas;
strt=sprintf("Failing Selesnick-Burrus Hofstetter lowpass FIR: \
nf=%d,M=%d,$\delta\\_{p}$=%g,$\delta\\_{s}$=%g,$f\\_{t}$=%g,$A\\_{t}$=%g",
             nf,M,deltap,deltas,ft,At);
[hM,fext,fiter,feasible]= ...
  selesnickFIRsymmetric_lowpass(M,deltap,deltas,ft,At, ...
                                nplot,maxiter,tol,verbose);
if feasible==false
  warning("hM not feasible");
endif
Aext=directFIRsymmetricA(2*pi*fext,hM);
print_polynomial(fext,"fext","%13.10f");
print_polynomial(Aext,"Aext","%13.10f");

for k=["a","b","c","d"]
  
  % Successful specifications
  if k=="a"
    nf=2000;M=150;deltap=1e-6;deltas=1e-8;ft=0.15;At=1-deltap;
    typef="low-pass"; typeAt="1-deltap";
  elseif k=="b"
    nf=1000;M=85;deltap=1e-6;deltas=1e-8;ft=0.15;At=deltas;
    typef="low-pass"; typeAt="deltas";
  elseif k=="c"
    nf=200;M=21;deltap=1e-3;deltas=1e-3;ft=0.25;At=0.5;
    typef="half-band"; typeAt=sprintf("%f",At);
  else
    nf=2000;M=199;deltap=1e-6;deltas=1e-6;ft=0.25;At=0.5;
    typef="half-band"; typeAt=sprintf("%f",At);
  endif
  
  strt=sprintf("Selesnick-Burrus Hofstetter %s : \
nf=%d,M=%d,deltap=%g,deltas=%g,ft=%g,At=%s",typef,nf,M,deltap,deltas,ft,typeAt);

  % Filter design
  [hM,fext,fiter,feasible]= ...
  selesnickFIRsymmetric_lowpass(M,deltap,deltas,ft,At,nf,maxiter,tol,verbose);
  if feasible==false
    error("hM not feasible");
  endif
  Aext=directFIRsymmetricA(2*pi*fext,hM);
  print_polynomial(fext,"fext","%13.10f");
  print_polynomial(Aext,"Aext","%13.10f");

  % Check transition amplitude
  wt=2*pi*ft;
  Atrans=directFIRsymmetricA(wt,hM);
  if abs(Atrans-At)>tol
    error("abs(Atrans-At)>tol");
  endif

  %
  % Plot solution
  %
  F=0.5*(0:nplot)'/nplot;
  wa=(2*pi*F);
  A=directFIRsymmetricA(wa,hM);
  plot(F,20*log10(abs(A)))
  axis([0 0.5 (20*log10(deltas)-10) 1]);
  xlabel("Frequency");
  ylabel("Amplitude(dB)");
  grid("on");
  title(strt);
  print(sprintf("%s_hM%s_response",strf,k),"-dpdflatex");
  close

  % Dual plot
  nat=ceil(nplot*ft/0.5)+1;
  ax=plotyy(F(1:nat),20*log10(abs(A(1:nat))), ...
            F(nat:end),20*log10(abs(A(nat:end))));
  axis(ax(1),[0 0.5 -1e-5 1e-5]);
  axis(ax(2),[0 0.5 -170 -150]);
  ylabel(ax(1),"Amplitude(dB)");
  xlabel("Frequency");
  title(strt);
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
  fprintf(fid,"deltap=%d %% Amplitude pass band peak-to-peak ripple\n",deltap);
  fprintf(fid,"deltas=%d %% Amplitude stop band peak-to-peak ripple\n",deltas);
  fprintf(fid,"ft=%g %% Amplitude transition band frequency\n",ft);
  fprintf(fid,"At=%s %% Amplitude at transition band frequency\n",typeAt);
  fprintf(fid,"nf=%d %% Number of frequencies\n",nf);
  fprintf(fid,"tol=%g %% Tolerance on convergence\n",tol);
  fclose(fid);

  print_polynomial(hM,sprintf("hM%s",k),"%15.12f");
  print_polynomial(hM,sprintf("hM%s",k), ...
                   sprintf("%s_hM%s_coef.m",strf,k),"%15.12f");

  eval(sprintf("M_hM%c=M;",k));
  eval(sprintf("deltap_hM%c=deltap;",k));
  eval(sprintf("deltas_hM%c=deltas;",k));
  eval(sprintf("ft_hM%c=ft;",k));
  eval(sprintf("At_hM%c=At;",k));
  eval(sprintf("nf_hM%c=nf;",k));
  eval(sprintf("hM%c=hM;",k));
  
endfor

save selesnickFIRsymmetric_lowpass_test.mat  ...
     M_hMa deltap_hMa deltas_hMa ft_hMa At_hMa nf_hMa hMa ...
     M_hMb deltap_hMb deltas_hMb ft_hMb At_hMb nf_hMb hMb ...
     M_hMc deltap_hMc deltas_hMc ft_hMc At_hMc nf_hMc hMc ...
     M_hMd deltap_hMd deltas_hMd ft_hMd At_hMd nf_hMd hMd ...
     maxiter tol 
%
% Done
%
diary off
movefile selesnickFIRsymmetric_lowpass_test.diary.tmp ...
           selesnickFIRsymmetric_lowpass_test.diary;

