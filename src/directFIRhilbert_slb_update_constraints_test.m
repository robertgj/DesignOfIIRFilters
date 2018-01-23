% directFIRhilbert_slb_update_constraints_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("directFIRhilbert_slb_update_constraints_test.diary");
unlink("directFIRhilbert_slb_update_constraints_test.diary.tmp");
diary directFIRhilbert_slb_update_constraints_test.diary.tmp

format compact;

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

% Amplitude response
A0=directFIRhilbertA(wa,hM0);

% Update constraints
war=1:(npoints/2);
vS=directFIRhilbert_slb_update_constraints(A0(war),Adu(war),Adl(war),tol);
for [v,k]=vS
  printf("%s=[ ",k);printf("%d ",v);printf("]\n");
endfor
Al=directFIRhilbertA(wa(vS.al),hM0);
Au=directFIRhilbertA(wa(vS.au),hM0);

% Show constraints
directFIRhilbert_slb_show_constraints(vS,wa,A0);

% Plot amplitude
fa=wa(war)*0.5/pi;
plot(fa,20*log10(abs([A0(war) Adu(war) Adl(war)])),fa(vS.al), ...
     20*log10(abs(Al)),"x",fa(vS.au),20*log10(abs(Au)),"+");
axis([0 0.25 -0.1 0.1]);
strM=sprintf("FIR Hilbert: fapl=%g,fapu=%g,dBap=%g",fapl,fapu,dBap);
title(strM);
xlabel("Frequency");
ylabel("Amplitude(dB)");
legend("A0","Adu","Adl");
legend("boxoff")
legend("left")
legend("location","northeast")
print("directFIRhilbert_slb_update_constraints_test_hM0","-dpdflatex");
close

% Done
diary off
movefile directFIRhilbert_slb_update_constraints_test.diary.tmp ...
         directFIRhilbert_slb_update_constraints_test.diary;
