% schurOneMlatticeFilter_test.m
% Copyright (C) 2022-2026 Robert G. Jenssen
%
% Test cases for estimating the noise gain of a Schur one-multiplier lattice
% filter:
%  1. With schurOneMlatticeNoiseGain()
%  2. With schurOneMlatticeNoiseGain() and p is a power-of-2 state scaling
%  3. With schurOneMlatticeRetimedNoiseGain(...,"Schur");
%     (Assumes the all-pass output is calculated with truncation at each stage.)
%  4. With schurOneMlatticeRetimedNoiseGain(...,"ABCD");
%     (Assumes both outputs are calculated in a wide accumulator.)
%  5. With a scaled direct form implementation

test_common;

strf="schurOneMlatticeFilter_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% Various 
delta=1;
nbits=10;
nscale=2^(nbits-1);
nsamples=2^16;
tol=1e-8;

for Nk=1:9
  printf("\nTesting Nk=%d\n",Nk);

  % Filter
  fap=0.2;dBap=1;dBas=40;
  [n,d]=ellip(Nk,dBap,dBas,2*fap);
  % fap=0.2;
  % [n,d]=butter(Nk,2*fap);
  zd=zeros(size(d));
  fd=fliplr(d);

  % Direct-form scaled state variable implementation
  [Ad,Bd,Cd,Dd]=tf2Abcd(n,d);
  [KABCDd,WABCDd]=KW(Ad,Bd,Cd,Dd);
  TABCDd=diag(delta*sqrt(diag(KABCDd)));
  invTABCDd=inv(TABCDd);
  Ads=invTABCDd*Ad*TABCDd;
  Bds=invTABCDd*Bd;
  Cds=Cd*TABCDd;
  Dds=Dd;
  [KABCDds,WABCDds]=KW(Ads,Bds,Cds,Dds);
  ngABCDds=sum(diag(KABCDds).*diag(WABCDds))
  KABCDds=invTABCDd*KABCDd*(invTABCDd');
  WABCDds=(TABCDd')*WABCDd*TABCDd;
  if abs(ngABCDds-sum(diag(KABCDds).*diag(WABCDds)))/ngABCDds > tol
    error("abs(ngABCDds-sum(diag(KABCDds).*diag(WABCDds)))/ngABCDds > tol");
  endif
  
  % One-multiplier Schur lattice filter implementation
  [k,epsilon,p,c,S]=tf2schurOneMlattice(n,d);
  pd=p*delta;
  [A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,epsilon,pd,c);
  
  % Simulated noise gain for the one-multiplier Schur lattice
  ng=schurOneMlatticeNoiseGain(S,k,epsilon,pd,c,d,n,zd)
  ngap=schurOneMlatticeNoiseGain(S,k,epsilon,pd,c,zd,fd,d)
  [ngSchur,ngSchurap]=schurOneMlatticeRetimedNoiseGain(k,epsilon,pd,c,"Schur")
  [ngABCD,ngABCDap]=schurOneMlatticeRetimedNoiseGain(k,epsilon,pd,c,"ABCD")

  % Scale the one-multiplier Schur lattice by powers-of-2
  if 1
    pow2p=2.^fix(log2(p*nscale))/nscale;
  elseif 0
    pow2p=zeros(size(p));
    plt1=find(p<1);
    pge1=find(p>1);
    pow2p(plt1)=2.^(sign(log2(p(plt1))).*ceil(abs(log2(p(plt1)))));
    pow2p(pge1)=(2.^(sign(log2(p(pge1))).*floor(abs(log2(p(pge1))))));
  else
    pow2p=2.^fix(log2(p));
  endif
  pow2pd=pow2p*delta
  ng2=schurOneMlatticeNoiseGain(S,k,epsilon,pow2pd,c,d,n,zd)
  ng2ap=schurOneMlatticeNoiseGain(S,k,epsilon,pow2pd,c,zd,fd,d)
  [ngABCD2,ngABCD2ap]=schurOneMlatticeRetimedNoiseGain(k,epsilon,pow2pd,c,"ABCD")

  % Alternate scaling of the one-multiplier Schur lattice by powers-of-2
  pow2palt=2.^(round(log2(p)));
  pow2paltd=pow2palt/delta
  ng2alt=schurOneMlatticeNoiseGain(S,k,epsilon,pow2paltd,c,d,n,zd)
  ng2altap=schurOneMlatticeNoiseGain(S,k,epsilon,pow2paltd,c,zd,fd,d)
  [ngABCD2alt,ngABCD2altap]= ...
    schurOneMlatticeRetimedNoiseGain(k,epsilon,pow2paltd,c,"ABCD")

  % State variable implementations of the one-multiplier Schur lattice
  [A2,B2,C2,D2,C2ap,D2ap]=schurOneMlattice2Abcd(k,epsilon,ones(size(p)),c);
  T2=diag(pow2p);
  A2=inv(T2)*A2*T2;
  B2=inv(T2)*B2;
  C2=C2*T2;
  C2ap=C2ap*T2;
  [K2,W2]=KW(A2,B2,C2,D2);
  ng2sv=sum(diag(K2).*diag(W2))
  [K2ap,W2ap]=KW(A2,B2,C2ap,D2ap);
  ng2svap=sum(diag(K2ap).*diag(W2ap))   

  [A2alt,B2alt,C2alt,D2alt,C2altap,D2altap]= ...
    schurOneMlattice2Abcd(k,epsilon,ones(size(p)),c);
  T2alt=diag(pow2palt);
  A2alt=inv(T2alt)*A2alt*T2alt;
  B2alt=inv(T2alt)*B2alt;
  C2alt=C2alt*T2alt;
  C2altap=C2altap*T2alt;
  [K2alt,W2alt]=KW(A2alt,B2alt,C2alt,D2alt);
  ng2svalt=sum(diag(K2alt).*diag(W2alt))
  [K2altap,W2altap]=KW(A2alt,B2alt,C2altap,D2altap);
  ng2svaltap=sum(diag(K2altap).*diag(W2altap))   

  %
  % Simulate the filters
  %
  
  % Make a quantised noise signal
  nscale=2^(nbits-1);
  n60=p2n60(d);
  u=reprand(n60+nsamples,1)-0.5;
  u=0.25*u/std(u);
  u=round(u*nscale);

  % Filter output
  [yap y xx]=schurOneMlatticeFilter(k,epsilon,pd,c,u,"none");
  [yapf yf xxf]=schurOneMlatticeFilter(k,epsilon,pd,c,u,"round");

  [y2ap y2 xx2]=schurOneMlatticeFilter(k,epsilon,pow2pd,c,u,"none");
  [y2apf y2f xx2f]=schurOneMlatticeFilter(k,epsilon,pow2pd,c,u,"round");

  [y2altap y2alt xx2alt]=schurOneMlatticeFilter(k,epsilon,pow2paltd,c,u,"none");
  [y2altapf y2altf xx2altf]= ...
    schurOneMlatticeFilter(k,epsilon,pow2paltd,c,u,"round");

  [y2sv,xx2sv]=svf(A2,B2,C2,D2,u,"none");
  [y2svf,xx2svf]=svf(A2,B2,C2,D2,u,"round");
  y2svap=svf(A2,B2,C2ap,D2ap,u,"none");
  y2svapf=svf(A2,B2,C2ap,D2ap,u,"round");

  [y2svalt,xx2svalt]=svf(A2alt,B2alt,C2alt,D2alt,u,"none");
  [y2svaltf,xx2svaltf]=svf(A2alt,B2alt,C2alt,D2alt,u,"round");
  y2svaltap=svf(A2alt,B2alt,C2altap,D2altap,u,"none");
  y2svaltapf=svf(A2alt,B2alt,C2altap,D2altap,u,"round");
  
  [yABCD,xxABCD]=svf(A,B,C,D,u,"none");
  [yABCDf,xxABCDf]=svf(A,B,C,D,u,"round");
  yABCDap=svf(A,B,Cap,Dap,u,"none");
  yABCDapf=svf(A,B,Cap,Dap,u,"round");
  
  [yABCDds,xxABCDds]=svf(Ads,Bds,Cds,Dds,u,"none");
  [yABCDdsf,xxABCDdsf]=svf(Ads,Bds,Cds,Dds,u,"round");

  % Remove initial transient
  Rn60=(n60+1):length(u);
  u=u(Rn60);

  y=y(Rn60);
  yf=yf(Rn60);
  yap=yap(Rn60);
  yapf=yapf(Rn60);

  y2=y2(Rn60);
  y2f=y2f(Rn60);
  y2ap=y2ap(Rn60);
  y2apf=y2apf(Rn60);

  y2alt=y2alt(Rn60);
  y2altf=y2altf(Rn60);
  y2altap=y2altap(Rn60);
  y2altapf=y2altapf(Rn60);

  y2sv=y2sv(Rn60);
  y2svf=y2svf(Rn60);
  y2svap=y2svap(Rn60);
  y2svapf=y2svapf(Rn60);

  y2svalt=y2svalt(Rn60);
  y2svaltf=y2svaltf(Rn60);
  y2svaltap=y2svaltap(Rn60);
  y2svaltapf=y2svaltapf(Rn60);

  yABCD=yABCD(Rn60);
  yABCDf=yABCDf(Rn60);

  yABCDap=yABCDap(Rn60);
  yABCDapf=yABCDapf(Rn60);

  yABCDds=yABCDds(Rn60);
  yABCDdsf=yABCDdsf(Rn60);

  % Sanity checks
  if max(abs(y-y2)) > tol
    error("max(abs(y-y2))(%g) > tol",max(abs(y-y2)))
  endif
  if max(abs(y-y2alt)) > tol
    error("max(abs(y-y2alt))(%g) > tol",max(abs(y-y2alt)))
  endif
  if max(abs(y-y2sv)) > tol
    error("max(abs(y-y2sv))(%g) > tol",max(abs(y-y2sv)))
  endif
  if max(abs(y-y2svalt)) > tol
    error("max(abs(y-y2svalt))(%g) > tol",max(abs(y-y2svalt)))
  endif
  if max(abs(y-yABCD)) > tol
    error("max(abs(y-yABCD))(%g) > tol",max(abs(y-yABCD)))
  endif
  if max(abs(yap-y2ap)) > tol
    error("max(abs(yap-y2ap))(%g) > tol",max(abs(yap-y2ap)))
  endif
  if max(abs(yap-y2altap)) > tol
    error("max(abs(yap-y2altap))(%g) > tol",max(abs(yap-y2altap)))
  endif
  if max(abs(yap-y2svap)) > tol
    error("max(abs(yap-y2svap))(%g) > tol",max(abs(yap-y2svap)))
  endif
  if max(abs(yap-y2svaltap)) > tol
    error("max(abs(yap-y2svaltap))(%g) > tol", ...
          max(abs(yap-y2svaltap)))
  endif
  if max(abs(yap-yABCDap)) > tol
    error("max(abs(yap-yABCDap))(%g) > tol",max(abs(yap-yABCDap)))
  endif
  if max(abs(y-yABCDds)) > 10*tol
    error("max(abs(y-yABCDds)) > 10*tol");
  endif

  % Remove initial transient
  xx=xx(Rn60,:);
  xxf=xxf(Rn60,:);

  xx2=xx2(Rn60,:);
  xx2f=xx2f(Rn60,:); 

  xx2alt=xx2alt(Rn60,:);
  xx2altf=xx2altf(Rn60,:); 

  xx2sv=xx2sv(Rn60,:);
  xx2svf=xx2svf(Rn60,:);

  xx2svalt=xx2svalt(Rn60,:);
  xx2svaltf=xx2svaltf(Rn60,:);

  xxABCD=xxABCD(Rn60,:);
  xxABCDf=xxABCDf(Rn60,:);

  xxABCDds=xxABCDds(Rn60,:);
  xxABCDdsf=xxABCDdsf(Rn60,:);

  % Output noise variance
  est_varyd=(1+(ng*delta*delta))/12
  est_varySchurd=(1+(ngSchur*delta*delta))/12
  varyd=var(y-yf)

  est_vary2d=(1+ng2)/12
  vary2d=var(y2-y2f)

  est_vary2altd=(1+ng2alt)/12
  vary2altd=var(y2alt-y2altf)

  est_vary2svd=(1+ng2sv)/12
  vary2svd=var(y2sv-y2svf)

  est_vary2svaltd=(1+ng2svalt)/12
  vary2svaltd=var(y2svalt-y2svaltf)

  est_varyABCDd=(1+(ngABCD*delta*delta))/12
  varyABCDd=var(yABCD-yABCDf)

  est_varyABCDdsd=(1+(ngABCDds*delta*delta))/12
  varyABCDdsd=var(yABCDds-yABCDdsf)

  % All-pass variance
  est_varyapd=(1+(ngap*delta*delta))/12
  est_varySchurapd=(1+(ngSchurap*delta*delta))/12
  varyapd=var(yap-yapf)
  
  est_vary2apd=(1+(ng2ap*delta*delta))/12
  vary2apd=var(y2ap-y2apf)
  
  est_vary2altapd=(1+(ng2altap*delta*delta))/12
  vary2altapd=var(y2altap-y2altapf)
  
  est_varyABCDapd=(1+(ngABCDap*delta*delta))/12
  varyABCDapd=var(yABCDap-yABCDapf)
  
  % Check state variable std. deviation
  std_xx=std(xx)
  std_xxf=std(xxf)
  
  std_xx2=std(xx2)
  std_xx2f=std(xx2f)
  
  std_xx2alt=std(xx2alt)
  std_xx2altf=std(xx2altf)
  
  std_xx2sv=std(xx2sv)
  std_xx2svf=std(xx2svf)
  
  std_xx2svalt=std(xx2svalt)
  std_xx2svaltf=std(xx2svaltf)
  
  std_xxABCD=std(xxABCD)
  std_xxABCDf=std(xxABCDf)
  
  std_xxABCDds=std(xxABCDds)
  std_xxABCDdsf=std(xxABCDdsf)
 
  % Find maximum state variable std. deviation
  max_std_xx=max(std_xx)
  max_std_xxf=max(std_xxf)
  
  max_std_xx2=max(std_xx2)
  max_std_xx2f=max(std_xx2f)
  
  max_std_xx2alt=max(std_xx2alt)
  max_std_xx2altf=max(std_xx2altf)
  
  max_std_xx2sv=max(std_xx2sv)
  max_std_xx2svf=max(std_xx2svf)
  
  max_std_xx2svalt=max(std_xx2svalt)
  max_std_xx2svaltf=max(std_xx2svaltf)
  
  max_std_xxABCD=max(std_xxABCD)
  max_std_xxABCDf=max(std_xxABCDf)
  
  max_std_xxABCDds=max(std_xxABCDds)
  max_std_xxABCDdsf=max(std_xxABCDdsf)
  
  % Find maximum state variable absolute value
  max_xx=max(max(abs(xx)))
  max_xxf=max(max(abs(xxf)))
  
  max_xx2=max(max(abs(xx2)))
  max_xx2f=max(max(abs(xx2f)))

  max_xx2alt=max(max(abs(xx2alt)))
  max_xx2altf=max(max(abs(xx2altf)))

  max_xx2sv=max(max(abs(xx2sv)))
  max_xx2svf=max(max(abs(xx2svf)))

  max_xx2alt=max(max(abs(xx2alt)))
  max_xx2altf=max(max(abs(xx2altf)))

  max_xxABCD=max(max(abs(xxABCD)))
  max_xxABCDf=max(max(abs(xxABCDf)))

  max_xxABCDds=max(max(abs(xxABCDds)))
  max_xxABCDdsf=max(max(abs(xxABCDdsf)))

  % Create a table of results
  p2_nscale_str="$p=2^{l}$";
  sigma_y_sq_str="$\\sigma_{y}^{2}$";
  sigma_y_hat_sq_str="$\\sigma_{\\hat{y}}^{2}$"; 
  max_sigma_x_str="$\\max\\sigma_{x}$"; 
  max_abs_x_str="$\\max\\mathabs{x}$";
  switch (Nk)
    case {1}
      order_str=sprintf("%dst",Nk);
    case {2}
      order_str=sprintf("%dnd",Nk);
    case {3}
      order_str=sprintf("%drd",Nk);
    otherwise
      order_str=sprintf("%dth",Nk);
  endswitch
  
  outfile=fopen(sprintf("%s_Nk_%d_results.tab",strf,Nk),"w");
  
  fprintf...
    (outfile, ...
     ["\\begin{table} \n", ...
      "\\centering \n", ...
      "\\begin{threeparttable} \n", ...
      "\\begin{tabular}{lcccccccc} \\toprule \n", ...
      "Low-pass elliptic          &Filter &Est .  &Meas.  &All-pass &Est.   &Meas.  &Meas.  &Meas. \\\\ \n", ...
      "$N_{k}=$%d, $f_{ap}=$%4.2f &noise  &%s     &%s     &noise    &%s     &%s     &%s     &%s    \\\\ \n", ...
      "$B=$%d, $\\delta=$%d       &gain   &       &       &gain     &       &       &       &      \\\\ \n", ...
      "\\midrule                                                                                        \n", ...
      "Scaled Schur lattice       & %5.3f & %5.3f & %5.3f & %5.3f   & %5.3f & %5.3f & %5.3f & %d   \\\\ \n", ...
      "%s Schur lattice           & %5.3f & %5.3f & %5.3f & %5.3f   & %5.3f & %5.3f & %5.3f & %d   \\\\ \n", ...
      "Scaled SVD Schur lattice   & %5.3f & %5.3f & %5.3f & %5.3f   & %5.3f & %5.3f & %5.3f & %d   \\\\ \n", ...
      "Scaled direct-form SVD     & %5.3f & %5.3f & %5.3f &         &       &       & %5.3f & %d   \\\\ \n", ...
      "\\bottomrule \n", ...
      "\\end{tabular} \n ", ...
      "\\end{threeparttable} \n", ...
      "\\caption[Comparison of noise performance for a %s order ", ...
      " elliptic filter implementations]{Comparison of estimated and ", ...
      " measured noise performance of a %s order low-pass ", ...
      " elliptic filter with cutoff freqency $f_{ap}=$%4.2f, ", ...
      " implemented as a Schur lattice, SVD lattice and scaled ", ...
      " direct form SVD each with output and state ", ...
      " rounding-to-nearest to %d-bit signed-twos-complement ", ...
      " integers.} \n", ...
      "\\label{tab:comparison-schurOneMlattice-Nk-%d-noise}\n", ...
      "\\end{table}"], ...
     Nk,fap,sigma_y_sq_str,sigma_y_sq_str,sigma_y_hat_sq_str,sigma_y_hat_sq_str,max_sigma_x_str,max_abs_x_str, ...
     nbits,delta, ...
     ng,est_varySchurd,varyd,ngap,est_varySchurapd,varyapd,max_std_xxf,max_xxf, ... 
     p2_nscale_str,ng2alt,est_vary2altd,vary2altd,ng2altap,est_vary2altapd,vary2altapd,max_std_xx2altf,max_xx2altf, ...
     ngABCD,est_varyABCDd,varyABCDd,ngABCDap,est_varyABCDapd,varyABCDapd,max_std_xxABCDf,max_xxABCDf, ...
     ngABCDds,est_varyABCDdsd,varyABCDdsd,max_std_xxABCDdsf,max_xxABCDdsf, ...
     order_str, order_str,fap,nbits,Nk);

  fclose(outfile);

  % Print power-of-2 scaling
  print_polynomial(pow2p,"pow2p", ...
                   sprintf("%s_Nk_%d_pow2p.m",strf,Nk),"%2d");
  print_polynomial(pow2palt,"pow2palt", ...
                   sprintf("%s_Nk_%d_pow2palt.m",strf,Nk),"%2d");
  
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
  HABCDds=crossWelch(u,yABCDds,nfpts);
  HABCDdsf=crossWelch(u,yABCDdsf,nfpts);

  plot(nppts/nfpts,20*log10(abs(Hapf)),"-", ...
       nppts/nfpts,20*log10(abs(Hf)),"--", ...
       nppts/nfpts,20*log10(abs(HABCDf)),"-.", ...
       nppts/nfpts,20*log10(abs(HABCDdsf)),":");
  axis([0 0.5 -60 5]);
  grid("on");
  xlabel("Frequency");
  ylabel("Amplitude(dB)");
  tstr=sprintf(["Simulated response of elliptic filter ", ...
                "implementations : Nk=%1d, fap=%4.2f, nbits=%d"],Nk,fap,nbits);
  title(tstr);
  legend("location","west");
  legend("All-pass","Schur lattice","Schur SVD lattice","Scaled direct SVD");
  legend("boxoff");
  legend("left");
  zticks([]);
  print(sprintf("%s_Nk_%1d_response",strf,Nk),"-dpdflatex");
  close
  
  npass=1+(nfpts*fap);
  printf("At fap Hf=%6.4f (dB)\n",20*log10(abs(Hf(npass))));

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
