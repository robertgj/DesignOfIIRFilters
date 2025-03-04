% directFIRnonsymmetric_socp_lowpass_test.m
% Copyright (C) 2021-2025 Robert G. Jenssen
% SDP design of a direct-form non-symmetric FIR lowpass filter with SOCP

test_common;

delete("directFIRnonsymmetric_socp_lowpass_test.diary");
delete("directFIRnonsymmetric_socp_lowpass_test.diary.tmp");
diary directFIRnonsymmetric_socp_lowpass_test.diary.tmp

tic;

verbose=false;
strf="directFIRnonsymmetric_socp_lowpass_test";

% Low-pass filter specification
N=30;d=10;fap=0.175;Wap=1;Wat=0.01;fas=0.25;Was=100;

% Set up the SeDuMi arguments for quadratic constraint on the amplitude response
[~,~,Q,q]=directFIRnonsymmetricEsqPW ...
            (zeros(N+1,1),[0,fap,fas,0.5]*2*pi,[1,0,0],[d,0,0],[Wap,Wat,Was]);
[U,P]=chol(Q);
if P~=0
  error("Q not positive definite");
endif
b=[1;zeros(N+1,1)];
At=-[b,[zeros(1,N+1);U]];
bt=-b;
ct=[0;inv(U')*q(:)];
K.q=size(At,2);
pars.fid=1;

% Call SeDuMi
try
  [x,y,info]=sedumi(At,bt,ct,K,pars);
  printf("SeDuMi info.iter=%d, info.feasratio=%6.4g\n",info.iter,info.feasratio);
  if info.pinf
    error("SeDuMi primary problem infeasible");
  endif
  if info.dinf
    error("SeDuMi dual problem infeasible");
  endif 
  if info.numerr == 1
    error("SeDuMi premature termination"); 
  elseif info.numerr == 2 
    error("SeDuMi numerical failure");
  elseif info.numerr
    error("SeDuMi info.numerr=%d",info.numerr);
  endif
catch
  err=lasterror();
  for e=1:length(err.stack)
    fprintf(stderr,"Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("%s\n", err.message);
end_try_catch

% Extract filter impulse response
h=y(2:end);
print_polynomial(h,"h");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"));

% Calculate response
nplot=1000;
nap=floor(fap*nplot/0.5)+1;
nas=floor(fas*nplot/0.5)+1;
f=(0:(nplot-1))'*0.5/nplot;
w=2*pi*f;
H=freqz(h,1,w);
T=delayz(h,1,nplot);

% Find pass-band ripple
[maxPassRipple,imaxPassRipple]=max(abs(abs(H(1:nap))-1));
dBap=abs(20*log10(abs(H(imaxPassRipple))));
[maxStop,imaxStop]=max(abs(H(nas:end)));
imaxStop=imaxStop+nas;
dBas=abs(20*log10(maxStop));
tdr=max(abs(T(1:nap)-d));

% Plot response
subplot(211)
plot(f,20*log10(abs(H)), ...
     f([imaxPassRipple,imaxStop]), ...
     20*log10(abs(H([imaxPassRipple,imaxStop]))),"+");
ylabel("Amplitude(dB)");
axis([0 0.5 -80 10]);
grid("on");
strt=sprintf("SOCP designed non-symmetric FIR filter : \
N=%d,d=%d,fap=%g,dBap=%g,tdr=%g,Wap=%g,fas=%g,dBas=%g,Was=%g",
             N,d,fap,dBap,tdr,Wap,fas,dBas,Was);
title(strt);
subplot(212)
plot(w*0.5/pi,T);
xlabel("Frequency");
ylabel("Delay(samples)");
axis([0 0.5 0 20]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
subplot(211)
axis([0 fap -1.0 0.2]);
subplot(212)
axis([0 fap d+[-2,2]]);
grid("on");
print(strcat(strf,"_passband"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"N=%d %% FIR filter order\n",N);
fprintf(fid,"d=%d %% Nominal FIR filter delay\n",d);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fclose(fid);

% Save results
save directFIRnonsymmetric_socp_lowpass_test.mat N d fap dBap Wap fas dBas Was h
       
% Done
toc;
diary off
movefile directFIRnonsymmetric_socp_lowpass_test.diary.tmp ...
         directFIRnonsymmetric_socp_lowpass_test.diary;
