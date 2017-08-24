% schurOneMPAlatticeEsq_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurOneMPAlatticeEsq_test.diary");
unlink("schurOneMPAlatticeEsq_test.diary.tmp");
diary schurOneMPAlatticeEsq_test.diary.tmp

tic;
verbose=true;

% Low pass filter from parallel_allpass_socp_slb_flat_delay_test.m 
Da1 = [   1.0000000000,   0.3931432341,  -0.2660133321,  -0.0850275861, ... 
         -0.2707651069,  -0.0298153197,   0.1338823243,  -0.0589362474, ... 
          0.1650490792,   0.0296371262,  -0.1113859180,   0.0372881323 ]';
Db1 = [   1.0000000000,  -0.1344939785,  -0.0918734630,   0.4461033862, ... 
         -0.1115261080,   0.1180340147,   0.0396352218,  -0.2006006436, ... 
          0.2105512466,  -0.0838522576,  -0.1001537312,   0.1080994566, ... 
         -0.0610732672 ]';
Dab1 = [   1.0000000000,   0.2586492556,  -0.4107621927,   0.3607335610, ... 
          -0.1710334226,  -0.0300684328,   0.2405442669,  -0.4019267583, ... 
           0.2886788963,   0.0928616471,  -0.3580821837,   0.2718123207, ... 
          -0.0374493775,  -0.0939561603,   0.1157815704,  -0.0939661732, ... 
           0.0336391381,   0.0384186168,  -0.0644954956,   0.0356638996, ... 
           0.0011526919,  -0.0175853389,   0.0108335288,  -0.0022773081 ]';
Nab1 = [  -0.0118925675,  -0.0161560163,  -0.0001083932,   0.0205704164, ... 
           0.0369335724,   0.0211196767,  -0.0280717678,  -0.0596562038, ... 
          -0.0358505121,   0.0676811446,   0.2182340832,   0.3207798419, ... 
           0.3207798419,   0.2182340832,   0.0676811446,  -0.0358505121, ... 
          -0.0596562038,  -0.0280717678,   0.0211196767,   0.0369335724, ... 
           0.0205704164,  -0.0001083932,  -0.0161560163,  -0.0118925675 ]';
ma=11; % Allpass model filter A denominator order
mb=12; % Allpass model filter B denominator order
fap=0.15; % Pass band amplitude response edge
Wap=1; % Pass band amplitude response weight
fas=0.2; % Stop band amplitude response edge
Was=750; % Stop band amplitude response weight
ftp=0.175; % Pass band group delay response edge
td=(ma+mb)/2; % Pass band nominal group delay
Wtp=1; % Pass band group delay response weight
Wpp=0.1; % Pass band phase response weight

