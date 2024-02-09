% qp_bandpass_test.m
% Copyright (C) 2023 Robert G. Jenssen

test_common;

strf="qp_bandpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Band-pass filter specification
nplot=1000;
M=40;N=2*M;
fasl=0.15;fatlu=0.198;
fapl=0.2;faplu=0.22;fapul=0.248;fapu=0.25;
fatul=0.252;fasu=0.3;
Wasl=1;Watll=0.1;Watlu=0.2;
Wapl=50;Wap=25;Wapu=50;
Watul=0.2;Watuu=0.1;Wasu=1;

for d=[M,floor(M/2)],
  printf("Testing d=%d\n",d);

  % Filter impulse response SDP variables
  if d~=M,
    [~,~,Q,q]=directFIRnonsymmetricEsqPW ...
                (zeros(N+1,1),
                 [0,fasl,fatlu,fapl,faplu,fapul,fapu,fatul,fasu,0.5]*2*pi, ...
                 [0,0,0,1,1,1,0,0,0], ...
                 [0,0,0,d,d,d,0,0,0], ...
                 [Wasl,Watll,Watlu,Wapl,Wap,Wapu,Watul,Watuu,Wasu]);
  else
    [~,~,Q,q]=directFIRsymmetricEsqPW ...
                (zeros(M+1,1),
                 [0,fasl,fatlu,fapl,faplu,fapul,fapu,fatul,fasu,0.5]*2*pi, ...
                 [0,0,0,1,1,1,0,0,0], ...
                 [Wasl,Watll,Watlu,Wapl,Wap,Wapu,Watul,Watuu,Wasu]);
  endif
  
  % Solve
  [h,~,info]=qp(zeros(size(q)),Q,q);
  if info.info
    error("qp failed : %s",info.info);
  endif
  obj=(h'*Q*h)+(2*q*h) + ...
      (2*sum([Wapl,Wap,Wapu].*diff([fapl,faplu,fapul,fapu])));
  printf("obj=%g\n",obj);
  
  % Plot response
  if d~=M
    hd=h;
    print_polynomial(hd,"hd","%13.10f");
    print_polynomial(hd,"hd",sprintf("%s_hd_coef.m",strf),"%13.10f");
    strt=sprintf("Non-symmetric FIR : order N=%d,d=%d,fasl=%4.2f,fapl=%4.2f,\
fapu=%4.2f,fasu=%4.2f",N,d,fasl,fapl,fapu,fasu);
    subplot(211);
  else
    h=[h;h(M:-1:1)];
    print_polynomial(h,"h","%13.10f");
    print_polynomial(h,"h",sprintf("%s_h_coef.m",strf),"%13.10f");
    strt=sprintf("Symmetric FIR : order N=%d,fasl=%4.2f,fapl=%4.2f,\
fapu=%4.2f,fasu=%4.2f",N,fasl,fapl,fapu,fasu);
  endif
  f=(0:(nplot-1))'*0.5/nplot;
  nasl=ceil(fasl*nplot/0.5)+1;
  napl=floor(fapl*nplot/0.5)+1;
  napu=ceil(fapu*nplot/0.5)+1;
  nasu=floor(fasu*nplot/0.5)+1;
  H=freqz(h,1,nplot);
  ax=plotyy(f,20*log10(abs(H)),f,20*log10(abs(H)));
  axis(ax(1),[0 0.5 -60 -20]);
  axis(ax(2),[0 0.5 0.2*[-1 1]]);
  ylabel(ax(1),"Amplitude(dB)");
  grid("on");
  title(strt);
  if d~=M
    subplot(212)
    T=delayz(h,1,nplot);
    plot(f(napl:napu),T(napl:napu));
    axis([0 0.5 d+[-1 1]]);
    grid("on");
    ylabel("Delay(samples)");
    xlabel("Frequency");
    print(sprintf("%s_hd_response",strf),"-dpdflatex");
    close
  else
    xlabel("Frequency");
    print(sprintf("%s_h_response",strf),"-dpdflatex");
    close
  endif

  % Check amplitude response
  [A_max,n_max]=max(abs(H));
  printf("max(A)=%11.6g at f=%6.4f\n",A_max,f(n_max));

  [A_p_max,n_p_max]=max(abs(H(napl:napu)));
  printf("max(A_p)=%11.6g at f=%6.4f\n",A_p_max,f(napl+n_p_max-1));

  [A_p_min,n_p_min]=min(abs(H(napl:napu)));
  printf("min(A_p)=%11.6g at f=%6.4f\n", A_p_min,f(napl+n_p_min-1));

  [A_z,n_z_max]=max(abs(H(napl:napu)-e.^(-j*2*pi*f(napl:napu)*d)));
  printf("max(A_z)=%11.6g at f=%6.4f\n",A_z,f(napl+n_z_max-1));

  [A_sl_max,n_sl_max]=max(abs(H(1:nasl)));
  printf("max(A_sl)=%11.6g at f=%6.4f\n",A_sl_max,f(n_sl_max));

  [A_su_max,n_su_max]=max(abs(H(nasu:end)));
  printf("max(A_su)=%11.6g at f=%6.4f\n",A_su_max,f(nasu+n_su_max-1));
endfor

% Compare with a filter designed by the McClellan-Parks algorithm
K=5;
nPM=2*nplot;
fPM=(0:nPM)'*0.5/nPM;
nasl=ceil(fasl*nPM/0.5)+1;
napl=floor(fapl*nPM/0.5)+1;
napu=ceil(fapu*nPM/0.5)+1;
nasu=floor(fasu*nPM/0.5)+1;
F=[fPM(1:(nasl-1));fasl;fapl;fPM((napl+1):(napu-1));fapu;fasu;fPM((nasu+1):end)];
D=[zeros(nasl,1); ones(napu-napl+1,1); zeros(nPM+1-nasu+1,1)];
W=[ones(nasl,1); ones(napu-napl+1,1)/K; ones(nPM+1-nasu+1,1)];
[hPM,rho,fext,fiter,feasible]=mcclellanFIRsymmetric(M,F,D,W);
if feasible==false
  error("hPM not feasible");
endif

print_polynomial(hPM,"hPM","%13.10f");
print_polynomial(hPM,"hPM",sprintf("%s_hPM_coef.m",strf),"%13.10f");

APM=directFIRsymmetricA(2*pi*fPM,hPM);
ax=plotyy(fPM,20*log10(abs(APM)),fPM,20*log10(abs(APM)));
axis(ax(1),[0 0.5 -100 -60]);
axis(ax(2),[0 0.5 0.01*[-1 1]]);
ylabel(ax(1),"Amplitude(dB)");
xlabel("Frequency");
grid("on");
strt=sprintf("Symmetric FIR (Parks-McClellan) : \
order N=%d,fasl=%g,fapl=%g,fapu=%g,fasu=%g,K=%g,nplot=%d", ...
             N,fasl,fapl,fapu,fasu,K,nplot);
title(strt);
print(sprintf("%s_hPM_response",strf),"-dpdflatex");
close

% Save specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nplot=%d %% Frequency points in [0,0.5)\n",nplot);
fprintf(fid,"M=%d %% Filter order is 2*M\n",M);
fprintf(fid,"fasl=%g %% Amplitude lower stop band edge\n",fasl);
fprintf(fid,"fatlu=%g %% Amplitude lower trans. band upper edge\n",fatlu);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"faplu=%g %% Amplitude pass band lower upper edge\n",faplu);
fprintf(fid,"fapul=%g %% Amplitude pass band upper lower edge\n",fapul);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"fapul=%g %% Amplitude upper trans. band lower edge\n",fatul);
fprintf(fid,"fasu=%g %% Amplitude upper stop band edge\n",fasu);
fprintf(fid,"Wasl=%g %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Watll=%g %% Amplitude lower trans. band lower weight\n",Watll);
fprintf(fid,"Watlu=%g %% Amplitude lower trans. band upper weight\n",Watlu);
fprintf(fid,"Wapl=%g %% Amplitude pass band lower weight\n",Wapl);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Wapu=%g %% Amplitude pass band upper weight\n",Wapu);
fprintf(fid,"Watul=%g %% Amplitude upper trans. band lower weight\n",Watul);
fprintf(fid,"Watuu=%g %% Amplitude upper trans. band upper weight\n",Watuu);
fprintf(fid,"Wasu=%g %% Amplitude upper stop band weight\n",Wasu);
fclose(fid);

eval(sprintf("save %s.mat M fasl fatlu fapl faplu fapul fapu fatul fasu \
Wasl Watll Watlu Wapl Wap Wapu Watul Watuu Wasu nplot h hd K hPM rho\n",strf));

% Done
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
