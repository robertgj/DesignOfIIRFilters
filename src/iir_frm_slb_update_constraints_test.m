% iir_frm_slb_update_constraints_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("iir_frm_slb_update_constraints_test.diary");
unlink("iir_frm_slb_update_constraints_test.diary.tmp");
diary iir_frm_slb_update_constraints_test.diary.tmp

format compact;

verbose=true
tol=1e-5

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
[Asqk,Tk]=iir_frm(w,x0k,U,V,M,Q,na,nc,Mmodel,Dmodel);

% Constraints
vS=iir_frm_slb_update_constraints(Asqk,Asqdu,Asqdl,Wa,Tk,Tdu,Tdl,Wt,tol);
for [v,k]=vS
  printf("%s=[ ",k);printf("%d ",v);printf("]\n");
endfor

% Show constraints
iir_frm_slb_show_constraints(vS,w,Asqk,Tk);

% Common strings
strM=sprintf("%%s:fap=%g,dBap=%g,fas=%g,dBas=%g,",fap,dBap,fas,dBas);
strM=strcat(strM, sprintf("Tnominal=%g,tpr=%g",Tnominal,tpr));
strd=sprintf("iir_frm_slb_update_constraints_test_%%s");

% Plot amplitude
f=w*0.5/pi;
subplot(211);
plot(f,Asqk,f,Asqdu,f,Asqdl,f(vS.al),Asqk(vS.al),"x",f(vS.au),Asqk(vS.au),"+");
axis([0 fas 0.8 1.1]);
strM0=sprintf(strM,"x0k");
title(strM0);
ylabel("Amplitude");
subplot(212);
plot(f,Asqk,f,Asqdu,f,Asqdl,f(vS.al),Asqk(vS.al),"x",f(vS.au),Asqk(vS.au),"+");
axis([fap 0.5 0 1e-3]);
ylabel("Amplitude");
xlabel("Frequency")
print(sprintf(strd,"x0A"),"-dpdflatex");
close

% Plot group delay
subplot(111);
plot(f(1:nap),Tk(1:nap),f(1:nap),Tdu,":",f(1:nap),Tdl,"-.", ...
     f(vS.tl),Tk(vS.tl),"x",f(vS.tu),Tk(vS.tu),"+");
axis([0 fap -(tpr*2) +(tpr*2)]);
title(strM0);
ylabel("Group delay");
xlabel("Frequency")
print(sprintf(strd,"x0T"),"-dpdflatex");
close

%
% Done
%
diary off
movefile iir_frm_slb_update_constraints_test.diary.tmp iir_frm_slb_update_constraints_test.diary;
