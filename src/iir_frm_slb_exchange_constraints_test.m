% iir_frm_slb_exchange_constraints_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("iir_frm_slb_exchange_constraints_test.diary");
delete("iir_frm_slb_exchange_constraints_test.diary.tmp");
diary iir_frm_slb_exchange_constraints_test.diary.tmp


maxiter=2000
tol=1e-5
verbose=true

%
% Initial filter is based on the filters found by tarczynski_frm_iir_test.m
%
x0.a = [   0.0167764585,   0.1088881694,   0.0000089591,  -0.2564808784, ... 
          -0.0120838451,   0.5742539304,   0.0029131547,  -0.0723385595, ... 
          -0.2450674010,   0.5110863294,   0.1522766320 ]';
x0.d = [   1.0000000000,   0.2022360090,   0.3940746880,   0.1200544657, ... 
          -0.0228300776,   0.0045729895,   0.0504127429,   0.0229445687, ... 
           0.0361252429,   0.0102913049,   0.0039434705 ]';
x0.aa = [  0.0031042717,  -0.0057984848,   0.0031002776,   0.0036966976, ... 
          -0.0055029586,  -0.0087160327,   0.0115457101,  -0.0008409106, ... 
          -0.0123904771,   0.0162950066,   0.0176897923,  -0.0333470258, ... 
           0.0058177661,   0.0349306948,  -0.0239908047,  -0.0200901198, ... 
           0.0606937591,  -0.0314210006,  -0.0780833560,   0.3181905273, ... 
           0.5669920509,   0.3181905273,  -0.0780833560,  -0.0314210006, ... 
           0.0606937591,  -0.0200901198,  -0.0239908047,   0.0349306948, ... 
           0.0058177661,  -0.0333470258,   0.0176897923,   0.0162950066, ... 
          -0.0123904771,  -0.0008409106,   0.0115457101,  -0.0087160327, ... 
          -0.0055029586,   0.0036966976,   0.0031002776,  -0.0057984848, ... 
           0.0031042717 ]';
x0.ac = [ -0.0095643857,  -0.0281807970,   0.0337747667,   0.0009139662, ... 
          -0.0306541128,  -0.0167508303,   0.0336338707,  -0.0077191127, ... 
          -0.0293545105,   0.0343483322,   0.0241930682,  -0.0587027497, ... 
           0.0187458649,   0.0508644059,  -0.0469972749,  -0.0212819548, ... 
           0.0863511416,  -0.0483624076,  -0.1187083736,   0.2881280944, ... 
           0.6378486542,   0.2881280944,  -0.1187083736,  -0.0483624076, ... 
           0.0863511416,  -0.0212819548,  -0.0469972749,   0.0508644059, ... 
           0.0187458649,  -0.0587027497,   0.0241930682,   0.0343483322, ... 
          -0.0293545105,  -0.0077191127,   0.0336338707,  -0.0167508303, ... 
          -0.0306541128,   0.0009139662,   0.0337747667,  -0.0281807970, ... 
          -0.0095643857 ]';

% Other filter is from iir_frm_socp_slb_test.diary
x1k = [  0.009169 ...
        -6.098492 -0.264780 ...
         1.773048  1.411134  1.021254  1.114667 ...
         2.643713  0.547748  0.622837  1.742980 ...
         0.576793  0.465207  0.753985  0.530270 0.433900 ...
         0.399086  2.917718  1.439408  1.720862 2.014019 ...
         0.664012  0.278531 -0.141400 -0.001274 ...
         0.061156 -0.050482 -0.000788  0.025613 ...
        -0.021387 -0.002041  0.019467 -0.016940 ...
        -0.001365  0.003679 -0.004217  0.001014 ...
         0.000470 -0.001680  0.000561  0.001395 ...
        -0.002100 ...
         0.629866  0.293180 -0.116694 -0.038880 ...
         0.105115 -0.045448 -0.046890  0.050742 ...
         0.004452 -0.044571  0.025201  0.019987 ...
        -0.033725 -0.012566  0.039259 -0.015530 ...
        -0.011864  0.021170 -0.004443 -0.014675 ...
         0.015420 ]';

%
% Filter specification
%
n=400;
tol=1e-6
constraints_tol=tol/10
maxiter=5000
verbose=true
Mmodel=9 % Model filter decimation
Dmodel=7 % Desired model filter passband delay
dmask=(max(length(x0.aa),length(x0.ac))-1)/2 % FIR masking filter delay
Tnominal=(Mmodel*Dmodel)+dmask;
fap=0.3 % Pass band edge
dBap=0.1 % Pass band amplitude ripple
Wap=1 % Pass band amplitude weight
tpr=1 % Peak-to-peak pass band delay ripple
Wtp=0.05 % Pass band delay weight
Wat=tol*tol; % Transition band weight
fas=0.31 % Stop band edge
dBas=40 % Stop band amplitude ripple
Was=50 % Stop band amplitude weight

%
% Convert x0 to vector form
%
[x0k,U,V,M,Q,na,nc]=iir_frm_struct_to_vec(x0);
if rem(na,2) == 1
  una=(na+1)/2;
else
  una=na/2;
endif
if rem(nc,2) == 1
  unc=(nc+1)/2;
else
  unc=nc/2;
