% directFIRhilbert_socp_mmsePW_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

delete("directFIRhilbert_socp_mmsePW_test.diary");
delete("directFIRhilbert_socp_mmsePW_test.diary.tmp");
diary directFIRhilbert_socp_mmsePW_test.diary.tmp

tic;

maxiter=2000
tol=1e-8
ctol=tol
verbose=false
strf="directFIRhilbert_socp_mmsePW_test";
                                         
% Hilbert filter frequency specification (dBap=0.05 also works)
M=40;fapl=0.01;fapu=0.5-fapl;dBap=0.04034;Wap=1;Was=0;
npoints=1000;
wa=(0:((npoints)-1))'*pi/(npoints);
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
Ad=-ones(npoints,1);
if 0
  Adl=-(10^(dBap/40))*ones(npoints,1);
  Adu=-[zeros(napl-1,1); ...
        (10^(-dBap/40))*ones(napu-napl+1,1); ...
        zeros(npoints-napu,1)];
else
  Adl=Ad;
  Adu=-[zeros(napl-1,1); ...
        (10^(-dBap/20))*ones(napu-napl+1,1); ...
        zeros(npoints-napu,1)];
endif
Wa=[Was*ones(napl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Was*ones(npoints-napu,1)];

% Make a Hilbert filter
n4M1=((-2*M)+1):2:((2*M)-1)';
h0=zeros((4*M)-1,1);
h0(n4M1+(2*M))=2*(sin(pi*n4M1/2).^2)./(pi*n4M1);
h0=h0.*hamming((4*M)-1);
hM0=h0(1:2:((2*M)-1));
% Find the exact coefficient error
na=[napl,(npoints)/2];
waf=wa(na);
Adf=-1;
Waf=Wap;
Esq0=directFIRhilbertEsqPW(hM0,waf,Adf,Waf);
printf("Esq0=%g\n",Esq0);

%
% SOCP SLB solution
%
try
  war=(napl:(npoints)/2);
  [hM1,slb_iter,socp_iter,func_iter,feasible]= ...
    directFIRhilbert_slb(@directFIRhilbert_socp_mmsePW, ...
                         hM0,(1:length(hM0)),[1 ((npoints/2)-napl+1)], ...
                         wa(war),Ad(war),Adu(war),Adl(war),Wa(war), ...
                         maxiter,tol,ctol,verbose);
catch
  feasible=false;
  err=lasterror();
  for e=1:length(err.stack)
    fprintf(stderr,"Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("%s\n", err.message);
end_try_catch
if feasible==false
  error("directFIRhilbert_slb failed! Filter not feasible!");
endif

% Amplitude and delay at local peaks
A0=freqz(h0,1,wa);
A=directFIRhilbertA(wa,hM1);
vAl=local_max(-A);
vAu=local_max(A);
wAS=unique([wa(vAl);wa(vAu);wa(na)]);
AS=directFIRhilbertA(wAS,hM1);
wAS=wAS(find(abs(AS)>0));
AS=AS(find(abs(AS)>0));
printf("hM1:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("hM1:AS=[ ");printf("%f ",20*log10(abs(AS)'));printf(" ] (dB)\n");

% Plot passband response
plot(wa*0.5/pi,20*log10(abs([A0 A Adl Adu])));
ylabel("Amplitude(dB)");
xlabel("Frequency");
axis([0 0.5 -0.1 0.04]);
grid("on");
strt=sprintf("Direct-form Hilbert FIR filter: \
fapl=%g,fapu=%g,dBap=%g,Wap=%g,Was=%g",fapl,fapu,dBap,Wap,Was);
title(strt);
legend("initial","PCLS","Adl","Adu");
legend("location","south");
legend("boxoff");
legend("left");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Save the filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"npoints=%d %% Frequency points across the band\n",npoints);
fprintf(fid,"fapl=%f %% Pass band amplitude response lower edge\n",fapl);
fprintf(fid,"fapu=%f %% Pass band amplitude response upper edge\n",fapu);
fprintf(fid,"dBap=%f %% Pass band amplitude response ripple\n",dBap);
fprintf(fid,"Wap=%f %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"Was=%f %% Stop band amplitude response weight\n",Was);
fclose(fid);

% Save results
print_polynomial(hM1,"hM1");
print_polynomial(hM1,"hM1",strcat(strf,"_hM1_coef.m"),"%12.8f");

% Done 
save directFIRhilbert_socp_mmsePW_test.mat ...
     tol ctol npoints fapl fapu dBap Wap Was hM0 hM1
toc
diary off
movefile directFIRhilbert_socp_mmsePW_test.diary.tmp ...
         directFIRhilbert_socp_mmsePW_test.diary;
