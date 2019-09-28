% directFIRhilbert_slb_exchange_constraints_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("directFIRhilbert_slb_exchange_constraints_test.diary");
unlink("directFIRhilbert_slb_exchange_constraints_test.diary.tmp");
diary directFIRhilbert_slb_exchange_constraints_test.diary.tmp


tol=1e-4;

%
% Initialise
%
maxiter=500;
verbose=true;
tol=1e-4;

% Hilbert filter frequency specification
M=8;fapl=0.05;fapu=0.5-fapl;dBap=0.05;Wap=1;Was=0;;
npoints=1000;
wa=(0:((npoints)-1))'*pi/(npoints);
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
Ad=ones(npoints,1);
Adu=ones(npoints,1);
Adl=[zeros(napl-1,1); ...
     (10^(-dBap/20))*ones(napu-napl+1,1); ...
     zeros(npoints-napu,1)];
Wa=[Was*ones(napl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Was*ones(npoints-napu,1)];
% Sanity check
nch=[1 napl-1 napl napl+1 napu-1 napu napu+1 npoints];
printf("fa=[ ");printf("%d ",wa(nch)*0.5/pi);printf("]\n");
printf("Adl=[ ");printf("%d ",Adl(nch));printf("]\n");
printf("Wa=[ ");printf("%d ",Wa(nch));printf("]\n");

% Make a Hilbert filter
n4M1=((-2*M)+1):2:((2*M)-1)';
h0=zeros((4*M)+1,1);
h0(n4M1+(2*M)+1)=2*(sin(pi*n4M1/2).^2)./(pi*n4M1);
h0=h0.*hamming((4*M)+1);
hM0=h0(((2*M)+2):2:(end-1));
hM_active=1:length(hM0);

% Common strings
strd=sprintf("directFIRhilbert_slb_exchange_constraints_test_%%s");
strM=sprintf("FIR Hilbert %%s : fapl=%g,fapu=%g,dBap=%g",fapl,fapu,dBap);

% Amplitude response
A0=directFIRhilbertA(wa,hM0);

% Optimise
war=1:(npoints/2);
vR=directFIRhilbert_slb_update_constraints(A0(war),Adu(war),Adl(war),tol);
[hM1,socp_iter,func_iter,feasible]=directFIRhilbert_mmsePW ...
  (vR,hM0,hM_active,[napl,(npoints/2)], ...
   wa(war),Ad(war),Adu(war),Adl(war),Wa(war),maxiter,tol,verbose);
if feasible==false
  error("hM1 not feasible");
endif

% Update constraints
A1=directFIRhilbertA(wa,hM1);
vS=directFIRhilbert_slb_update_constraints(A1(war),Adu(war),Adl(war),tol);

% Show constraints before exchange
printf("vR before exchange constraints:\n");
directFIRhilbert_slb_show_constraints(vR,wa,A1);
printf("vS before exchange constraints:\n");
directFIRhilbert_slb_show_constraints(vS,wa,A1);

% Plot amplitude
fa=wa(war)*0.5/pi;
plot(fa,20*log10(abs([A0(war),A1(war),Adu(war),Adl(war)])), ...
     fa(vR.al),20*log10(abs(A0(vR.al))),'*', ...
     fa(vR.au),20*log10(abs(A0(vR.au))),'+', ...
     fa(vS.al),20*log10(abs(A1(vS.al))),'*', ...
     fa(vS.au),20*log10(abs(A1(vS.au))),'+');
axis([0,0.25,-0.1,0.1]);
strM1=sprintf(strM,"before exchange");
title(strM1);
ylabel("Amplitude");
xlabel("Frequency");
legend("A0","A1","Adu","Adl")
legend("location","northeast");
legend("boxoff");
legend("left");
print(sprintf(strd,"vR_A0"),"-dpdflatex");
close

% Exchange constraints
[vR,vS,exchanged]= ...
  directFIRhilbert_slb_exchange_constraints(vS,vR,A1,Adu,Adl,tol);
printf("vR after exchange constraints:\n");
directFIRhilbert_slb_show_constraints(vR,wa,A1);
printf("vS after exchange constraints:\n");
directFIRhilbert_slb_show_constraints(vS,wa,A1);

% Plot amplitude
plot(fa,20*log10(abs([A0(war),A1(war),Adu(war),Adl(war)])), ...
     fa(vR.al),20*log10(abs(A0(vR.al))),'*', ...
     fa(vR.au),20*log10(abs(A0(vR.au))),'+', ...
     fa(vR.al),20*log10(abs(A1(vR.al))),'*', ...
     fa(vR.au),20*log10(abs(A1(vR.au))),'+', ...
     fa(vS.al),20*log10(abs(A1(vS.al))),'*', ...
     fa(vS.au),20*log10(abs(A1(vS.au))),'+');
axis([0,0.25,-0.1,0.1]);
strM1=sprintf(strM,"after exchange");
title(strM1);
ylabel("Amplitude");
xlabel("Frequency");
legend("A0","A1","Adu","Adl")
legend("location","northeast");
legend("boxoff");
legend("left");
print(sprintf(strd,"vR_A0_vS_A1"),"-dpdflatex");
close

% Done
diary off
movefile directFIRhilbert_slb_exchange_constraints_test.diary.tmp ...
         directFIRhilbert_slb_exchange_constraints_test.diary;
