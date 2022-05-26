% johanssonOneMlatticeAzp_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

delete("johanssonOneMlatticeAzp_test.diary");
delete("johanssonOneMlatticeAzp_test.diary.tmp");
diary johanssonOneMlatticeAzp_test.diary.tmp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Band-stop filter from johansson_cascade_allpass_bandstop_test.m
fM = [  -0.0314881200,  -0.0000085599,   0.2814857078,   0.5000169443 ];
a0 = [   1.0000000000,  -0.5650802796,   1.6504647259,  -0.4790659039, ... 
         0.7284633026 ];
a1 = [   1.0000000000,  -0.2594839587,   0.6383172372 ];


% Convert all-pass filter transfer functions to Schur 1-multiplier lattice
[k0,epsilon0,~,~]=tf2schurOneMlattice(fliplr(a0),a0);
[k1,epsilon1,~,~]=tf2schurOneMlattice(fliplr(a1),a1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check the zero-phase response
nf=500;
wa=(0:nf)'*pi/nf;
Fr=johansson_cascade_allpassAzp(wa,fM,a0,a1);
Azp=johanssonOneMlatticeAzp(wa,fM,k0,epsilon0,k1,epsilon1);
if max(abs(Fr-Azp)) > 20*eps
  error("max(abs(Fr-Azp))(%g*eps) > 20*eps", max(abs(Fr-Azp))/eps);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate gradients
[Azp,gradAzp]=johanssonOneMlatticeAzp(wa,fM,k0,epsilon0,k1,epsilon1);

% Check the gradients of the zero-phase response wrt fM
RfM=1:length(fM);
del=1e-6;
delf=zeros(size(fM));
delf(1)=del/2;
diff_Af=zeros(length(wa),length(fM));
for l=1:length(fM)
  AfPdel2=johanssonOneMlatticeAzp(wa,fM+delf,k0,epsilon0,k1,epsilon1);
  AfMdel2=johanssonOneMlatticeAzp(wa,fM-delf,k0,epsilon0,k1,epsilon1);
  delf=circshift(delf,1);
  diff_Af(:,l)=(AfPdel2-AfMdel2)/del;
endfor
if max(max(abs(diff_Af-gradAzp(:,RfM)))) > del/3600
  error("max(max(abs(diff_Af-gradAzp(:,RfM)))) > del/3600");
endif

% Check the gradients of the zero-phase response wrt k0
Rk0=(1+length(fM)):(length(fM)+length(k0));
del=1e-6;
delk=zeros(size(k0));
delk(1)=del/2;
diff_Ak0=zeros(length(wa),length(k0));
for l=1:length(k0)
  Ak0Pdel2=johanssonOneMlatticeAzp(wa,fM,k0+delk,epsilon0,k1,epsilon1);
  Ak0Mdel2=johanssonOneMlatticeAzp(wa,fM,k0-delk,epsilon0,k1,epsilon1);
  delk=circshift(delk,1);
  diff_Ak0(:,l)=(Ak0Pdel2-Ak0Mdel2)/del;
endfor
if max(max(abs(diff_Ak0-gradAzp(:,Rk0)))) > del/100
  error("max(max(abs(diff_Ak0-gradAzp(:,Rk0)))) > del/100");
endif

% Check the gradients of the zero-phase response wrt k1
Rk1=(1+length(fM)+length(k0)):(length(fM)+length(k0)+length(k1));
del=1e-6;
delk=zeros(size(k1));
delk(1)=del/2;
diff_Ak1=zeros(length(wa),length(k1));
for l=1:length(k1)
  Ak1Pdel2=johanssonOneMlatticeAzp(wa,fM,k0,epsilon0,k1+delk,epsilon1);
  Ak1Mdel2=johanssonOneMlatticeAzp(wa,fM,k0,epsilon0,k1-delk,epsilon1);
  delk=circshift(delk,1);
  diff_Ak1(:,l)=(Ak1Pdel2-Ak1Mdel2)/del;
endfor
if max(max(abs(diff_Ak1-gradAzp(:,Rk1)))) > del/900
  error("max(max(abs(diff_Ak1-gradAzp(:,Rk1)))) > del/900");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate diagonal of Hessian
[Azp,gradAzp,diagHessAzp]=johanssonOneMlatticeAzp(wa,fM,k0,epsilon0,k1,epsilon1);

% Check the diagonal of the Hessian of the phase response wrt fM
RfM=1:length(fM);
del=1e-6;
delf=zeros(size(fM));
delf(1)=del/2;
diff_gradAf=zeros(length(wa),length(fM));
for l=1:length(fM)
  [~,gradAfPdel2]=johanssonOneMlatticeAzp(wa,fM+delf,k0,epsilon0,k1,epsilon1);
  [~,gradAfMdel2]=johanssonOneMlatticeAzp(wa,fM-delf,k0,epsilon0,k1,epsilon1);
  delf=circshift(delf,1);
  diff_gradAf(:,l)=(gradAfPdel2(:,l)-gradAfMdel2(:,l))/del;
endfor
if max(max(abs(diff_gradAf-diagHessAzp(:,RfM)))) > eps
  error("max(max(abs(diff_gradAf-diagHessAzp(:,RfM)))) > eps");
endif

% Check the diagonal of the Hessian of the zero-phase response wrt k0
Rk0=(length(fM)+1):(length(fM)+length(k0));
del=1e-6;
delk=zeros(size(k0));
delk(1)=del/2;
diff_gradAk0=zeros(length(wa),length(k0));
for l=1:length(k0)
  [~,gradAk0Pdel2]=johanssonOneMlatticeAzp(wa,fM,k0+delk,epsilon0,k1,epsilon1);
  [~,gradAk0Mdel2]=johanssonOneMlatticeAzp(wa,fM,k0-delk,epsilon0,k1,epsilon1);
  delk=circshift(delk,1);
  diff_gradAk0(:,l)=(gradAk0Pdel2(:,Rk0(l))-gradAk0Mdel2(:,Rk0(l)))/del;
endfor
if max(max(abs(diff_gradAk0-diagHessAzp(:,Rk0)))) > del/2
  error("max(max(abs(diff_gradAk0-diagHessAzp(:,Rk0))))(%g) > del/2", ...
        max(max(abs(diff_gradAk0-diagHessAzp(:,Rk0)))));
endif

% Check the diagonal of the Hessian of the zero-phase response wrt k1
Rk1=(length(fM)+length(k0)+1):(length(fM)+length(k0)+length(k1));
del=1e-6;
delk=zeros(size(k1));
delk(1)=del/2;
diff_gradAk1=zeros(length(wa),length(k1));
for l=1:length(k1)
  [~,gradAk1Pdel2]=johanssonOneMlatticeAzp(wa,fM,k0,epsilon0,k1+delk,epsilon1);
  [~,gradAk1Mdel2]=johanssonOneMlatticeAzp(wa,fM,k0,epsilon0,k1-delk,epsilon1);
  delk=circshift(delk,1);
  diff_gradAk1(:,l)=(gradAk1Pdel2(:,Rk1(l))-gradAk1Mdel2(:,Rk1(l)))/del;
endfor
if max(max(abs(diff_gradAk1-diagHessAzp(:,Rk1)))) > del/100
  error("max(max(abs(diff_gradAk1-diagHessAzp(:,Rk1))))(%g) > del/100", ...
        max(max(abs(diff_gradAk1-diagHessAzp(:,Rk1)))));
endif

% Done
diary off
movefile johanssonOneMlatticeAzp_test.diary.tmp ...
         johanssonOneMlatticeAzp_test.diary;
