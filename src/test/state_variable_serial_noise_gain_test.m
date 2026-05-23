% state_variable_serial_noise_gain_test.m
% Copyright (C) 2026 Robert G. Jenssen
%
% Test serial cascade of two state variable filters

test_common;

strf="state_variable_serial_noise_gain_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

fap=0.1;fas=0.3;dBap=1;dBas=20;delta=2;tol=100*eps;

for NN=1:5,
  
  %
  % Create a series combination of Chebyshev filters
  %

  % First filter is low-pass
  [n1,d1]=cheby2(NN,dBas,2*fas);
  [k1,epsilon1,p1,c1] = tf2schurOneMlattice(n1,d1);
  [A1,B1,C1,D1]=schurOneMlattice2Abcd(k1,epsilon1,p1,c1);
  ABCD1=[A1,B1;C1,D1];
  [K1,W1]=KW(ABCD1);
  N1=rows(A1);
  T1=[diag(delta*sqrt(diag(K1))),zeros(N1,1);zeros(1,N1),1];
  ABCD1=inv(T1)*ABCD1*T1;
  [K1,W1]=KW(ABCD1);
  ng1=sum(diag(K1).*diag(W1));
  
  % Second filter is high-pass
  [n2,d2]=cheby1(NN+1,dBap,2*fap,"high");
  [k2,epsilon2,p2,c2] = tf2schurOneMlattice(n2,d2);
  [A2,B2,C2,D2]=schurOneMlattice2Abcd(k2,epsilon2,p2,c2);
  ABCD2=[A2,B2;C2,D2];
  [K2,W2]=KW(ABCD2);
  N2=rows(A2);
  T2=[diag(delta*sqrt(diag(K2))),zeros(N2,1);zeros(1,N2),1];
  ABCD2=inv(T2)*ABCD2*T2;
  [K2,W2]=KW(ABCD2);
  ng2=sum(diag(K2).*diag(W2));

  %
  % Check the series combination
  %  
  A1=ABCD1(1:N1,1:N1);
  B1=ABCD1(1:N1,N1+1);
  C1=ABCD1(N1+1,1:N1);
  D1=ABCD1(N1+1,N1+1);
  
  A2=ABCD2(1:N2,1:N2);
  B2=ABCD2(1:N2,N2+1);
  C2=ABCD2(N2+1,1:N2);
  D2=ABCD2(N2+1,N2+1);

  ABCD1=[[C1,           zeros(1,N2),  D1]; ...
         [A1,           zeros(N1,N2), B1]; ...
         [zeros(N2,N1), eye(N2),      zeros(N2,1)]];
  
  ABCD2=[[zeros(N1,1),  eye(N1),      zeros(N1,N2)]; ...
         [B2,           zeros(N2,N1), A2]; ...
         [D2,           zeros(1,N1),  C2]];
  
  ABCD=ABCD2*ABCD1;
   
  % Sanity checks
  altABCD=[ [A1,    zeros(N1,N2), B1]; ...
            [B2*C1, A2,           B2*D1 ]; ...
            [D2*C1, C2,           D2*D1 ] ];
  if max(max(abs(ABCD-altABCD))) > tol
    error("max(max(abs(ABCD-altABCD))) > tol");
  endif

  N12=N1+N2;
  A=ABCD(1:N12,1:N12);
  B=ABCD(1:N12,N12+1);
  C=ABCD(N12+1,1:N12);
  D=ABCD(N12+1,N12+1);
  [n,d]=Abcd2tf(A,B,C,D);
  n12=conv(n1,n2);
  d12=conv(d1,d2);
  if max(abs(n-n12)) > tol
    error("max(abs(n-n12))(%g) > tol(%g)",max(abs(n-n12)),tol);
  endif
  if max(abs(d-d12)) > tol
    error("max(abs(d-d12))(%g) > tol(%g)",max(abs(d-d12)),tol);
  endif

  [K,W]=KW(ABCD);
  ng=sum(diag(K).*diag(W));
  K0=[ [K,zeros(N12,1)]; ...
       [zeros(1,N12),1] ];
  K1=ABCD1*K0*(ABCD1');
  K2=ABCD2*K1*(ABCD2');
  KL=[ [K,               A*K*(C')+B*(D')]; ...
       [C*K*(A')+D*(B'), C*K*(C')+D*(D')] ];
  if max(max(abs(K2-KL))) > tol
    error("max(max(abs(K2-KL))) (%g) > tol", max(max(abs(K2-KL))));
  endif

  %
  % Scale the overall filter
  %
  T=[diag(delta*sqrt(diag(K))),zeros(N12,1);zeros(1,N12),1];
  invT=inv(T);
  ABCDs=invT*ABCD*T;
  [Ks,Ws]=KW(ABCDs);
  ngs=sum(diag(Ks).*diag(Ws));

  % Sanity check
  As=ABCDs(1:N12,1:N12);
  Bs=ABCDs(1:N12,N12+1);
  Cs=ABCDs(N12+1,1:N12);
  Ds=ABCDs(N12+1,N12+1);
  [ns,ds]=Abcd2tf(As,Bs,Cs,Ds);
  if max(abs(ns-n12)) > tol
    error("max(abs(ns-n12))(%g) > tol(%g)",max(abs(ns-n12)),tol);
  endif
  if max(abs(ds-d12)) > tol
    error("max(abs(ds-d12))(%g) > tol(%g)",max(abs(ds-d12)),tol);
  endif

  %
  % Find the noise gain of the series combination
  %
  
  K0=[ [Ks,zeros(N12,1)]; ...
       [zeros(1,N12),1] ];
  K1=ABCD1*K0*(ABCD1');
  K2=ABCD2*K1*(ABCD2');
  
  W3=[ [Ws,zeros(N12,1)]; ...
       [zeros(1,N12),1] ];
  W2=(ABCD2')*W3*ABCD2;
  W1=(ABCD1')*W2*ABCD1;

  % Include the Ax+Bu rows and exclude the Cx+Du rows of ABCD1 and ABCD2
  gm1=[0,ones(1,N1),zeros(1,N2)];
  gm2=[zeros(1,N1),ones(1,N2),0];
  
  ng12=(gm1*(diag(K1).*diag(W1))) + (gm2*(diag(K2).*diag(W2)));
 
  %
  % Simulate the roundoff noise of the series combination and overall filter
  %
  % Make a quantised noise signal with standard deviation 0.25
  nbits=12;
  scale=2^(nbits-1);
  nsamples=2^16;
  n60=p2n60(d);
  u=reprand(n60+nsamples,1)-0.5;
  u=0.25*u/std(u); 
  u=round(u*scale);

  % Simulate the scaled overall filter
  [ys,xxs]=svf(As,Bs,Cs,Ds,u,"none");
  [ysf,xxsf]=svf(As,Bs,Cs,Ds,u,"round");

  % Renove initial transients
  Rn60=(n60+1):length(u);
  u=u(Rn60);
  ys=ys(Rn60);
  xxs=xxs(Rn60,:);
  ysf=ysf(Rn60);
  xxsf=xxsf(Rn60,:);
  
  % Compare estimated and measured output round-off noise variance

  est_vary12=(1+(ng12*delta*delta))/12;
  est_varysd=(1+(ngs*delta*delta))/12;
  varysd=var(ys-ysf);
  printf(["NN=%d : Overall scaled ng12=%5.3f, ngs=%5.3f, ", ...
          "est_vary12=%5.3f, est_varysd=%5.3f, varysd=%5.3f\n"], ...
         NN, ng12, ngs, est_vary12, est_varysd, varysd);

  outfile=fopen(sprintf("%s_NN_%1d.txt",strf,NN),"w");
  fprintf(outfile, ...
          ["NN=%d : Overall scaled ng12=%5.3f, ngs=%5.3f, ", ...
           "est_vary12=%5.3f, est_varysd=%5.3f, varysd=%5.3f\n"], ...
          NN, ng12, ngs, est_vary12, est_varysd, varysd);
  fclose(outfile);

endfor

%
% Done
%
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
