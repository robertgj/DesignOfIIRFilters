% schurOneMAPlattice_frm_hilbert_slb_update_constraints_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurOneMAPlattice_frm_hilbert_slb_update_constraints_test.diary");
unlink...
  ("schurOneMAPlattice_frm_hilbert_slb_update_constraints_test.diary.tmp");
diary schurOneMAPlattice_frm_hilbert_slb_update_constraints_test.diary.tmp

format compact;

maxiter=2000
tol=5e-6
verbose=true

%
% Filter from tarczynski_frm_hilbert_test.m
%
r1 = [   1.0000000000,  -0.2601535016,  -0.0585423666,  -0.0138388212, ... 
        -0.0058161583,   0.0009139294 ]';
u1 = [  -0.0087030511,   0.0141455165,  -0.0185956688,   0.0261090002, ... 
        -0.0319048413,   0.0363169770,  -0.0436616121,   0.0472945986, ... 
         0.4468293109 ]';
v1 = [   0.0003832266,   0.0017197905,  -0.0046597683,   0.0135556644, ... 
        -0.0252428888,   0.0484350620,  -0.0964367347,   0.3154148817 ]';
rm1=ones(size(r1));
rm1(2:2:end)=-1;
[k1,epsilon1,p1,~] = tf2schurOneMlattice(flipud(r1).*rm1,r1.*rm1);
um1=ones(size(u1));
um1(2:2:end)=-1;
u1=u1.*um1;
vm1=ones(size(v1));
vm1(2:2:end)=-1;
v1=v1.*vm1;

%
% Filter specification
%
Mmodel=7; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
mr=length(r1)-1; % Model filter order
dmask=2*length(v1); % FIR masking filter delay
fap=0.02 % Amplitude pass band edge
fas=0.48 % Amplitude stop band edge
dBap=0.05 % Pass band amplitude ripple
Wap=1 % Pass band amplitude weight
ftp=0.05 % Delay pass band edge
fts=0.45 % Delay stop band edge
tp=(Mmodel*Dmodel)+dmask % Nominal FRM filter group delay
tpr=0.4 % Peak-to-peak pass band delay ripple
Wtp=0.2 % Pass band delay weight
fpp=0.05 % Phase pass band edge
fps=0.45 % Phase stop band edge
pp=-pi/2 % Nominal passband phase (adjusted for delay)
ppr=0.002*pi % Peak-to-peak pass band phase ripple
Wpp=0.2 % Pass band phase weight

%
% Frequency vectors
%
n=800;
w=(0:(n-1))'*pi/n;

% Amplitude constraints
nap=floor(fap*n/0.5)+1;
nas=ceil(fas*n/0.5)+1;
wa=w(nap:nas);
Asqd=ones(size(wa));
Asqdu=Asqd;
Asqdl=10^(-dBap/10)*ones(size(wa));
Wa=Wap*ones(size(wa));

% Group delay constraints
ntp=floor(ftp*n/0.5)+1;
nts=ceil(fts*n/0.5)+1;
wt=w(ntp:nts);
Td=zeros(size(wt));
Tdu=(tpr/2)*ones(size(wt));
Tdl=-Tdu;
Wt=Wtp*ones(size(wt));

% Phase constraints
npp=floor(fpp*n/0.5)+1;
nps=ceil(fps*n/0.5)+1;
wp=w(npp:nps);
Pd=pp*ones(size(wp));
Pdu=pp+(ppr/2)*ones(size(wp));
Pdl=pp-(ppr/2)*ones(size(wp));
Wp=Wpp*ones(size(wp));

% Common strings
strd=sprintf("schurOneMAPlattice_frm_hilbert_slb_update_constraints_test_%%s");

% Calculate frequency response
Asq1=schurOneMAPlattice_frm_hilbertAsq(wa,k1,epsilon1,p1,u1,v1,Mmodel,Dmodel);
T1=schurOneMAPlattice_frm_hilbertT(wt,k1,epsilon1,p1,u1,v1,Mmodel,Dmodel);
P1=schurOneMAPlattice_frm_hilbertP(wp,k1,epsilon1,p1,u1,v1,Mmodel,Dmodel);

