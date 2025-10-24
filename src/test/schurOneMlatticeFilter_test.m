% schurOneMlatticeFilter_test.m
% Copyright (C) 2022-2025 Robert G. Jenssen
%
% Test cases for the Schur one-multiplier lattice filter 

test_common;

strf="schurOneMlatticeFilter_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% Various 
tol=100*eps;
fc=0.05;
for Nk=1:9
  printf("\nTesting Nk=%d\n",Nk);

  % Filter
  [n,d]=butter(Nk,2*fc);
  [k,epsilon,p,c,S]=tf2schurOneMlattice(n,d);
  [A,B,C,dd,Cap,ddap]=schurOneMlattice2Abcd(k,epsilon,p,c);

  % Make a quantised noise signal
  nbits=10;
  scale=2^(nbits-1);
  delta=1;
  nsamples=2^14;
  n60=p2n60(d);
  u=reprand(n60+nsamples,1)-0.5;
  u=0.25*u/std(u);
  u=round(u*scale);

  % Simulated noise gain
  ng=schurOneMlatticeNoiseGain(S,k,epsilon,p,c,d,n,zeros(size(d)))
  ngap=schurOneMlatticeNoiseGain(S,k,epsilon,p,c,zeros(size(d)),fliplr(d),d)
  [ngSchur,ngSchurap]=schurOneMlatticeRetimedNoiseGain(k,epsilon,p,c,"Schur")
  [ngABCD,ngABCDap]=schurOneMlatticeRetimedNoiseGain(k,epsilon,p,c,"ABCD")
  
  % Butterworth filter output
  [yap y xx]=schurOneMlatticeFilter(k,epsilon,p,c,u,"none");
  [yapf yf xxf]=schurOneMlatticeFilter(k,epsilon,p,c,u,"round");
  [yABCD,xxABCD]=svf(A,B,C,dd,u,"none");
  [yABCDf,xxABCDf]=svf(A,B,C,dd,u,"round");
  [yABCDap,xxABCDap]=svf(A,B,Cap,ddap,u,"none");
  [yABCDapf,xxABCDapf]=svf(A,B,Cap,ddap,u,"round");

  % Remove initial transient
  Rn60=(n60+1):length(u);
  u=u(Rn60);
  y=y(Rn60);
  yf=yf(Rn60);
  yap=yap(Rn60);
  yapf=yapf(Rn60);
  yABCD=yABCD(Rn60);
  yABCDf=yABCDf(Rn60);
  yABCDap=yABCDap(Rn60);
  yABCDapf=yABCDapf(Rn60);

  % Sanity check
  if max(abs(y-yABCD)) > 1e4*eps
    error("max(abs(y-yABCD))(%g*eps) > 1e4*eps",max(abs(y-yABCD))/eps)
  endif
  if max(abs(yap-yABCDap)) > 1e4*eps
    error("max(abs(yap-yABCDap))(%g*eps) > 1e4*eps",max(abs(yap-yABCDap))/eps)
  endif
  
  % Butterworth variance
  est_varyd=(1+(ng*delta*delta))/12
  est_varySchurd=(1+(ngSchur*delta*delta))/12
  varyd=var(y-yf)
  est_varydABCD=(1+(ngABCD*delta*delta))/12
  varyABCDd=var(yABCD-yABCDf)

  % All-pass variance
  est_varyapd=(1+(ngap*delta*delta))/12
  est_varySchurapd=(1+(ngSchurap*delta*delta))/12
  varyapd=var(yap-yapf)
  est_varyABCDapd=(1+(ngABCDap*delta*delta))/12
  varyABCDapd=var(yABCDap-yABCDapf)
  
  % Check state variable std. deviation
  stdxx=std(xx(Rn60,:))
  stdxxf=std(xxf(Rn60,:))
  stdxxABCD=std(xxABCD(Rn60,:))
  stdxxABCDf=std(xxABCDf(Rn60,:))
  stdxxABCDap=std(xxABCDap(Rn60,:))
  stdxxABCDapf=std(xxABCDapf(Rn60,:))
  
  % Plot frequency response for the Schur lattice implementation
  nfpts=1000;
  nppts=(0:((nfpts/2)-1));
  fnppts=nppts*0.5/nppts(end);
  Hnd=freqz(n,d,2*pi*fnppts);
  H=crossWelch(u,y,nfpts);
  Hap=crossWelch(u,yap,nfpts);
  Hf=crossWelch(u,yf,nfpts);
  Hapf=crossWelch(u,yapf,nfpts);
  HABCD=crossWelch(u,yABCD,nfpts);
  HABCDap=crossWelch(u,yABCDap,nfpts); 
  HABCDf=crossWelch(u,yABCDf,nfpts);
  HABCDapf=crossWelch(u,yABCDapf,nfpts);
  plot(nppts/nfpts,20*log10(abs(Hf)), ...
       nppts/nfpts,20*log10(abs(Hapf)), ...
       nppts/nfpts,20*log10(abs(Hnd)));
  axis([0 0.5 -80 5])
  grid("on");
  xlabel("Frequency")
  ylabel("Amplitude(dB)")
zticks([]);
  print(sprintf("%s_response_%d",strf,Nk),"-dpdflatex");
  close
  npass=1+(nfpts*fc);
  printf("At fc Hf=%f (dB)\n",20*log10(abs(Hf(npass))));

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
