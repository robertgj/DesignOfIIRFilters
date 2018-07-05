% allpass_GM2_retimed_test.m
% Copyright (C) 2018 Robert G. Jenssen

test_common;

unlink("allpass_GM2_retimed_test.diary");
unlink("allpass_GM2_retimed_test.diary.tmp");
diary allpass_GM2_retimed_test.diary.tmp

del=1e-6;
tol=10*eps;

%
% Real poles
%
r1=-0.3;
r2=0.4;
b=conv([r1, 0, -1],[r2, 0, -1]);
a=conv([1, 0, -r1],[1, 0, -r2]);
[Hf,w]=freqz(b,a,1024);
[Tf,w]=grpdelay(b,a,1024);

[k1,k2]=allpass_GM2_retimed_pole2coef(r1,r2,"real");
[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_GM2_retimed_coef2Abcd(k1,k2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
[bb,aa]=Abcd2tf(A,B,C,D);
if max(abs(bb-b)) > tol
  error("max(abs(bb-b)) > tol");
endif
if max(abs(aa-a)) > tol
  error("max(abs(aa-a)) > tol");
endif

[H,dHdw]=Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx);
if max(abs(H)-1) > tol
  error("max(abs(H)-1) > tol");
endif
P=H2P(H);
if max(abs(P-unwrap(arg(Hf)))) > tol
  error("max(P-abs(unwrap(arg(Hf)))) > tol");
endif
T=H2T(H,dHdw);
if max(abs(T-Tf)) > 10*tol
  error("max(abs(T-Tf)) > 10*tol");
endif
allpass_filter_check_gradc1c2(@allpass_GM2_retimed_coef2Abcd, ...
                              w,k1,k2,del,del/200);

% Check e1,e2
dtol=del/200;
kdel=del/2;
for e1=-1:2:1
  for e2=-1:2:1
 
    % Check A,B,C,D
    [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_GM2_retimed_coef2Abcd(k1,e1,k2,e2);
    if rank([A,B])~=rows(A)
      printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
    endif
    [H,dHdw,dHdx,d2Hdwdx] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx);
    [bb,aa]=Abcd2tf(A,B,C,D);
    if max(abs(bb-b)) > tol
      error("max(abs(bb-b)) > tol");
    endif
    if max(abs(aa-a)) > tol
      error("max(abs(aa-a)) > tol");
    endif

    [P,gradP]=H2P(H,dHdx);
    if max(abs(P-unwrap(arg(Hf)))) > tol
      error("max(abs(P-unwrap(arg(Hf)))) > tol");
    endif
    [T,gradT]=H2T(H,dHdw,dHdx,d2Hdwdx);
    if max(abs(T-Tf)) > 10*tol
      error("max(abs(T-Tf)) > 10*tol");
    endif

    % Check gradP(:,1)
    [AP,BP,CP,DP]=allpass_GM2_retimed_coef2Abcd(k1+kdel,e1,k2,e2);
    HP = Abcd2H(w,AP,BP,CP,DP);
    PP=H2P(HP);
    [AM,BM,CM,DM]=allpass_GM2_retimed_coef2Abcd(k1-kdel,e1,k2,e2);
    HM = Abcd2H(w,AM,BM,CM,DM);
    PM=H2P(HM); 
    approx_gradP=(PP-PM)/del;
    max_diff_gradP_k1=max(abs(gradP(:,1)-approx_gradP));
    if max_diff_gradP_k1 > dtol
      error("max_diff_gradP_k1(%g) > dtol",max_diff_gradP_k1);
    endif

    % Check gradP(:,2)
    [AP,BP,CP,DP]=allpass_GM2_retimed_coef2Abcd(k1,e1,k2+kdel,e2);
    HP = Abcd2H(w,AP,BP,CP,DP);
    PP=H2P(HP);
    [AM,BM,CM,DM]=allpass_GM2_retimed_coef2Abcd(k1,e1,k2-kdel,e2);
    HM = Abcd2H(w,AM,BM,CM,DM);
    PM=H2P(HM); 
    approx_gradP=(PP-PM)/del;
    max_diff_gradP_k2=max(abs(gradP(:,2)-approx_gradP));
    if max_diff_gradP_k2 > dtol
      error("max_diff_gradP_c(%g)2 > dtol",max_diff_gradP_k2);
    endif

    % Check gradT(:,1)
    [AP,BP,CP,DP,dAPdx,dBPdx,dCPdx,dDPdx]= ...
      allpass_GM2_retimed_coef2Abcd(k1+kdel,e1,k2,e2);
    [HP,dHPdw,dHPdx,d2HPdwdx] = Abcd2H(w,AP,BP,CP,DP,dAPdx,dBPdx,dCPdx,dDPdx);
    TP=H2T(HP,dHPdw,dHPdx,d2HPdwdx);
    [AM,BM,CM,DM,dAMdx,dBMdx,dCMdx,dDMdx]= ...
      allpass_GM2_retimed_coef2Abcd(k1-kdel,e1,k2,e2);
    [HM,dHMdw,dHMdx,d2HMdwdx] = Abcd2H(w,AM,BM,CM,DM,dAMdx,dBMdx,dCMdx,dDMdx);
    TM=H2T(HM,dHMdw,dHMdx,d2HMdwdx);
    approx_gradT=(TP-TM)/del;
    max_diff_gradT_k1=max(abs(gradT(:,1)-approx_gradT));
    if max_diff_gradT_k1 > dtol
      error("max_diff_gradT_k1(%g) > dtol",max_diff_gradT_k1);
    endif
    
    % Check gradT(:,2)
    [AP,BP,CP,DP,dAPdx,dBPdx,dCPdx,dDPdx]= ...
      allpass_GM2_retimed_coef2Abcd(k1,e1,k2+kdel,e2);
    [HP,dHPdw,dHPdx,d2HPdwdx] = Abcd2H(w,AP,BP,CP,DP,dAPdx,dBPdx,dCPdx,dDPdx);
    TP=H2T(HP,dHPdw,dHPdx,d2HPdwdx);
    [AM,BM,CM,DM,dAMdx,dBMdx,dCMdx,dDMdx]= ...
      allpass_GM2_retimed_coef2Abcd(k1,e1,k2-kdel,e2);
    [HM,dHMdw,dHMdx,d2HMdwdx] = Abcd2H(w,AM,BM,CM,DM,dAMdx,dBMdx,dCMdx,dDMdx);
    TM=H2T(HM,dHMdw,dHMdx,d2HMdwdx);
    approx_gradT=(TP-TM)/del;
    max_diff_gradT_k2=max(abs(gradT(:,2)-approx_gradT));
    if max_diff_gradT_k2 > 2*dtol
      error("max_diff_gradT_k2(%g) > 2*dtol",max_diff_gradT_k2);
    endif
    
  endfor
endfor

%
% Complex poles
%
r=-0.7;
theta=-pi/1.5;
b=conv([r*e^(-j*theta), 0, -1],[r*e^(j*theta), 0, -1]);
a=conv([1, 0, -r*e^(-j*theta)],[1, 0, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[Tf,w]=grpdelay(b,a,1024);

[k1,k2]=allpass_GM2_retimed_pole2coef(r,theta,"complex");
[A,B,C,D]=allpass_GM2_retimed_coef2Abcd(k1,k2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
[bb,aa]=Abcd2tf(A,B,C,D);
if max(abs(bb-b)) > tol
  error("max(abs(bb-b)) > tol");
endif
if max(abs(aa-a)) > tol
  error("max(abs(aa-a)) > tol");
endif

[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_GM2_retimed_coef2Abcd(k1,k2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
[bb,aa]=Abcd2tf(A,B,C,D);
if max(abs(bb-b)) > tol
  error("max(abs(bb-b)) > tol");
endif
if max(abs(aa-a)) > tol
  error("max(abs(aa-a)) > tol");
endif

[H,dHdw] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx);
if max(abs(H)-1) > tol
  error("max(abs(H)-1) > tol");
endif
P=H2P(H);
if max(abs(P-unwrap(arg(Hf)))) > 10*tol
  error("max(abs(P-unwrap(arg(Hf)))) > 10*tol");
endif
T=H2T(H,dHdw);
if max(abs(T-Tf)) > 20*tol
  error("max(abs(T-Tf)) > 20*tol");
endif
allpass_filter_check_gradc1c2(@allpass_GM2_retimed_coef2Abcd,w, ...
                              k1,k2,del,del/100);

% Check e1,e2
dtol=del/200;
kdel=del/2;
for e1=-1:2:1
  for e2=-1:2:1
 
    % Check A,B,C,D
    [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_GM2_retimed_coef2Abcd(k1,e1,k2,e2);
    if rank([A,B])~=rows(A)
      printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
    endif
    [H,dHdw,dHdx,d2Hdwdx] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx);
    [bb,aa]=Abcd2tf(A,B,C,D);
    if max(abs(bb-b)) > tol
      error("max(abs(bb-b)) > tol");
    endif
    if max(abs(aa-a)) > tol
      error("max(abs(aa-a)) > tol");
    endif

    [P,gradP]=H2P(H,dHdx);
    if max(abs(P-unwrap(arg(Hf)))) > 10*tol
      error("max(abs(P-unwrap(arg(Hf)))) > 10*tol");
    endif
    [T,gradT]=H2T(H,dHdw,dHdx,d2Hdwdx);
    if max(abs(T-Tf)) > 20*tol
      error("max(abs(T-Tf)) > 20*tol");
    endif

    % Check gradP(:,1)
    [AP,BP,CP,DP]=allpass_GM2_retimed_coef2Abcd(k1+kdel,e1,k2,e2);
    HP = Abcd2H(w,AP,BP,CP,DP);
    PP=H2P(HP);
    [AM,BM,CM,DM]=allpass_GM2_retimed_coef2Abcd(k1-kdel,e1,k2,e2);
    HM = Abcd2H(w,AM,BM,CM,DM);
    PM=H2P(HM); 
    approx_gradP=(PP-PM)/del;
    max_diff_gradP_k1=max(abs(gradP(:,1)-approx_gradP));
    if max_diff_gradP_k1 > dtol
      error("max_diff_gradP_k1(%g) > dtol",max_diff_gradP_k1);
    endif

    % Check gradP(:,2)
    [AP,BP,CP,DP]=allpass_GM2_retimed_coef2Abcd(k1,e1,k2+kdel,e2);
    HP = Abcd2H(w,AP,BP,CP,DP);
    PP=H2P(HP);
    [AM,BM,CM,DM]=allpass_GM2_retimed_coef2Abcd(k1,e1,k2-kdel,e2);
    HM = Abcd2H(w,AM,BM,CM,DM);
    PM=H2P(HM); 
    approx_gradP=(PP-PM)/del;
    max_diff_gradP_k2=max(abs(gradP(:,2)-approx_gradP));
    if max_diff_gradP_k2 > dtol
      error("max_diff_gradP_c(%g)2 > dtol",max_diff_gradP_k2);
    endif

    % Check gradT(:,1)
    [AP,BP,CP,DP,dAPdx,dBPdx,dCPdx,dDPdx]= ...
      allpass_GM2_retimed_coef2Abcd(k1+kdel,e1,k2,e2);
    [HP,dHPdw,dHPdx,d2HPdwdx] = Abcd2H(w,AP,BP,CP,DP,dAPdx,dBPdx,dCPdx,dDPdx);
    TP=H2T(HP,dHPdw,dHPdx,d2HPdwdx);
    [AM,BM,CM,DM,dAMdx,dBMdx,dCMdx,dDMdx]= ...
      allpass_GM2_retimed_coef2Abcd(k1-kdel,e1,k2,e2);
    [HM,dHMdw,dHMdx,d2HMdwdx] = Abcd2H(w,AM,BM,CM,DM,dAMdx,dBMdx,dCMdx,dDMdx);
    TM=H2T(HM,dHMdw,dHMdx,d2HMdwdx);
    approx_gradT=(TP-TM)/del;
    max_diff_gradT_k1=max(abs(gradT(:,1)-approx_gradT));
    if max_diff_gradT_k1 > 2*dtol
      error("max_diff_gradT_k1(%g) > 2*dtol",max_diff_gradT_k1);
    endif
    
    % Check gradT(:,2)
    [AP,BP,CP,DP,dAPdx,dBPdx,dCPdx,dDPdx]= ...
      allpass_GM2_retimed_coef2Abcd(k1,e1,k2+kdel,e2);
    [HP,dHPdw,dHPdx,d2HPdwdx] = Abcd2H(w,AP,BP,CP,DP,dAPdx,dBPdx,dCPdx,dDPdx);
    TP=H2T(HP,dHPdw,dHPdx,d2HPdwdx);
    [AM,BM,CM,DM,dAMdx,dBMdx,dCMdx,dDMdx]= ...
      allpass_GM2_retimed_coef2Abcd(k1,e1,k2-kdel,e2);
    [HM,dHMdw,dHMdx,d2HMdwdx] = Abcd2H(w,AM,BM,CM,DM,dAMdx,dBMdx,dCMdx,dDMdx);
    TM=H2T(HM,dHMdw,dHMdx,d2HMdwdx);
    approx_gradT=(TP-TM)/del;
    max_diff_gradT_k2=max(abs(gradT(:,2)-approx_gradT));
    if max_diff_gradT_k2 > 4*dtol
      error("max_diff_gradT_k2(%g) > 4*dtol",max_diff_gradT_k2);
    endif
    
  endfor
endfor

%
% Simulation
%
nbits=10;
nscale=2^(nbits-1);
nsamples=2^15;
rand("seed",0xdeadbeef);
u=(rand(nsamples,1)-0.5);
u=round(nscale*u/(2*std(u)));

r=0.9;
theta=pi/5;
b=conv([r*e^(-j*theta), 0, -1],[r*e^(j*theta), 0, -1]);
a=conv([1, 0, -r*e^(-j*theta)],[1, 0, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[k1,k2]=allpass_GM2_retimed_pole2coef(r,theta,"complex");
[A,B,C,D]=allpass_GM2_retimed_coef2Abcd(k1,k2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
H=Abcd2H(w,A,B,C,D);
if max(abs(Hf-H)) > 10*tol
  error("max(abs(H-Hf)) > 10*tol");
endif
[bb,aa]=Abcd2tf(A,B,C,D);
bb=bb(1:length(b));
if max(abs(bb-b)) > tol
  error("max(abs(bb-b)) > tol");
endif
aa=a(1:length(a));
if max(abs(aa-a)) > tol
  error("max(abs(aa-a)) > tol");
endif
y=filter(b,a,u);
[yABCD,xxABCD]=svf(A,B,C,D,u,"none");
if max(abs(y-yABCD)) > 500*tol
  error("max(abs(y-yABCD)) > 500*tol");
endif
[yGM2_retimed,xxGM2_retimed]=allpass_GM2_retimed(k1,k2,u);
if max(abs(y-yGM2_retimed)) > 500*tol
  error("max(abs(y-yGM2_retimed)) > 500*tol");
endif

% Check noise gain
[yGM2_retimedf,xxGM2_retimedf]=allpass_GM2_retimed(k1,k2,u,"round");
ngGM2_retimed=allpass_GM2_retimed_coef2ng(k1,k2)
est_varyd=(1+ngGM2_retimed)/12
varyd=var(yGM2_retimed-yGM2_retimedf)

% Try a different filter
r=0.98;
theta=pi/2;
b=conv([r*e^(-j*theta), 0, -1],[r*e^(j*theta), 0, -1]);
a=conv([1, 0, -r*e^(-j*theta)],[1, 0, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[k1,k2]=allpass_GM2_retimed_pole2coef(r,theta,"complex");
for ep1=-1:2:1
  for ep2=-1:2:1
    [A,B,C,D]=allpass_GM2_retimed_coef2Abcd(k1,e1,k2,e2);
    if rank([A,B])~=rows(A)
      printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
    endif
    H=Abcd2H(w,A,B,C,D);
    if max(abs(Hf-H)) > 100*tol
      error("max(abs(H-Hf)) > 100*tol");
    endif
    ngGM2_retimed=allpass_GM2_retimed_coef2ng(k1,ep1,k2,ep2)
    [yGM2_retimed,xxGM2_retimed]=allpass_GM2_retimed(k1,ep1,k2,ep2,u,"none");
    [yGM2_retimedf,xxGM2_retimedf]=allpass_GM2_retimed(k1,ep1,k2,ep2,u,"round");
    est_varyd=(1+ngGM2_retimed)/12;
    varyd=var(yGM2_retimed-yGM2_retimedf);
    printf("ep1=%d,ep2=%d,est_varyd=%f,varyd=%f\n",ep1,ep2,est_varyd,varyd);
  endfor
endfor

% Try a different filter
r=0.1;
theta=pi/3;
b=conv([r*e^(-j*theta), 0, -1],[r*e^(j*theta), 0, -1]);
a=conv([1, 0, -r*e^(-j*theta)],[1, 0, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[k1,k2]=allpass_GM2_retimed_pole2coef(r,theta,"complex");
e1=-1;
e2=1;
[A,B,C,D]=allpass_GM2_retimed_coef2Abcd(k1,e1,k2,e2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
H=Abcd2H(w,A,B,C,D);
if max(abs(Hf-H)) > 10*tol
  error("max(abs(H-Hf)) > 10*tol");
endif
% Check noise gain
[yGM2_retimed,xxGM2_retimed]=allpass_GM2_retimed(k1,e1,k2,e2,u,"none");
[yGM2_retimedf,xxGM2_retimedf]=allpass_GM2_retimed(k1,e1,k2,e2,u,"round");
ngGM2_retimed=allpass_GM2_retimed_coef2ng(k1,e1,k2,e2)
est_varyd=(1+ngGM2_retimed)/12
varyd=var(yGM2_retimed-yGM2_retimedf)

% Try a different filter
r=-0.2;
theta=pi/3;
b=conv([r*e^(-j*theta), 0, -1],[r*e^(j*theta), 0, -1]);
a=conv([1, 0, -r*e^(-j*theta)],[1, 0, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[k1,k2]=allpass_GM2_retimed_pole2coef(r,theta,"complex");
e1=1;
e2=-1;
[A,B,C,D]=allpass_GM2_retimed_coef2Abcd(k1,e1,k2,e2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
H=Abcd2H(w,A,B,C,D);
if max(abs(Hf-H)) > 10*tol
  error("max(abs(H-Hf)) > 10*tol");
endif
% Check noise gain
[yGM2_retimed,xxGM2_retimed]=allpass_GM2_retimed(k1,e1,k2,e2,u,"none");
[yGM2_retimedf,xxGM2_retimedf]=allpass_GM2_retimed(k1,e1,k2,e2,u,"round");
ngGM2_retimed=allpass_GM2_retimed_coef2ng(k1,e1,k2,e2)
est_varyd=(1+ngGM2_retimed)/12
varyd=var(yGM2_retimed-yGM2_retimedf)

% Try a different filter
r=0.2;
theta=pi;
b=conv([r*e^(-j*theta), 0, -1],[r*e^(j*theta), 0, -1]);
a=conv([1, 0, -r*e^(-j*theta)],[1, 0, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[k1,k2]=allpass_GM2_retimed_pole2coef(r,theta,"complex");
e1=1;
e2=-1;
[A,B,C,D]=allpass_GM2_retimed_coef2Abcd(k1,e1,k2,e2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
H=Abcd2H(w,A,B,C,D);
if max(abs(Hf-H)) > 10*tol
  error("max(abs(H-Hf)) > 10*tol");
endif
% Check noise gain
[yGM2_retimed,xxGM2_retimed]=allpass_GM2_retimed(k1,e1,k2,e2,u,"none");
[yGM2_retimedf,xxGM2_retimedf]=allpass_GM2_retimed(k1,e1,k2,e2,u,"round");
ngGM2_retimed=allpass_GM2_retimed_coef2ng(k1,e1,k2,e2)
est_varyd=(1+ngGM2_retimed)/12
varyd=var(yGM2_retimed-yGM2_retimedf)

% Done
diary off
movefile allpass_GM2_retimed_test.diary.tmp allpass_GM2_retimed_test.diary;