% Update constraints
vS=schurOneMAPlattice_frm_hilbert_slb_update_constraints ...
     (Asq1,Asqdu,Asqdl,Wa,T1,Tdu,Tdl,Wt,P1,Pdu,Pdl,Wp,tol);
for [vv,mm]=vS
  printf("%s=[ ",mm);printf("%d ",vv);printf("]\n");
endfor
Asql=schurOneMAPlattice_frm_hilbertAsq(wa(vS.al), ...
                                       k1,epsilon1,p1,u1,v1,Mmodel,Dmodel);
Asqu=schurOneMAPlattice_frm_hilbertAsq(wa(vS.au), ...
                                       k1,epsilon1,p1,u1,v1,Mmodel,Dmodel);
Tl=schurOneMAPlattice_frm_hilbertT(wt(vS.tl), ...
                                   k1,epsilon1,p1,u1,v1,Mmodel,Dmodel);
Tu=schurOneMAPlattice_frm_hilbertT(wt(vS.tu), ...
                                   k1,epsilon1,p1,u1,v1,Mmodel,Dmodel);
Pl=schurOneMAPlattice_frm_hilbertP(wp(vS.pl), ...
                                   k1,epsilon1,p1,u1,v1,Mmodel,Dmodel);
Pu=schurOneMAPlattice_frm_hilbertP(wp(vS.pu), ...
                                   k1,epsilon1,p1,u1,v1,Mmodel,Dmodel);

% Show constraints
schurOneMAPlattice_frm_hilbert_slb_show_constraints(vS,wa,Asq1,wt,T1,wp,P1);

% Plot amplitude
fa=wa*0.5/pi;
plot(fa,Asq1,fa,Asqdu,":",fa,Asqdl,"-.",fa(vS.al),Asql,"x",fa(vS.au),Asqu,"+");
%axis([0 0.5 0.95 1.05]);
strMa=sprintf("Asq(k1):fap=%g,fas=%g,dBap=%g,Wap=%g,",fap,fas,dBap,Wap);
title(strMa);
ylabel("Amplitude");
xlabel("Frequency")
grid("on");
print(sprintf(strd,"Asq1"),"-dpdflatex");
close

% Plot zero-phase group delay
ft=wt*0.5/pi;
plot(ft,T1,ft,Tdu,":",ft,Tdl,"-.",ft(vS.tl),Tl,"x",ft(vS.tu),Tu,"+");
%axis([0 0.5 -(tpr*2) +(tpr*2)]);
strMt=sprintf("T(k1):ftp=%g,fts=%g,tp=%d,tpr=%g,Wtp=%g",ftp,fts,tp,tpr,Wtp);
title(strMt);
ylabel("Zero-phase group delay");
xlabel("Frequency")
grid("on");
print(sprintf(strd,"T1"),"-dpdflatex");
close

% Plot phase
fp=wp*0.5/pi;
plot(fp,P1/pi, ...
     fp,Pdu/pi,":",fp,Pdl/pi,"-.",fp(vS.pl),Pl/pi,"x",fp(vS.pu),Pu/pi,"+");
%axis([0 0.5 [pp-(ppr*2) pp+(ppr*2)]/pi]);
strMp=sprintf("P(k1):fpp=%g,fps=%g,ppr=%g*pi,Wpp=%g,",fpp,fps,ppr/pi,Wpp);
title(strMp);
ylabel("Phase(rad./pi)\n(Adjusted for delay)");
xlabel("Frequency")
grid("on");
print(sprintf(strd,"P1"),"-dpdflatex");
close

% Done
diary off
movefile schurOneMAPlattice_frm_hilbert_slb_update_constraints_test.diary.tmp ...
       schurOneMAPlattice_frm_hilbert_slb_update_constraints_test.diary;
