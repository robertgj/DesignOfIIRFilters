% schurOneMPAlatticeDoublyPipelinedAntiAliased2Abcd_test.m
% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="schurOneMPAlatticeDoublyPipelinedAntiAliased2Abcd_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tol=2e-14;

% Design a doubly-pipelined anti-aliased low-pass filter
fap=0.1;fas=0.2;dBap=1;dBas=40;NB=3;tol=2e-14;

for NA=3:2:7,

  tol_10_NA=tol*(10^NA);

  % Doubly-pipelined filter
  [nA,dA]=cheby2(NA,dBas,2*2*fas);
  nAR=[nA(1),kron(nA(2:end),[0,1])];
  dAR=[dA(1),kron(dA(2:end),[0,1])];
  [A1,A2]=tf2pa(nA,dA);
  A1k=schurdecomp(A1);
  A2k=schurdecomp(A2);
  
  % Anti-aliasing filter
  [nB,dB]=cheby2(NB,dBas,2*(0.5-fas));
  [B1,B2]=tf2pa(nB,dB);
  B1k=schurdecomp(B1);
  B2k=schurdecomp(B2);
  
  for difference=[true,false],
    
    [AAB,BAB,CAB,DAB]=schurOneMPAlatticeDoublyPipelinedAntiAliased2Abcd ...
                        (A1k,A2k,difference,B1k,B2k);

    [nAB,dAB]=Abcd2tf(AAB,BAB,CAB,DAB);
    if any(nAB([1,2,end-1,end])>eps),
      error("any(nAB([1,2,end-1,end])>eps)");
    endif
    if any(dAB((end-3):end)>eps),
      error("any(dAB([end-3,end-2,end-1,end])>eps)");
    endif
    nAB=nAB(3:(end-2));
    dAB=dAB(1:(end-4));
    
    if difference
      % tf2pa() fails for high pass filters!?!?
      A1R=[A1(1),kron(A1(2:end),[0,1])];
      A2R=[A2(1),kron(A2(2:end),[0,1])];
      nA12R=(conv(fliplr(A1R),A2R)-conv(A1R,fliplr(A2R)))/2;
      if max(abs(conv(nA12R,nB)-nAB)) > tol_10_NA
        error("max(abs(conv(nA12R,nB)-nAB)) > tol_10_NA");
      endif
      dA12R=conv(A1R,A2R);
      if max(abs(conv(dA12R,dB)-dAB)) > tol_10_NA
        error("max(abs(conv(dA12R,dB)-dAB)) > tol_10_NA");
      endif
    else
      if max(abs(conv(nAR,nB)-nAB)) > tol_10_NA
        error("max(abs(conv(nAR,nB)-nAB)) > tol_10_NA");
      endif
      if max(abs(conv(dAR,dB)-dAB)) > tol_10_NA
        error("max(abs(conv(dAR,dB)-dAB)) > tol_10_NA");
      endif
    endif
    
    endfor
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
