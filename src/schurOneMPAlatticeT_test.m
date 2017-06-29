% schurOneMPAlatticeT_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurOneMPAlatticeT_test.diary");
unlink("schurOneMPAlatticeT_test.diary.tmp");
diary schurOneMPAlatticeT_test.diary.tmp

clear schurOneMlattice2H
tic;
verbose=true;

% Low pass filter
norder=5;
fpass=0.125;
[n,d]=butter(norder,2*fpass);
nplot=1024;
npass=floor(nplot*fpass/0.5);
[h,wplot]=freqz(n,d,nplot);
t=grpdelay(n,d,nplot);
% Alternative calculation
[Aap1,Aap2]=tf2pa(n,d);
tAap1=grpdelay(fliplr(Aap1),Aap1,nplot);
tAap2=grpdelay(fliplr(Aap2),Aap2,nplot);
tAap12=(tAap1+tAap2)/2;

% Lattice decomposition
[A1k,A1epsilon,A1p,A1c] = tf2schurOneMlattice(fliplr(Aap1),Aap1);
[A2k,A2epsilon,A2p,A2c] = tf2schurOneMlattice(fliplr(Aap2),Aap2);

% Find the group delay
T=schurOneMPAlatticeT(wplot,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p);

% Check the group-delay response
if max(abs(t(1:npass)-T(1:npass))) > 72*eps
  error("max(abs(t(1:npass)-T(1:npass))) > 72*eps");
endif

% Find the gradients of T
[T,gradT]=schurOneMPAlatticeT(wplot,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p);

% Check the gradients of the group delay response wrt A1k
del=1e-6;
delk=zeros(size(A1k));
delk(1)=del/2;
diff_Tk=zeros(npass,size(A1k));
for l=1:length(A1k)
  TkPdel2=...
    schurOneMPAlatticeT(wplot(1:npass),A1k+delk,A1epsilon,A1p,A2k,A2epsilon,A2p);
  TkMdel2=...
    schurOneMPAlatticeT(wplot(1:npass),A1k-delk,A1epsilon,A1p,A2k,A2epsilon,A2p);
  delk=shift(delk,1);
  diff_Tk(:,l)=(TkPdel2-TkMdel2)/del;
endfor
if max(max(abs(diff_Tk-gradT(1:npass,1:length(A1k))))) > del/259.23
  error("max(max(abs(diff_Tk-gradT(1:npass,1:length(A1k))))) > del/259.23");
endif

% Check the gradients of the group delay response wrt A2k
del=1e-6;
delk=zeros(size(A2k));
delk(1)=del/2;
diff_Tk=zeros(npass,size(A2k));
for l=1:length(A2k)
  TkPdel2=...
    schurOneMPAlatticeT(wplot(1:npass),A1k,A1epsilon,A1p,A2k+delk,A2epsilon,A2p);
  TkMdel2=...
    schurOneMPAlatticeT(wplot(1:npass),A1k,A1epsilon,A1p,A2k-delk,A2epsilon,A2p);
  delk=shift(delk,1);
  diff_Tk(:,l)=(TkPdel2-TkMdel2)/del;
endfor
if max(max(abs(diff_Tk-gradT(1:npass,(length(A1k)+1):end)))) > del/132.85
  error("max(max(abs(diff_Tk-gradT(npass,(length(A1k)+1):end)))) > del/132.85");
endif

% Find diagHessT
[T,gradT,diagHessT]=...
  schurOneMPAlatticeT(wplot,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p);

% Check the Hessian of the group delay response wrt A1k
del=1e-6;
delk=zeros(size(A1k));
delk(1)=del/2;
diff_gradTk=zeros(npass,length(A1k));
for l=1:length(A1k)
  [TkPdel2,gradTkPdel2]=...
    schurOneMPAlatticeT(wplot(1:npass),A1k+delk,A1epsilon,A1p,A2k,A2epsilon,A2p);
  [TkMdel2,gradTkMdel2]=...
    schurOneMPAlatticeT(wplot(1:npass),A1k-delk,A1epsilon,A1p,A2k,A2epsilon,A2p);
  delk=shift(delk,1);
  diff_gradTk(:,l)=(gradTkPdel2(:,l)-gradTkMdel2(:,l))/del;
endfor
if max(max(abs(diff_gradTk-diagHessT(1:npass,1:length(A1k))))) > del/44.514
  error("max(max(abs(diff_gradTk-diagHessT(...))))>del/44.514");
endif

% Check the Hessian of the group delay response wrt A2k
del=1e-6;
delk=zeros(size(A2k));
delk(1)=del/2;
diff_gradTk=zeros(npass,size(A2k));
for l=1:length(A2k)
  [TkPdel2,gradTkPdel2]=...
    schurOneMPAlatticeT(wplot(1:npass),A1k,A1epsilon,A1p,A2k+delk,A2epsilon,A2p);
  [TkMdel2,gradTkMdel2]=...
    schurOneMPAlatticeT(wplot(1:npass),A1k,A1epsilon,A1p,A2k-delk,A2epsilon,A2p);
  delk=shift(delk,1);
  diff_gradTk(:,l)=(gradTkPdel2(:,length(A1k)+l)-...
                    gradTkMdel2(:,length(A1k)+l))/del;
endfor
if max(max(abs(diff_gradTk-diagHessT(1:npass,(length(A1k)+1):end)))) > del/5.149
  error("max(max(abs(diff_gradTk-diagHessT(...)>del/5.149");
endif

% Done
toc;
diary off
movefile schurOneMPAlatticeT_test.diary.tmp schurOneMPAlatticeT_test.diary;
