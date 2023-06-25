% schurOneMlatticePipelinedFilter_test.m
% Copyright (C) 2023 Robert G. Jenssen
%
% Test cases for the pipelined Schur one-multiplier lattice filter 

test_common;

strf="schurOneMlatticePipelinedFilter_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% Various 
tol=100*eps;
fc=0.05;
delta=1;

for Nk=1:9
  printf("\nTesting Nk=%d\n",Nk);

  % Filter
  [n,d]=butter(Nk,2*fc);
  [k,epsilon,~,c,S]=tf2schurOneMlattice(n,d);

  % Calculate noise gain and state scaling
  [A,B,C,D,Cap,Dap]=schurOneMlatticePipelined2Abcd(k,epsilon,c);
  [ng,At,Bt,Ct,D,T]=Abcd2ng(A,B,C,D,delta);
  ng
  ngap=Abcd2ng(A,B,Cap,Dap,delta)
  Ctap=Cap*T;
  px=diag(T);
  
  % Make a quantised noise signal
  nbits=10;
  scale=2^(nbits-1);
  nsamples=2^14;
  n60=p2n60(d);
  u=reprand(n60+nsamples,1)-0.5;
  u=0.25*u/std(u);
  u=round(u*scale);

  % Butterworth filter output
  % (schurOneMlatticePipelinedFilter() and svf() outputs should be identical)
  if 1
    [yap y xx]=schurOneMlatticePipelinedFilter(k,epsilon,px,c,u,"none");
    [yapf yf xxf]=schurOneMlatticePipelinedFilter(k,epsilon,px,c,u,"round");
  else
    [y,xx]=svf(At,Bt,Ct,D,u,"none");
    [yf,xxf]=svf(At,Bt,Ct,D,u,"round");
    yap=svf(At,Bt,Ctap,Dap,u,"none");
    yapf=svf(At,Bt,Ctap,Dap,u,"round");
  endif

  % Remove initial transient
  Rn60=(n60+1):length(u);
  u=u(Rn60);
  xx=xx(Rn60,:);
  xxf=xxf(Rn60,:);
  y=y(Rn60);
  yf=yf(Rn60);
  yap=yap(Rn60);
  yapf=yapf(Rn60);
  
  % Butterworth variance
  est_varyd=(1+(ng*delta*delta))/12
  varyd=var(y-yf)

  % All-pass variance
  est_varyapd=(1+(ngap*delta*delta))/12
  varyapd=var(yap-yapf)
  
  % Check state variable std. deviation
  stdxx=std(xx)
  stdxxf=std(xxf)
  
  % Plot frequency response for the Schur lattice implementation
  nfpts=1000;
  nppts=(0:499);
  fnppts=nppts*0.5/nppts(end);
  Hnd=freqz(n,d,2*pi*fnppts);
  Hf=crossWelch(u,yf,nfpts);
  Hapf=crossWelch(u,yapf,nfpts);
  plot(nppts/nfpts,20*log10(abs(Hf)), ...
       nppts/nfpts,20*log10(abs(Hapf)), ...
       nppts/nfpts,20*log10(abs(Hnd)));
  axis([0 0.5 -80 5])
  grid("on");
  xlabel("Frequency")
  ylabel("Amplitude(dB)")
  print(sprintf("%s_response_%d",strf,Nk),"-dpdflatex");
  close
  npass=1+(nfpts*fc);
  printf("At fc Hf=%f (dB)\n",20*log10(abs(Hf(npass))));

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
