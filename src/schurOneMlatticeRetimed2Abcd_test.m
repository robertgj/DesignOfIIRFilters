% schurOneMlatticeRetimed2Abcd_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen
%
% Test cases for the retimed Schur one-multiplier lattice filter 

test_common;

unlink("schurOneMlatticeRetimed2Abcd_test.diary");
unlink("schurOneMlatticeRetimed2Abcd_test.diary.tmp");
diary schurOneMlatticeRetimed2Abcd_test.diary.tmp


% Make a quantised noise signal
nbits=10;
scale=2^(nbits-1);
delta=1;
nsamples=2^14;
u=reprand(nsamples,1)-0.5;
u=0.25*u/std(u);
u=round(u*scale);

% k empty
k=epsilon=p=c=[];
try
  [A,B,C,dd,Cap,ddap]=schurOneMlatticeRetimed2Abcd(k,epsilon,p,c);
catch
  printf("%s\n", lasterror().message);
end_try_catch

% Various 
tol=100*eps;
fc=0.05;
for Nk=1:9
  printf("\nTesting Nk=%d\n",Nk);
  [n,d]=butter(Nk,2*fc);
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);
  p1=ones(size(p));
  try
    [A,B,C,dd,Cap,ddap]=schurOneMlatticeRetimed2Abcd(k,epsilon,p,c);
  catch
    err=lasterror();
    for e=1:length(err.stack)
      printf("Called %s at line %d\n", ...
             err.stack(e).name,err.stack(e).line);
    endfor
    printf("%s\n", err.message);
  end_try_catch
  % Filter transfer function
  [N,D]=Abcd2tf(A,B,C,dd);
  % Test extra states
  if max(abs(N((Nk+2):end))) > tol
    error("max(abs(N((Nk+2):end))) > tol");
  endif 
  if max(abs(D((Nk+2):end))) > tol
    error("max(abs(D((Nk+2):end))) > tol");
  endif 
  % Trim extra states 
  N=N(1:(Nk+1));
  D=D(1:(Nk+1));
  if max(abs(N-n)) > tol
    error("max(abs(N-n)) > tol");
  endif 
  if max(abs(D-d)) > tol
    error("max(abs(D-d)) > tol");
  endif
  % All-pass filter transfer function
  [Nap,Dap]=Abcd2tf(A,B,Cap,ddap);
  % Test extra states
  if max(abs(Nap((Nk+2):end))) > tol
    error("max(abs(Nap((Nk+2):end))) > tol");
  endif 
  if max(abs(Dap((Nk+2):end))) > tol
    error("max(abs(Dap((Nk+2):end))) > tol");
  endif 
  % Trim extra states 
  Nap=Nap(1:(Nk+1));
  Dap=Dap(1:(Nk+1));
  if max(abs(flipud(Nap(:))-Dap(:))) > tol
    error("max(abs(flipud(Nap(:))-Dap(:))) > tol");
  endif 
  if max(abs(Dap-d)) > tol
    error("max(abs(Dap-d)) > tol");
  endif

  % Check noise gain
  [ngPipe,ngPipeap]=schurOneMlatticeRetimedNoiseGain(k,epsilon,p,c,"pipe");
  [K,W]=KW(A,B,C,dd);
  ng=sum(diag(K).*diag(W));
  if abs(ng-ngPipe) > 20*tol
    error("abs(ng-ngPipe) > 20*tol");
  endif
  [Kap,Wap]=KW(A,B,Cap,ddap);
  ngap=sum(diag(Kap).*diag(Wap));
  if abs(ngap-ngPipeap) > 40*tol
    error("abs(ngap-ngPipeap) > 40*tol");
  endif

  % Simulate noise gain
  kf = round(k*scale)/scale;
  cf = round(c*scale)/scale;
  [Af,Bf,Cf,ddf,Capf,ddapf]=schurOneMlattice2Abcd(kf,epsilon,p,cf);
  [Kf,Wf]=KW(Af,Bf,Cf,ddf);
  ngABCDf=sum(diag(Kf).*diag(Wf));
  [Kapf,Wapf]=KW(Af,Bf,Capf,ddapf);
  ngABCDapf=sum(diag(Kapf).*diag(Wapf));
  % Butterworth output
  [yABCD,xxABCD]=svf(Af,Bf,Cf,ddf,u,"none");
  [yABCDf,xxABCDf]=svf(Af,Bf,Cf,ddf,u,"round");
  est_varyABCDd=(1+(ngABCDf*delta*delta))/12
  varyABCDd=var(yABCD-yABCDf)
  % All-pass output
  [yABCDap,xxABCDap]=svf(Af,Bf,Capf,ddapf,u,"none");
  [yABCDapf,xxABCDapf]=svf(Af,Bf,Capf,ddapf,u,"round");
  est_varyABCDapd=(1+(ngABCDapf*delta*delta))/12
  varyABCDapd=var(yABCDap-yABCDapf)
  
  % Plot frequency response for the state-variable implementation
  nfpts=1000;
  nppts=(0:499);
  HABCDf=crossWelch(u,yABCDf,nfpts);
  HABCDapf=crossWelch(u,yABCDapf,nfpts);
  subplot(111);
  plot(nppts/nfpts,20*log10(abs(HABCDf)), ...
       nppts/nfpts,20*log10(abs(HABCDapf)));
  axis([0 0.5 -80 5])
  grid("on");
  xlabel("Frequency")
  ylabel("Amplitude(dB)")
  print(sprintf("schurOneMlatticeRetimed2Abcd_test_response_%d",Nk),
        "-dpdflatex");
  npass=1+(nfpts*fc);
  printf("At fc HABCDf=%f (dB)\n",20*log10(abs(HABCDf(npass))));
endfor

% Done
diary off
movefile schurOneMlatticeRetimed2Abcd_test.diary.tmp ...
         schurOneMlatticeRetimed2Abcd_test.diary;