% Desired squared magnitude response
nplot=1000;
nap=ceil(nplot*fap/0.5)+1;
nas=floor(nplot*fas/0.5)+1;
wa=(0:(nplot-1))'*pi/nplot;
Asqd=[ones(nap,1);zeros(nplot-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(nplot-nas+1,1)];

% Desired pass-band group delay response
ntp=ceil(nplot*ftp/0.5)+1;
wt=wa(1:ntp);
Td=td*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Desired pass-band phase response
npp=ntp;
wp=wt;
Pd=-td*wp;
Wp=Wpp*ones(npp,1);

% Lattice decomposition
[A1k,A1epsilon,A1p,~] = tf2schurOneMlattice(flipud(Da1),Da1);
[A2k,A2epsilon,A2p,~] = tf2schurOneMlattice(flipud(Db1),Db1);

% Find the squared-error
Esq=schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Check the squared-error response
[Hab1,wplot]=freqz(Nab1,Dab1,nplot);
Pab1=unwrap(arg(Hab1));
Tab1=grpdelay(Nab1,Dab1,wplot);
Asqab1=abs(Hab1).^2;
AsqErr=Wa.*((Asqab1-Asqd).^2);
AsqErrSum=sum(diff(wa).*(AsqErr(1:(length(wa)-1))+AsqErr(2:end)))/2;
TErr=Wt.*((Tab1(1:ntp)-Td).^2);  
TErrSum=sum(diff(wt).*(TErr(1:(ntp-1))+TErr(2:end)))/2;
PErr=Wp.*((Pab1(1:npp)-Pd).^2);  
PErrSum=sum(diff(wp).*(PErr(1:(npp-1))+PErr(2:end)))/2;
if abs(AsqErrSum+TErrSum+PErrSum-Esq) > 46895*eps
  error("abs(AsqErrSum+TErrSum+PErrSum-Esq) > 46895*eps");
endif

% Find the gradients of Esq
[Esq,gradEsq]=schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                    wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Check the gradients of the group delay response wrt A1k
del=1e-6;
NA1k=length(A1k);
delk=zeros(size(A1k));
delk(1)=del/2;
diff_Esqk=zeros(size(A1k));
for l=1:NA1k
  EsqkPdel2=schurOneMPAlatticeEsq(A1k+delk,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                  wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  EsqkMdel2=schurOneMPAlatticeEsq(A1k-delk,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                  wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  delk=shift(delk,1);
  diff_Esqk(l)=(EsqkPdel2-EsqkMdel2)/del;
endfor
if max(max(abs(diff_Esqk-gradEsq(1:NA1k)))) > del/16097
  error("max(max(abs(diff_Esqk-gradEsq(1 to NA1k)))) > del/16097");
endif

% Check the gradients of the group delay response wrt A2k
del=1e-6;
NA2k=length(A2k);
delk=zeros(size(A2k));
delk(1)=del/2;
diff_Esqk=zeros(size(A2k));
for l=1:NA2k
  EsqkPdel2=schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k+delk,A2epsilon,A2p, ...
                                  wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  EsqkMdel2=schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k-delk,A2epsilon,A2p, ...
                                  wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  delk=shift(delk,1);
  diff_Esqk(l)=(EsqkPdel2-EsqkMdel2)/del;
endfor
if max(max(abs(diff_Esqk-gradEsq((NA1k+1):end)))) > del/6385
  error("max(max(abs(diff_Esqk-gradEsq((NA1k+1) to end)))) > del/6385");
endif

% Find diagHessEsq
[Esq,gradEsq,diagHessEsq]=...
  schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                        wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Check the Hessian of the group delay response wrt A1k
del=1e-6;
delk=zeros(size(A1k));
delk(1)=del/2;
diff_gradEsqk=zeros(size(A1k));
for l=1:NA1k
  [EsqkPdel2,gradEsqkPdel2]=...
    schurOneMPAlatticeEsq(A1k+delk,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                  wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  [EsqkMdel2,gradEsqkMdel2]= ...
    schurOneMPAlatticeEsq(A1k-delk,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  delk=shift(delk,1);
  diff_gradEsqk(l)=(gradEsqkPdel2(l)-gradEsqkMdel2(l))/del;
endfor
if max(max(abs(diff_gradEsqk-diagHessEsq(1:NA1k)))) > del/104
  error("max(max(abs(diff_gradEsqk-diagHessEsq(1 to NA1k))))>del/104");
endif

% Check the Hessian of the group delay response wrt A2k
del=1e-6;
delk=zeros(size(A2k));
delk(1)=del/2;
diff_gradEsqk=zeros(size(A2k));
for l=1:NA2k
  [EsqkPdel2,gradEsqkPdel2]=...
    schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k+delk,A2epsilon,A2p, ...
                          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  [EsqkMdel2,gradEsqkMdel2]=...
    schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k-delk,A2epsilon,A2p, ...
                          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  
  delk=shift(delk,1);
  diff_gradEsqk(l)=(gradEsqkPdel2(NA1k+l)-gradEsqkMdel2(NA1k+l))/del;
endfor
if max(max(abs(diff_gradEsqk-diagHessEsq((NA1k+1):end)))) > del/89.105
  error("max(max(abs(diff_gradEsqk-diagHessEsq((NA1k+1) to end)>del/89.105");
endif

% Done
toc;
diary off
movefile schurOneMPAlatticeEsq_test.diary.tmp schurOneMPAlatticeEsq_test.diary;
