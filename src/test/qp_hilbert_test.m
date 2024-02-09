% qp_hilbert_test.m
% Copyright (C) 2023 Robert G. Jenssen

test_common;

strf="qp_hilbert_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Low-pass filter specification
M=40;d=(2*M)-1;N=(2*d);
fap=0.01;fas=0.49;

% Filter impulse response SDP variables
hsdp=sdpvar(1,M);

% Solve
[~,~,Q,q]=directFIRhilbertEsqPW(zeros(M,1),[fap,fas]*2*pi,1);
[hM,~,info]=qp(zeros(size(q)),Q,q);
if info.info
  error("qp failed : %s",info.info);
endif
obj=(hM'*Q*hM)+(2*q*hM)+(2*(fas-fap));
printf("obj=%g\n",obj);

% Plot response
h=zeros(N+1,1);
h(1:2:d)=-hM;
h((d+2):2:end)=hM(M:-1:1);
nplot=1000;
nap=(fap*nplot/0.5)+1;
nas=(fas*nplot/0.5)+1;
strt=sprintf("Hilbert FIR : order N=%d,fap=%5.3f,fas=%5.3f",N,fap,fas);
[H,w]=freqz(h,1,nplot);
f=w*0.5/pi;
plot(f,20*log10(abs(H)));
axis([0 0.5 0.04*[-1 1]]);
ylabel("Amplitude(dB)");
grid("on");
title(strt);
xlabel("Frequency");
print(sprintf("%s_response",strf),"-dpdflatex");
close

% Check amplitude response
[A_max,n_max]=max(abs(H)-1);
printf("max(A-1)=%11.6g at f=%6.4f\n",A_max,f(n_max));

[A_p_max,n_p_max]=max(abs(H(nap:nas))-1);
printf("max(A_p-1)=%11.6g at f=%6.4f\n",A_p_max,f(nap+n_p_max-1));

[A_p_min,n_p_min]=min(abs(H(nap:nas))-1);
printf("min(A_p-1)=%11.6g at f=%6.4f\n", A_p_min,f(nap+n_p_min-1));

[A_z,n_z_max]=max(abs(H(nap:nas)-e.^(-(j*((w(nap:nas)*d)+1.5)))));
printf("max(A_z)=%11.6g at f=%6.4f\n",A_z,f(nap+n_z_max-1));

[A_z,n_z_min]=min(abs(H(nap:nas)-e.^(-(j*((w(nap:nas)*d)+1.5)))));
printf("min(A_z)=%11.6g at f=%6.4f\n",A_z,f(nap+n_z_min-1));

% Save
print_polynomial(hM,"hM","%13.10f");
print_polynomial(hM,"hM", sprintf("%s_hM_coef.m",strf),"%13.10f");
print_polynomial(h,"h","%13.10f");
print_polynomial(h,"h", sprintf("%s_h_coef.m",strf),"%13.10f");

% Save specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nplot=%d %% Frequency points in [0,0.5)\n",nplot);
fprintf(fid,"M=%d %% Filter order is (4*M)-1\n",M);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fclose(fid);

eval(sprintf("save %s.mat nplot M fap fas hM h\n",strf));

% Done
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
