% schurOneMPAlatticeP_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurOneMPAlatticeP_test.diary");
unlink("schurOneMPAlatticeP_test.diary.tmp");
diary schurOneMPAlatticeP_test.diary.tmp

tic;
verbose=true;

% Low pass filter
if 1
  norder=5;
  nplot=1024;
  fpass=0.125;
  npass=floor(nplot*fpass/0.5);
  [n,d]=butter(norder,2*fpass);
  [h,wplot]=freqz(n,d,nplot);
  p=unwrap(arg(h));
  [Aap1,Aap2]=tf2pa(n,d);
  Aap1=Aap1(:);
  Aap2=Aap2(:);
else
  Aap1 = [  1.0000000000,   0.3931432341,  -0.2660133321,  -0.0850275861, ... 
           -0.2707651069,  -0.0298153197,   0.1338823243,  -0.0589362474, ... 
            0.1650490792,   0.0296371262,  -0.1113859180,   0.0372881323 ]';
  Aap2 = [  1.0000000000,  -0.1344939785,  -0.0918734630,   0.4461033862, ... 
           -0.1115261080,   0.1180340147,   0.0396352218,  -0.2006006436, ... 
            0.2105512466,  -0.0838522576,  -0.1001537312,   0.1080994566, ... 
           -0.0610732672 ]';
  nplot=1024;
  fpass=0.175;
  npass=floor(nplot*fpass/0.5);
  [hAap1,wplot]=freqz(flipud(Aap1),Aap1,nplot);
  hAap2=freqz(flipud(Aap2),Aap2,nplot);
  h=(hAap1+hAap2)/2;
  p=unwrap(arg(h));
endif

% Lattice decomposition
[A1k,A1epsilon,A1p,~] = tf2schurOneMlattice(flipud(Aap1),Aap1);
[A2k,A2epsilon,A2p,~] = tf2schurOneMlattice(flipud(Aap2),Aap2);

% Find the phase
P=schurOneMPAlatticeP(wplot,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p);

% Check the phase response
if max(abs(p(1:npass*2)-P(1:npass*2))) > 106*eps
  error("max(abs(p(1:npass*2)-P(1:npass*2))) > 106*eps");
endif

% Find the gradients of P
[P,gradP]=schurOneMPAlatticeP(wplot,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p);

% Check the gradients of the phase response wrt A1k
del=1e-6;
delk=zeros(size(A1k));
delk(1)=del/2;
diff_Pk=zeros(npass,size(A1k));
for l=1:length(A1k)
  PkPdel2=...
    schurOneMPAlatticeP(wplot(1:npass),A1k+delk,A1epsilon,A1p,A2k,A2epsilon,A2p);
  PkMdel2=...
    schurOneMPAlatticeP(wplot(1:npass),A1k-delk,A1epsilon,A1p,A2k,A2epsilon,A2p);
  delk=shift(delk,1);
  diff_Pk(:,l)=(PkPdel2-PkMdel2)/del;
endfor
if max(max(abs(diff_Pk-gradP(1:npass,1:length(A1k))))) > del/1713.92
  error("max(max(abs(diff_Pk-gradP(1:npass,1:length(A1k))))) > del/1713.92");
endif

% Check the gradients of the phase response wrt A2k
del=1e-6;
delk=zeros(size(A2k));
delk(1)=del/2;
diff_Pk=zeros(npass,size(A2k));
for l=1:length(A2k)
  PkPdel2=...
    schurOneMPAlatticeP(wplot(1:npass),A1k,A1epsilon,A1p,A2k+delk,A2epsilon,A2p);
  PkMdel2=...
    schurOneMPAlatticeP(wplot(1:npass),A1k,A1epsilon,A1p,A2k-delk,A2epsilon,A2p);
  delk=shift(delk,1);
  diff_Pk(:,l)=(PkPdel2-PkMdel2)/del;
endfor
if max(max(abs(diff_Pk-gradP(1:npass,(length(A1k)+1):end)))) > del/640.92
  error("max(max(abs(diff_Pk-gradP(npass,(length(A1k)+1):end)))) > del/640.92");
endif

% Find diagHessP
[P,gradP,diagHessP]=...
  schurOneMPAlatticeP(wplot,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p);

% Check the Hessian of the phase response wrt A1k
del=1e-6;
delk=zeros(size(A1k));
delk(1)=del/2;
diff_gradPk=zeros(npass,length(A1k));
for l=1:length(A1k)
  [PkPdel2,gradPkPdel2]=...
    schurOneMPAlatticeP(wplot(1:npass),A1k+delk,A1epsilon,A1p,A2k,A2epsilon,A2p);
  [PkMdel2,gradPkMdel2]=...
    schurOneMPAlatticeP(wplot(1:npass),A1k-delk,A1epsilon,A1p,A2k,A2epsilon,A2p);
  delk=shift(delk,1);
  diff_gradPk(:,l)=(gradPkPdel2(:,l)-gradPkMdel2(:,l))/del;
endfor
if max(max(abs(diff_gradPk-diagHessP(1:npass,1:length(A1k))))) > del/410.21
  error("max(max(abs(diff_gradPk-diagHessP(...))))>del/410.21");
endif

% Check the Hessian of the phase response wrt A2k
del=1e-6;
delk=zeros(size(A2k));
delk(1)=del/2;
diff_gradPk=zeros(npass,size(A2k));
for l=1:length(A2k)
  [PkPdel2,gradPkPdel2]=...
    schurOneMPAlatticeP(wplot(1:npass),A1k,A1epsilon,A1p,A2k+delk,A2epsilon,A2p);
  [PkMdel2,gradPkMdel2]=...
    schurOneMPAlatticeP(wplot(1:npass),A1k,A1epsilon,A1p,A2k-delk,A2epsilon,A2p);
  delk=shift(delk,1);
  diff_gradPk(:,l)=(gradPkPdel2(:,length(A1k)+l)-...
                    gradPkMdel2(:,length(A1k)+l))/del;
endfor
if max(max(abs(diff_gradPk-diagHessP(1:npass,(length(A1k)+1):end)))) > del/84.767
  error("max(max(abs(diff_gradPk-diagHessP(...)>del/84.767");
endif

% Done
toc;
diary off
movefile schurOneMPAlatticeP_test.diary.tmp schurOneMPAlatticeP_test.diary;
