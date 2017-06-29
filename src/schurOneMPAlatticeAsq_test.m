% schurOneMPAlatticeAsq_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurOneMPAlatticeAsq_test.diary");
unlink("schurOneMPAlatticeAsq_test.diary.tmp");
diary schurOneMPAlatticeAsq_test.diary.tmp

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
% Alternative calculation
[Aap1,Aap2]=tf2pa(n,d);
hAap1=freqz(fliplr(Aap1),Aap1,nplot);
hAap2=freqz(fliplr(Aap2),Aap2,nplot);
hAap12=(hAap1+hAap2)/2;

% Lattice decomposition
[A1k,A1epsilon,A1p,A1c] = tf2schurOneMlattice(fliplr(Aap1),Aap1);
[A2k,A2epsilon,A2p,A2c] = tf2schurOneMlattice(fliplr(Aap2),Aap2);

% Find the complex response
[Asq]=schurOneMPAlatticeAsq(wplot,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p);

% Check the magnitude-squared response
if max(abs((abs(h).^2)-Asq)) > 139*eps
  error("max(abs((abs(h).^2)-Asq)) > 139*eps");
endif

% Find the gradients of the complex response
[Asq,gradAsq]=schurOneMPAlatticeAsq(wplot,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p);

% Check the gradients of the squared-magnitude response wrt A1k
del=1e-6;
delk=zeros(size(A1k));
delk(1)=del/2;
diff_Asqk=zeros(npass,size(A1k));
for l=1:length(A1k)
  AsqkPdel2=schurOneMPAlatticeAsq(wplot(1:npass),...
                                  A1k+delk,A1epsilon,A1p,A2k,A2epsilon,A2p);
  AsqkMdel2=schurOneMPAlatticeAsq(wplot(1:npass),...
                                  A1k-delk,A1epsilon,A1p,A2k,A2epsilon,A2p);
  delk=shift(delk,1);
  diff_Asqk(:,l)=(AsqkPdel2-AsqkMdel2)/del;
endfor
if max(max(abs(diff_Asqk-gradAsq(1:npass,1:length(A1k))))) > del/1152.8
  error("max(max(abs(diff_Asqk-gradAsq(1:npass,1:length(A1k))))) > del/1152.8");
endif

% Check the gradients of the squared-magnitude response wrt A2k
del=1e-6;
delk=zeros(size(A2k));
delk(1)=del/2;
diff_Asqk=zeros(npass,size(A2k));
for l=1:length(A2k)
  AsqkPdel2=schurOneMPAlatticeAsq(wplot(1:npass),A1k,A1epsilon,A1p, ...
                                  A2k+delk,A2epsilon,A2p);
  AsqkMdel2=schurOneMPAlatticeAsq(wplot(1:npass),A1k,A1epsilon,A1p, ...
                                  A2k-delk,A2epsilon,A2p);
  delk=shift(delk,1);
  diff_Asqk(:,l)=(AsqkPdel2-AsqkMdel2)/del;
endfor
if max(max(abs(diff_Asqk-gradAsq(1:npass,(length(A1k)+1):end)))) > del/518.95
  error("max(max(abs(diff_Asqk-\
gradAsq(1:npass,(length(A1k)+1):end)))) > del/518.95");
endif

% Find the diagonal of the Hessian of the complex response
[Asq,gradAsq,diagHessAsq]=...
  schurOneMPAlatticeAsq(wplot,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p);

% Check the diagonal of the Hessian of the squared-magnitude response wrt A1k
del=1e-6;
delk=zeros(size(A1k));
delk(1)=del/2;
diff_gradAsqk=zeros(npass,size(A1k));
for l=1:length(A1k)
  [AsqkPdel2,gradAsqkPdel2]=...
    schurOneMPAlatticeAsq(wplot(1:npass), ...
                          A1k+delk,A1epsilon,A1p,A2k,A2epsilon,A2p);
  [AsqkMdel2,gradAsqkMdel2]=...
    schurOneMPAlatticeAsq(wplot(1:npass), ...
                          A1k-delk,A1epsilon,A1p,A2k,A2epsilon,A2p);
  delk=shift(delk,1);
  diff_gradAsqk(:,l)=(gradAsqkPdel2(:,l)-gradAsqkMdel2(:,l))/del;
endfor
if max(max(abs(diff_gradAsqk-diagHessAsq(1:npass,1:length(A1k))))) > del/288.46
  error("max(max(abs(diff_gradAsqk-\
diagHessAsq(1:npass,1:length(A1k))))) > del/288.46");
endif

% Check the diagonal of the Hessian of the squared-magnitude response wrt A2k
del=1e-6;
delk=zeros(size(A2k));
delk(1)=del/2;
diff_gradAsqk=zeros(npass,size(A2k));
for l=1:length(A2k)
  [AsqkPdel2,gradAsqkPdel2]=...
    schurOneMPAlatticeAsq(wplot(1:npass), ...
                          A1k,A1epsilon,A1p,A2k+delk,A2epsilon,A2p);
  [AsqkMdel2,gradAsqkMdel2]=...
    schurOneMPAlatticeAsq(wplot(1:npass), ...
                          A1k,A1epsilon,A1p,A2k-delk,A2epsilon,A2p);
  delk=shift(delk,1);
  diff_gradAsqk(:,l)=...
    (gradAsqkPdel2(:,length(A1k)+l)-gradAsqkMdel2(:,length(A1k)+l))/del;
endfor
if max(max(abs(diff_gradAsqk-diagHessAsq(1:npass,(length(A1k)+1):end)))) ...
   > del/38.64
  error("max(max(abs(diff_gradAsqk-\
diagHessAsq(1:npass,(length(A1k)+1):end)))) > del/38.64");
endif

% Done
toc;
diary off
movefile schurOneMPAlatticeAsq_test.diary.tmp schurOneMPAlatticeAsq_test.diary;
