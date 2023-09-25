% qp_lowpass_test.m
% Copyright (C) 2023 Robert G. Jenssen

test_common;

strf="qp_lowpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Low-pass filter specification
nplot=1000;
M=14;N=2*M;
fap=0.17265;fas=0.26265;
Wap=10;Wat=0.01;Was=1;

for d=[M,floor(M/2)],
  printf("Testing d=%d\n",d);

  % Filter impulse response QP matrixes
  if d~=M,
    [~,~,Q,q]=directFIRnonsymmetricEsqPW ...
               (zeros(N+1,1),[0,fap,fas,0.5]*2*pi,[1,0,0],[d,0,0],[Wap,Wat,Was]);
  else
    [~,~,Q,q]=directFIRsymmetricEsqPW ...
               (zeros(M+1,1),[0,fap,fas,0.5]*2*pi,[1,0,0],[Wap,Wat,Was]);
  endif
  
  % Solve
  [h,~,info]=qp(zeros(size(q)),Q,q);
  if info.info
    error("qp failed : %s",info.info);
  endif
  obj=(h'*Q*h)+(2*q*h)+(2*fap*Wap);
  printf("obj=%g\n",obj);

  % Plot response
  if d~=M
    hd=h;
    print_polynomial(hd,"hd","%13.10f");
    print_polynomial(hd,"hd",sprintf("%s_hd_coef.m",strf),"%13.10f");
    strt=sprintf("Non-symmetric FIR : order N=%d,d=%d,fap=%g,fas=%g",
                 N,d,fap,fas);
    subplot(211);
  else
    h=[h;h(M:-1:1)];
    print_polynomial(h,"h","%13.10f");
    print_polynomial(h,"h",sprintf("%s_h_coef.m",strf),"%13.10f");
    strt=sprintf("Symmetric FIR : order N=%d,fap=%g,fas=%g",N,fap,fas);
  endif
  f=(0:(nplot-1))'*0.5/nplot;
  nap=ceil(fap*nplot/0.5)+1;
  nas=floor(fas*nplot/0.5)+1;
  H=freqz(h,1,nplot);
  ax=plotyy(f(1:nap),20*log10(abs(H(1:nap))), ...
            f(nap:end),20*log10(abs(H(nap:end))));
  set(ax(1),'ycolor','black');
  set(ax(2),'ycolor','black');
  axis(ax(1),[0 0.5 0.1*[-1 1]]);
  axis(ax(2),[0 0.5 -60 -20]);
  ylabel(ax(1),"Amplitude(dB)");
  grid("on");
  title(strt);
  if d~=M
    subplot(212)
    T=delayz(h,1,nplot);
    plot(f(1:nap),T(1:nap));
    axis([0 0.5 d-0.4 d+0.4]);
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

  [A_p_max,n_p_max]=max(abs(H(1:nap)));
  printf("max(A_p)=%11.6g at f=%6.4f\n",A_p_max,f(n_p_max));

  [A_p_min,n_p_min]=min(abs(H(1:nap)));
  printf("min(A_p)=%11.6g at f=%6.4f\n", A_p_min,f(n_p_min));

  [A_z,n_z_max]=max(abs(H(1:nap)-e.^(-j*2*pi*f(1:nap)*d)));
  printf("max(A_z)=%11.6g at f=%6.4f\n",A_z,f(n_z_max));

  [A_t_max,n_t_max]=max(abs(H((nap+1):(nas-1))));
  printf("max(A_t)=%11.6g at f=%6.4f\n",A_t_max,f(nap+n_t_max));

  [A_t_min,n_t_min]=min(abs(H((nap+1):(nas-1))));
  printf("min(A_t)=%11.6g at f=%6.4f\n",A_t_min,f(nap+n_t_min));

  [A_s_max,n_s_max]=max(abs(H(nas:end)));
  printf("max(A_s)=%11.6g at f=%6.4f\n",A_s_max,f(nas-1+n_s_max));

endfor

% Compare with a filter designed by the McClellan-Parks algorithm
K=5;
nPM=2*nplot;
fPM=(0:(nPM-1))'*0.5/nPM;
nap=ceil(fap*nPM/0.5)+1;
nas=floor(fas*nPM/0.5)+1;
F=[fPM(1:(nap-1));fap;fas;fPM((nas+1):end)];
gs=length(F);
D=[ones(nap,1); zeros(gs-nap,1)];
W=[ones(nap,1)/K; ones(gs-nap,1)];
[hPM,rho,fext,fiter,feasible]=mcclellanFIRsymmetric(M,F,D,W);
if feasible==false
  error("hPM not feasible");
endif

print_polynomial(hPM,sprintf("hPM"),"%13.10f");
print_polynomial(hPM,sprintf("hPM"),sprintf("%s_hPM_coef.m",strf),"%13.10f");

APM=directFIRsymmetricA(2*pi*fPM,hPM);
ax=plotyy(fPM(1:nap),20*log10(abs(APM(1:nap))), ...
          fPM(nap:end),20*log10(abs(APM(nap:end))));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 0.1*[-1 1]]);
axis(ax(2),[0 0.5 -60 -20]);
ylabel(ax(1),"Amplitude(dB)");
xlabel("Frequency");
grid("on");
strt=sprintf("Symmetric FIR (Parks-McClellan) : \
order N=%d,K=%3.1f,fap=%g,fas=%g",2*M,K,fap,fas);
title(strt);
print(sprintf("%s_hPM_response",strf),"-dpdflatex");
close

% Save specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"nplot=%d %% Frequency points in [0,0.5)\n",nplot);
fprintf(fid,"M=%d %% Filter order is 2*M\n",M);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Wat=%g %% Amplitude transition band weight\n",Wat);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fclose(fid);

eval(sprintf("save %s.mat M fap fas nplot h hd K nPM hPM rho\n",strf));

% Done
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