endif
if length(x0k) ~= (1+U+V+M+Q+una+unc)
  error("Expected length(x0k) == (1+U+V+M+Q+una+unc");
endif
[xl,xu]=xConstraints(U,V,M,Q);

%
% Frequency vectors
%
w=(0:(n-1))'*pi/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;

% Amplitude constraints
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
Td=zeros(nap,1);
Tdu=(tpr/2)*ones(nap,1);
Tdl=-Tdu;
Wt=Wtp*ones(nap,1);

% Response
[Asqx0k,Tx0k]=iir_frm(w,x0k,U,V,M,Q,na,nc,Mmodel,Dmodel);
[Asqx1k,Tx1k]=iir_frm(w,x1k,U,V,M,Q,na,nc,Mmodel,Dmodel);

vRx0k=iir_frm_slb_update_constraints(Asqx0k,Asqdu,Asqdl,Wa,Tx0k,Tdu,Tdl,Wt,tol);
vSx1k=iir_frm_slb_update_constraints(Asqx1k,Asqdu,Asqdl,Wa,Tx1k,Tdu,Tdl,Wt,tol);

printf("vR before exchange constraints:\n");
iir_frm_slb_show_constraints(vRx0k,w,Asqx0k,Tx0k);

printf("vS before exchange constraints:\n");
iir_frm_slb_show_constraints(vSx1k,w,Asqx1k,Tx1k);

% Common strings
strM=sprintf("%%s:fap=%g,dBap=%g,fas=%g,dBas=%g,",fap,dBap,fas,dBas);
strM=strcat(strM, sprintf("Tnominal=%g,tpr=%g",Tnominal,tpr));
strd=sprintf("iir_frm_slb_exchange_constraints_test_%%s");

% Plot amplitude
f=w*0.5/pi;
subplot(211);
plot(f,[Asqx0k,Asqdu,Asqdl], ...
     f(vRx0k.al),Asqx0k(vRx0k.al),'*', ...
     f(vRx0k.au),Asqx0k(vRx0k.au),'+');
axis([0,0.5,0.8,1.1]);
strM0=sprintf(strM,"x0k");
title(strM0);
ylabel("Amplitude");
subplot(212);
plot(f,[Asqx0k,Asqdu,Asqdl], ...
     f(vRx0k.al),Asqx0k(vRx0k.al),'*', ...
     f(vRx0k.au),Asqx0k(vRx0k.au),'+');
axis([0,0.5,0,25e-5]);
ylabel("Amplitude");
xlabel("Frequency")
print(sprintf(strd,"x0kA"),"-dpdflatex");
close

% Plot group delay
plot(f(1:nap),[Tx0k(1:nap),Tdu,Tdl], ...
     f(vRx0k.tl),Tx0k(vRx0k.tl),'*', ...
     f(vRx0k.tu),Tx0k(vRx0k.tu),'+');
title(strM0);
ylabel("Group delay");
xlabel("Frequency")
print(sprintf(strd,"x0kT"),"-dpdflatex");
close

% Exchange constraints
[vRx1k,vSx1k,exchanged] = iir_frm_slb_exchange_constraints ...
                            (vSx1k,vRx0k,Asqx1k,Asqdu,Asqdl,Tx1k,Tdu,Tdl,tol)

printf("vR after exchange constraints:\n");
iir_frm_slb_show_constraints(vRx1k,w,Asqx1k,Tx1k);

printf("vS after exchange constraints:\n");
iir_frm_slb_show_constraints(vSx1k,w,Asqx1k,Tx1k);

% Plot amplitude
subplot(211);
plot(f,[Asqx0k,Asqx1k,Asqdu,Asqdl], ...
     f(vRx0k.al),Asqx0k(vRx0k.al),'*', f(vRx0k.au),Asqx0k(vRx0k.au),'+', ...
     f(vSx1k.al),Asqx0k(vSx1k.al),'*', f(vSx1k.au),Asqx0k(vSx1k.au),'+');
axis([0,fas,0.8,1.1]);
strM1=sprintf(strM,"x1k");
title(strM1);
ylabel("Amplitude");
subplot(212);
plot(f,[Asqx0k,Asqx1k,Asqdu,Asqdl], ...
     f(vRx0k.al),Asqx0k(vRx0k.al),'*', f(vRx0k.au),Asqx0k(vRx0k.au),'+', ...
     f(vSx1k.al),Asqx1k(vSx1k.al),'*', f(vSx1k.au),Asqx1k(vSx1k.au),'+');
axis([fap,0.5,0,5e-4]);
ylabel("Amplitude");
xlabel("Frequency")
print(sprintf(strd,"x1kA"),"-dpdflatex");
close

% Plot group delay
plot(f(1:nap),[Tx0k(1:nap),Tx1k(1:nap),Tdu,Tdl], ...
     f(vRx0k.tl),Tx0k(vRx0k.tl),'*', f(vRx0k.tu),Tx0k(vRx0k.tu),'+', ...
     f(vSx1k.tl),Tx1k(vSx1k.tl),'*', f(vSx1k.tu),Tx1k(vSx1k.tu),'+');
title(strM1);
ylabel("Group delay");
xlabel("Frequency")
print(sprintf(strd,"x1kT"),"-dpdflatex");
close

diary off
movefile iir_frm_slb_exchange_constraints_test.diary.tmp iir_frm_slb_exchange_constraints_test.diary;
