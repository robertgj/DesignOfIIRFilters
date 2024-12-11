% schurOneMPAlatticeDoublyPipelinedAsq_svf_test.m
% Copyright (C) 2024 Robert G. Jenssen

test_common;

strf="schurOneMPAlatticeDoublyPipelinedAsq_svf_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=false;

% Check Asq with svf
for difference=[false,true]
  % Prototype filter
  norder=9;
  fpass=0.125;
  [n,d]=butter(norder,2*fpass);
  % Convert to one-multiplier parallel-allpass lattice
  [Aap1,Aap2]=tf2pa(n,d);
  [A1k,~,~,~] = tf2schurOneMlattice(flipud(Aap1(:)),Aap1(:));
  [A2k,~,~,~] = tf2schurOneMlattice(flipud(Aap2(:)),Aap2(:));
  % Convert to state-variable form
  if difference
    [n,d]=butter(norder,2*fpass,"high");
    mm=-1;
  else
    [n,d]=butter(norder,2*fpass);
    mm=1;
  endif
  [A1,B1,C1,D1]=schurOneMAPlatticeDoublyPipelined2Abcd(A1k);
  [A2,B2,C2,D2]=schurOneMAPlatticeDoublyPipelined2Abcd(A2k);
  A=[A1,zeros(rows(A1),columns(A2));zeros(rows(A2),columns(A1)),A2];
  B=[B1;B2];
  C=[C1,mm*C2]/2;
  D=[D1+(mm*D2)]/2;
  % Simulate the state-variable filter
  nfilt=2^16;
  crossWelchN=16;
  wfilt=(0:((nfilt)-1))'*pi/(nfilt);
  u=reprand(2*crossWelchN*nfilt,1);
  y=svf(A,B,C,D,u);
  % Check response
  Hsvf=crossWelch(u,y,2*nfilt);
  Hsvf=Hsvf(:);
  Asq=schurOneMPAlatticeDoublyPipelinedAsq(wfilt,A1k,A2k,difference);
  if max(abs((abs(Hsvf).^2)-Asq)) > 1e-3
    error("max(abs((abs(Hsvf).^2)-Asq))(%g)>1e-3",max(abs((abs(Hsvf).^2)-Asq)));
  endif
  H2=freqz(n,d,2*wfilt);
  if max(abs((abs(H2).^2)-Asq)) > 1e4*eps
    error("max(abs((abs(H2).^2)-Asq))(%g*eps)>1e4*eps",
          max(abs((abs(H2).^2)-Asq))/eps);
  endif
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
