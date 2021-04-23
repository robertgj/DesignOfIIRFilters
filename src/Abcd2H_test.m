% Abcd2H_test.m
% Copyright (C) 2017-2021 Robert G. Jenssen

test_common;

delete("Abcd2H_test.diary");
delete("Abcd2H_test.diary.tmp");
diary Abcd2H_test.diary.tmp

check_octave_file("Abcd2H");

verbose=true;
tol=5e-9;

% First check for a small filter
N=1;fc=0.1;
[n,d]=butter(N,2*fc);
nplot=1024;
nc=(fc/0.5)*nplot;
[h,wplot]=freqz(n,d,nplot);
[k,epsilon,p,c]=tf2schurOneMlattice(n,d);
[A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc]=schurOneMlattice2Abcd(k,epsilon,p,c);
H=Abcd2H(wplot,A,B,C,D);
if max(abs(h(1:(nc*2))-H(1:(nc*2)))) > 4*eps
  error("max(abs(h(1:(nc*2))-H(1:(nc*2))))(%g*eps) > 4*eps",
        max(abs(h-H))/eps);
endif

% Second check for a small filter
N=2;fc=0.1;
[n,d]=butter(N,2*fc);
nplot=1024;
nc=(fc/0.5)*nplot;
[h,wplot]=freqz(n,d,nplot);
[k,epsilon,p,c]=tf2schurOneMlattice(n,d);
[A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc]=schurOneMlattice2Abcd(k,epsilon,p,c);
H=Abcd2H(wplot,A,B,C,D);
if max(abs(h(1:(nc*2))-H(1:(nc*2)))) > 8*eps
  error("max(abs(h(1:(nc*2))-H(1:(nc*2))))(%g*eps) > 8*eps",
        max(abs(h-H))/eps);
endif

% Design filter transfer function
N=15;fc=0.1;
[n,d]=butter(N,2*fc);
nplot=1024;
[h,wplot]=freqz(n,d,nplot);

%
% Convert filter transfer function to lattice form
%
[k,epsilon,p,c]=tf2schurOneMlattice(n,d);
[A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc]=schurOneMlattice2Abcd(k,epsilon,p,c);
[A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk]=schurOneMAPlattice2Abcd(k,epsilon,p);

% Check H
H=Abcd2H(wplot,A,B,C,D);
if max(abs(h-H)) > tol
  error("max(abs(h-H))(%g*tol) > tol",max(abs(h-H))/tol);
endif

% Check Hap
Hap=Abcd2H(wplot,A,B,Cap,Dap);
if max(abs(Hap)-1) > 40*eps
  error("max(abs(Hap)-1)(%g*eps) > 40*eps",max(abs(Hap)-1)/eps);
endif

% Check dHdw
[H,dHdw]=Abcd2H(wplot,A,B,C,D);
del=tol;
delw=del/2;
nc=round((fc/0.5)*nplot);
diff_Hw=zeros(1,nplot);
HP=Abcd2H(wplot+delw,A,B,C,D);
HM=Abcd2H(wplot-delw,A,B,C,D);
diff_Hw=abs(((HP-HM)/del)-dHdw);
if max(diff_Hw) > 200*tol
  error("max(abs(((HP-HM)/del)-dHdw))(%g*tol) > 200*tol",max(diff_Hw)/tol);
endif

% Check dHapdw
[Hap,dHapdw]=Abcd2H(wplot,A,B,Cap,Dap);
if any(abs(dHapdw)<tol)
  error("any(abs(dHapdw)<tol)");
endif
del=tol;
delw=del/2;
diff_Hapw=zeros(1,nplot);
HapP=Abcd2H(wplot+delw,A,B,Cap,Dap);
HapM=Abcd2H(wplot-delw,A,B,Cap,Dap);
diff_Hapw=abs(((HapP-HapM)/del)-dHapdw)./abs(dHapdw);
if max(diff_Hapw) > 25*tol
  error("max(abs(((HapP-HapM)/del)-dHapdw)./abs(dHapdw))(%g*tol) > 25*tol",
        max(diff_Hapw)/tol);
endif

% Check dHdkc
Nkc=length(dAdkc);
Nk=rows(A);
Nc=Nk+1;
[H,dHdw,dHdkc]=Abcd2H(wplot,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
if any(any(abs(dHdkc))<tol)
  error("any(any(abs(dHdkc)<tol))");
endif
del=tol;
delk=zeros(size(k));
delk(1)=del/2;
delc=zeros(size(c));
delc(1)=del/2;
nc=round((fc/0.5)*nplot);
diff_Hkc=zeros(1,Nkc);
for l=1:Nkc
  if l<=Nk
    [AP,BP,CP,DP]=schurOneMlattice2Abcd(k+delk,epsilon,p,c);
    [AM,BM,CM,DM]=schurOneMlattice2Abcd(k-delk,epsilon,p,c);
    delk=shift(delk,1);
  else
    [AP,BP,CP,DP]=schurOneMlattice2Abcd(k,epsilon,p,c+delc);
    [AM,BM,CM,DM]=schurOneMlattice2Abcd(k,epsilon,p,c-delc);
    delc=shift(delc,1);
  endif
  HP=Abcd2H(wplot(nc),AP,BP,CP,DP);
  HM=Abcd2H(wplot(nc),AM,BM,CM,DM);
  diff_Hkc(l)=abs(((HP-HM)/del)-dHdkc(nc,l))./abs(dHdkc(nc,l));
endfor
if max(diff_Hkc) > 200*tol
  error("max(abs(((HP-HM)/del)-dHdkc(nc,l))./abs(dHdkc(nc,l)))\n\
(%g*tol) > 200*tol",max(diff_Hkc)/tol);
endif

% Check dHapdk
[Hap,dHapdw,dHapdk]=Abcd2H(wplot,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
if any(any(abs(dHapdk))<tol)
  error("any(any(abs(dHapdk)<tol))");
endif
Nk=rows(A);
del=tol;
delk=zeros(size(k));
delk(1)=del/2;
nc=round((fc/0.5)*nplot);
diff_Hapk=zeros(1,Nk);
for l=1:Nk
  [AP,BP,CapP,DapP]=schurOneMAPlattice2Abcd(k+delk,epsilon,p);
  [AM,BM,CapM,DapM]=schurOneMAPlattice2Abcd(k-delk,epsilon,p);
  delk=shift(delk,1);
  HapP=Abcd2H(wplot(nc),AP,BP,CapP,DapP);
HapM=Abcd2H(wplot(nc),AM,BM,CapM,DapM);
diff_Hapk(l)=abs(((HapP-HapM)/del)-dHapdk(nc,l))./abs(dHapdk(nc,l));
endfor
if max(diff_Hapk) > 100*tol
  error("max(abs(((HapP-HapM)/del)-dHapdk(nc,l))./abs(dHapdk(nc,l)))\n\
(%g*tol) > 100*tol(%g)",max(diff_Hapk)/tol);
endif

% Check d2Hdwdkc
[H,dHdw,dHdkc,d2Hdwdkc]=Abcd2H(wplot,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
% Exclude d2Hdwdkc(:,end) since d2HdwdD==0
if any(any(abs(d2Hdwdkc(:,end))))
  error("any(any(abs(d2Hdwdkc(:,end))))");
endif
if any(any(abs(d2Hdwdkc(:,1:(end-1))))<tol)
  error("any(any(abs(d2Hdwdkc(:,1:(end-1)))<tol))");
endif
Nkc=length(dAdkc);
Nk=rows(A);
Nc=Nk+1;
del=tol;
delk=zeros(size(k));
delk(1)=del/2;
delc=zeros(size(c));
delc(1)=del/2;
nc=round((fc/0.5)*nplot);
diff_Hkc=zeros(1,Nkc);
for l=1:Nkc
  if l<=Nk
    [AP,BP,CP,DP]=schurOneMlattice2Abcd(k+delk,epsilon,p,c);
    [AM,BM,CM,DM]=schurOneMlattice2Abcd(k-delk,epsilon,p,c);
    delk=shift(delk,1);
  else
    [AP,BP,CP,DP]=schurOneMlattice2Abcd(k,epsilon,p,c+delc);
    [AM,BM,CM,DM]=schurOneMlattice2Abcd(k,epsilon,p,c-delc);
    delc=shift(delc,1);
  endif
  [HP,dHdwP]=Abcd2H(wplot(nc),AP,BP,CP,DP);
  [HM,dHdwM]=Abcd2H(wplot(nc),AM,BM,CM,DM);
  if l<Nkc
    diff_dHdw(l)=max(abs(((dHdwP-dHdwM)/del)- ...
                         d2Hdwdkc(nc,l))./abs(d2Hdwdkc(nc,l)));
  else
    diff_dHdw(l)=max(abs((dHdwP-dHdwM)/del));
  endif
endfor
if max(diff_dHdw) > 300*tol
    error("max(abs(((dHdwP-dHdwM)/del)-d2Hdwdkc(nc,l))./abs(d2Hdwdkc(nc,l)))\n\
(%g*tol) > 300*tol",max(diff_dHdw)/tol);
endif
if diff_dHdw(end)>eps
 error("diff_dHdw(end)(%g)>eps",diff_dHdw(end));
endif

% Check d2Hapdwdk
[Hap,dHapdw,dHapdk,d2Hapdwdk]=Abcd2H(wplot,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
if any(any(abs(d2Hapdwdk))<tol)
  error("any(any(abs(d2Hapdwdk)<tol))");
endif
Nk=rows(A);
del=tol;
delk=zeros(size(k));
delk(1)=del/2;
nc=round((fc/0.5)*nplot);
diff_dHapdw=zeros(1,Nk);
for l=1:Nk
  [AP,BP,CapP,DapP]=schurOneMAPlattice2Abcd(k+delk,epsilon,p);
  [AM,BM,CapM,DapM]=schurOneMAPlattice2Abcd(k-delk,epsilon,p);
  delk=shift(delk,1);
  [HapP,dHapdwP]=Abcd2H(wplot(nc),AP,BP,CapP,DapP);
  [HapM,dHapdwM]=Abcd2H(wplot(nc),AM,BM,CapM,DapM);
  diff_dHapdw(l)=max(abs(((dHapdwP-dHapdwM)/del)- ...
                         d2Hapdwdk(nc,l))./abs(d2Hapdwdk(nc,l)));
endfor
if max(diff_dHapdw) > 30*tol
    error("max(abs(((dHapdwP-dHapdwM)/del)-d2Hapdwdk(nc,l))./\n\
abs(d2Hapdwdk(nc,l)))(%g*tol) > 30*tol",max(diff_dHapdw)/tol);
endif

% Check diagd2Hdkc2
[H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2]=Abcd2H(wplot,A,B,C,D, ...
                                           dAdkc,dBdkc,dCdkc,dDdkc);
% Exclude diagd2Hdkc2(:,(Nk+1);end) since d2HdC2==0 and d2HdD2==0
if any(any(abs(diagd2Hdkc2(:,(Nk+1):end))))
  error("any(any(diagd2Hdkc2(:,(Nk+1):end)))");
endif
if any(any(abs(diagd2Hdkc2(:,1:Nk)))<tol)
  error("any(any(abs(diagd2Hdkc2(:,1:Nk))<tol))");
endif
Nkc=length(dAdkc);
Nk=rows(A);
Nc=Nk+1;
del=tol;
delk=zeros(size(k));
delk(1)=del/2;
delc=zeros(size(c));
delc(1)=del/2;
nc=round((fc/0.5)*nplot);
diff_dHdkc=zeros(1,Nkc);
for l=1:Nkc
  if l<=Nk
    [AP,BP,CP,DP,CapP,DapP,dAdkcP,dBdkcP,dCdkcP,dDdkcP]= ...
      schurOneMlattice2Abcd(k+delk,epsilon,p,c);
    [AM,BM,CM,DM,CapM,DapM,dAdkcM,dBdkcM,dCdkcM,dDdkcM]= ...
      schurOneMlattice2Abcd(k-delk,epsilon,p,c);
    delk=shift(delk,1);
  else
    [AP,BP,CP,DP,CapP,DapP,dAdkcP,dBdkcP,dCdkcP,dDdkcP]= ...
      schurOneMlattice2Abcd(k,epsilon,p,c+delc);
    [AM,BM,CM,DM,CapM,DapM,dAdkcM,dBdkcM,dCdkcM,dDdkcM]= ...
      schurOneMlattice2Abcd(k,epsilon,p,c-delc);
    delc=shift(delc,1);
  endif
  [HP,dHdwP,dHdkcP]=Abcd2H(wplot(nc),AP,BP,CP,DP,dAdkcP,dBdkcP,dCdkcP,dDdkcP);
  [HM,dHdwM,dHdkcM]=Abcd2H(wplot(nc),AM,BM,CM,DM,dAdkcM,dBdkcM,dCdkcM,dDdkcM);
  if l<=Nk
    diff_dHdkc(l)=max(abs(((dHdkcP(l)-dHdkcM(l))/del)- ...
                          diagd2Hdkc2(nc,l))./abs(diagd2Hdkc2(nc,l)));
  else
    diff_dHdkc(l)=max(abs(((dHdkcP(l)-dHdkcM(l))/del)));
  endif
endfor
if max(diff_dHdkc) > 100*tol
    error("max(abs(((dHdkcP(l)-dHdkcM(l))/del)-diagd2Hdkc2(nc,l))./\n\
abs(diagd2Hdkc2(nc,l)))(%g*tol) > 100*tol",max(diff_dHdkc)/tol);
endif
if max(diff_dHdkc((Nk+1):end))>eps
 error("max(diff_dHdkc((Nk+1):end))(%g)>eps",max(diff_dHdkc((Nk+1):end)));
endif

% Check diagd2Hapdk2
[Hap,dHapdw,dHapdk,d2Hapdwdk,diagd2Hapdk2]=...
  Abcd2H(wplot,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
if any(any(abs(diagd2Hapdk2))<tol)
  error("any(any(abs(diagd2Hapdk2)<tol))");
endif
Nk=rows(A);
del=tol;
delk=zeros(size(k));
delk(1)=del/2;
nc=round((fc/0.5)*nplot);
diff_dHapdk=zeros(1,Nk);
for l=1:Nk
  [AP,BP,CapP,DapP,dAdkP,dBdkP,dCapdkP,dDapdkP]= ...
    schurOneMAPlattice2Abcd(k+delk,epsilon,p);
  [AM,BM,CapM,DapM,dAdkM,dBdkM,dCapdkM,dDapdkM]= ...
    schurOneMAPlattice2Abcd(k-delk,epsilon,p);
  delk=shift(delk,1);
  [HapP,dHapdwP,dHapdkP]=Abcd2H(wplot(nc),AP,BP,CapP,DapP, ...
                                dAdkP,dBdkP,dCapdkP,dDapdkP);
  [HapM,dHapdwM,dHapdkM]=Abcd2H(wplot(nc),AM,BM,CapM,DapM, ...
                                dAdkM,dBdkM,dCapdkM,dDapdkM);
  diff_dHapdk(l)=max(abs(((dHapdkP(l)-dHapdkM(l))/del)- ...
                         diagd2Hapdk2(nc,l))./abs(diagd2Hapdk2(nc,l)));
endfor
if max(diff_dHapdk) > 200*tol
    error("max(abs(((dHapdkP(l)-dHapdkM(l))/del)-diagd2Hapdk2(nc,l))./\n\
abs(diagd2Hapdk2(nc,l)))(%g*tol) > 200*tol",max(diff_dHapdk)/tol);
endif

% Check diagd3Hdwdkc2 with delw
[H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2]=...
  Abcd2H(wplot,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
% Exclude diagd3Hdwdkc2(:,(Nk+1);end) since d2HdC2==0 and d2HdD2==0
if any(any(diagd3Hdwdkc2(:,(Nk+1):end)))
  error("any(any(diagd3Hdwdkc2(:,(Nk+1):end)))");
endif
if any(any(abs(diagd3Hdwdkc2(:,1:Nk))<tol))
  error("any(any(abs(diagd3Hdwdkc2(:,1:Nk))<tol))");
endif
Nkc=length(dAdkc);
Nk=rows(A);
Nc=Nk+1;
del=tol;
delw=del/2;
nc=round((fc/0.5)*nplot);
diff_diagd2Hdkc2=zeros(1,Nkc);
for l=1:Nkc
  [HP,dHdwP,dHdkcP,d2HdwdkcP,diagd2Hdkc2P]=...
    Abcd2H(wplot(nc)+delw,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  [HM,dHdwM,dHdkcM,d2HdwdkcM,diagd2Hdkc2M]=...
    Abcd2H(wplot(nc)-delw,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  if l<=Nk
    diff_diagd2Hdkc2(l)=max(abs(((diagd2Hdkc2P(l)-diagd2Hdkc2M(l))/del)- ...
                                diagd3Hdwdkc2(nc,l))./abs(diagd3Hdwdkc2(nc,l)));
  else
    diff_diagd2Hdkc2(l)=max(abs(((diagd2Hdkc2P(l)-diagd2Hdkc2M(l))/del)));
  endif
endfor
if max(diff_diagd2Hdkc2) > 10*tol
    error("max(abs(((diagd2Hdkc2P(l)-diagd2Hdkc2M(l))/del)-\n\
diagd3Hdwdkc2(nc,l))./abs(diagd3Hdwdkc2(nc,l)))(%g*tol) > 10*tol",
          max(diff_diagd2Hdkc2)/tol);
endif
if max(diff_diagd2Hdkc2((Nk+1):end))>eps
  error("max(diff_diagd2Hdkc2((Nk+1):end))(%g)>eps",
        max(diff_d2Hdkc2((Nk+1):end)));
endif

% Check diagd3Hdwdkc2 with delk and delc
[H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2]=...
  Abcd2H(wplot,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
Nkc=length(dAdkc);
Nk=rows(A);
Nc=Nk+1;
del=tol;
delk=zeros(size(k));
delk(1)=del/2;
delc=zeros(size(c));
delc(1)=del/2;
nc=round((fc/0.5)*nplot);
diff_d2Hdwdkc=zeros(1,Nkc);
for l=1:Nkc
  if l<=Nk
    [AP,BP,CP,DP,CapP,DapP,dAdkcP,dBdkcP,dCdkcP,dDdkcP]= ...
      schurOneMlattice2Abcd(k+delk,epsilon,p,c);
    [AM,BM,CM,DM,CapM,DapM,dAdkcM,dBdkcM,dCdkcM,dDdkcM]= ...
      schurOneMlattice2Abcd(k-delk,epsilon,p,c);
    delk=shift(delk,1);
  else
    [AP,BP,CP,DP,CapP,DapP,dAdkcP,dBdkcP,dCdkcP,dDdkcP]= ...
      schurOneMlattice2Abcd(k,epsilon,p,c+delc);
    [AM,BM,CM,DM,CapM,DapM,dAdkcM,dBdkcM,dCdkcM,dDdkcM]= ...
      schurOneMlattice2Abcd(k,epsilon,p,c-delc);
    delc=shift(delc,1);
  endif
  [HP,dHdwP,dHdkcP,d2HdwdkcP]=Abcd2H(wplot(nc),AP,BP,CP,DP, ...
                                     dAdkcP,dBdkcP,dCdkcP,dDdkcP);
  [HM,dHdwM,dHdkcM,d2HdwdkcM]=Abcd2H(wplot(nc),AM,BM,CM,DM, ...
                                     dAdkcM,dBdkcM,dCdkcM,dDdkcM);
  if l<=Nk
    diff_d2Hdwdkc(l)=max(abs(((d2HdwdkcP(l)-d2HdwdkcM(l))/del)- ...
                             diagd3Hdwdkc2(nc,l))./abs(diagd3Hdwdkc2(nc,l)));
  else
    diff_d2Hdwdkc(l)=max(abs(((d2HdwdkcP(l)-d2HdwdkcM(l))/del)));
  endif
endfor
if max(diff_d2Hdwdkc) > 40*tol
    error("max(abs(((d2HdwdkcP(l)-d2HdwdkcM(l))/del)-diagd3Hdwdkc2(nc,l))./\
abs(diagd3Hdwdkc2(nc,l)))(%g*tol) > 40*tol",max(diff_d2Hdwdkc)/tol);
endif
if max(diff_d2Hdwdkc((Nk+1):end))>eps
 error("max(diff_d2Hdwdkc((Nk+1):end))(%g)>eps",max(diff_dH2dwdkc((Nk+1):end)));
endif

% Check diagd3Hapdwdk2 with delw
[Hap,dHapdw,dHapdk,d2Hapdwdk,diagd2Hapdk2,diagd3Hapdwdk2]=...
  Abcd2H(wplot,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
% Avoid problematic values k(1:4)
if any(any(abs(diagd3Hapdwdk2(:,5:end))<tol))
  error("any(any(abs(diagd3Hapdwdk2(:,5:end))<tol))");
endif
Nk=rows(A);
del=tol;
delw=del/2;
nc=round((fc/0.5)*nplot);
diff_diagd2Hapdk2=zeros(1,Nk);
for l=5:Nk
  [HapP,dHapdwP,dHapdkP,d2HapdwdkP,diagd2Hapdk2P]=...
    Abcd2H(wplot(nc)+delw,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
  [HapM,dHapdwM,dHapdkM,d2HapdwdkM,diagd2Hapdk2M]=...
    Abcd2H(wplot(nc)-delw,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
  diff_diagd2Hapdk2(l)=max(abs(((diagd2Hapdk2P(l)-diagd2Hapdk2M(l))/del)- ...
                               diagd3Hapdwdk2(nc,l))./abs(diagd3Hapdwdk2(nc,l)));
endfor
if max(diff_diagd2Hapdk2) > 5*tol
  error("max(abs(((diagd2Hapdk2P(l)-diagd2Hapdk2M(l))/del)-\n\
diagd3Hapdwdk2(nc,l))./abs(diagd3Hapdwdk2(nc,l)))(%g*tol) > 5*tol",
        max(diff_diagd2Hapdk2)/tol);
endif

% Check diagd3Hapdwdk2 with delk
[Hap,dHapdw,dHapdk,d2Hapdwdk,diagd2Hapdk2,diagd3Hapdwdk2]=...
  Abcd2H(wplot,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
Nk=rows(A);
del=tol;
delk=zeros(size(k));
delk(5)=del/2;
nc=round((fc/0.5)*nplot);
diff_d2Hapdwdk=zeros(1,Nk);
for l=5:Nk
  [AP,BP,CapP,DapP,dAdkP,dBdkP,dCapdkP,dDapdkP]= ...
    schurOneMAPlattice2Abcd(k+delk,epsilon,p);
  [AM,BM,CapM,DapM,dAdkM,dBdkM,dCapdkM,dDapdkM]= ...
    schurOneMAPlattice2Abcd(k-delk,epsilon,p);
  delk=shift(delk,1);
  [HapP,dHapdwP,dHapdkP,d2HapdwdkP]=Abcd2H(wplot(nc),AP,BP,CapP,DapP, ...
                                           dAdkP,dBdkP,dCapdkP,dDapdkP);
  [HapM,dHapdwM,dHapdkM,d2HapdwdkM]=Abcd2H(wplot(nc),AM,BM,CapM,DapM, ...
                                           dAdkM,dBdkM,dCapdkM,dDapdkM);
  diff_d2Hapdwdk(l)=max(abs(((d2HapdwdkP(l)-d2HapdwdkM(l))/del)- ...
                            diagd3Hapdwdk2(nc,l))./abs(diagd3Hapdwdk2(nc,l)));
endfor
if max(diff_d2Hapdwdk) > 40*tol
    error("max(abs(((d2HapdwdkP(l)-d2HapdwdkM(l))/del)-diagd3Hapdwdk2(nc,l))./\
abs(diagd3Hapdwdk2(nc,l)))(%g*tol) > 40*tol",max(diff_d2Hapdwdk)/tol);
endif

%
% Repeat for the globally optimised state variable filter with 256 coefficients.
%
[A,B,C,D]=tf2Abcd(n,d);
[K,W]=KW(A,B,C,D);
delta=4;
[Topt,Kopt,Wopt]=optKW(K,W,delta);
Aopt=inv(Topt)*A*Topt;
Bopt=inv(Topt)*B;
Copt=C*Topt;
Dopt=D;

% Check H
Hopt=Abcd2H(wplot,Aopt,Bopt,Copt,Dopt);
if max(abs(h-Hopt)) > tol
  error("max(abs(h-Hopt))(%g*tol) > tol",max(abs(h-Hopt))/tol);
endif

% Check dHdw
[Hopt,dHoptdw]=Abcd2H(wplot,Aopt,Bopt,Copt,Dopt);
del=tol;
delw=del/2;
diff_Hoptw=zeros(1,nplot);
HoptP=Abcd2H(wplot+delw,Aopt,Bopt,Copt,Dopt);
HoptM=Abcd2H(wplot-delw,Aopt,Bopt,Copt,Dopt);
diff_Hoptw=abs(((HoptP-HoptM)/del)-dHoptdw);
if max(diff_Hoptw) > 200*tol
  error("max(abs(((HoptP-HoptM)/del)-dHoptdw))(%g*tol) > 200*tol",
        max(diff_Hoptw)/tol);
endif

% Check dHoptdx
% Initialise derivative arrays
Nr=rows(Aopt);
Nc=columns(Aopt);
dAoptdx=cell(1,(Nr+1)*(Nc+1));
dBoptdx=cell(size(dAoptdx));
dCoptdx=cell(size(dAoptdx));
dDoptdx=cell(size(dAoptdx));
for l=1:Nr
  for m=1:Nc
    dAoptdx{m+(Nr*(l-1))}=zeros(Nr,Nc);
    dAoptdx{m+(Nr*(l-1))}(l,m)=1;
    dBoptdx{m+(Nr*(l-1))}=zeros(Nr,1);
    dCoptdx{m+(Nr*(l-1))}=zeros(1,Nc);
    dDoptdx{m+(Nr*(l-1))}=0;
  endfor
endfor
for l=1:Nr
  dAoptdx{l+(Nc*Nr)}=zeros(Nr,Nc);
  dBoptdx{l+(Nc*Nr)}=zeros(Nr,1);
  dBoptdx{l+(Nc*Nr)}(l)=1;
  dCoptdx{l+(Nc*Nr)}=zeros(1,Nc);
  dDoptdx{l+(Nc*Nr)}=0;
endfor
for l=1:Nc
  dAoptdx{l+(Nc*Nr)+Nr}=zeros(Nr,Nc);
  dBoptdx{l+(Nc*Nr)+Nr}=zeros(Nr,1);
  dCoptdx{l+(Nc*Nr)+Nr}=zeros(1,Nc);
  dCoptdx{l+(Nc*Nr)+Nr}(l)=1;
  dDoptdx{l+(Nc*Nr)+Nr}=0+j*0;
endfor
dAoptdx{(Nc*Nr)+Nr+Nc+1}=zeros(Nr,Nc);
dBoptdx{(Nc*Nr)+Nr+Nc+1}=zeros(Nr,1);
dCoptdx{(Nc*Nr)+Nr+Nc+1}=zeros(1,Nc);
dDoptdx{(Nc*Nr)+Nr+Nc+1}=1;
% Exact result
[Hopt,dHoptdw,dHoptdx]=Abcd2H(wplot,Aopt,Bopt,Copt,Dopt,...
                              dAoptdx,dBoptdx,dCoptdx,dDoptdx);
% Aopt
del=tol;
diff_Hoptx=zeros(1,length(dAoptdx));
nc=round((fc/0.5)*nplot);
for l=1:Nr
  for m=1:Nc
    AoptP=Aopt;
    AoptP(l,m)=AoptP(l,m)+(del/2);
    AoptM=Aopt;
    AoptM(l,m)=AoptM(l,m)-(del/2);
    HoptP=Abcd2H(wplot(nc),AoptP,Bopt,Copt,Dopt);
    HoptM=Abcd2H(wplot(nc),AoptM,Bopt,Copt,Dopt);
    diff_Hoptx(m+(Nc*(l-1)))=abs(((HoptP-HoptM)/del)-dHoptdx(nc,m+(Nc*(l-1))));
  endfor
endfor
% Bopt
for l=1:Nr
  BoptP=Bopt;
  BoptP(l)=BoptP(l)+(del/2);
  BoptM=Bopt;
  BoptM(l)=BoptM(l)-(del/2);
  HoptP=Abcd2H(wplot(nc),Aopt,BoptP,Copt,Dopt);
  HoptM=Abcd2H(wplot(nc),Aopt,BoptM,Copt,Dopt);
  diff_Hoptx(l+(Nc*Nr))=abs(((HoptP-HoptM)/del)-dHoptdx(nc,l+(Nc*Nr)));
endfor
% Copt
for m=1:Nc
  CoptP=Copt;
  CoptP(m)=CoptP(m)+(del/2);
  CoptM=Copt;
  CoptM(m)=CoptM(m)-(del/2);
  HoptP=Abcd2H(wplot(nc),Aopt,Bopt,CoptP,Dopt);
  HoptM=Abcd2H(wplot(nc),Aopt,Bopt,CoptM,Dopt);
  diff_Hoptx(m+Nr+(Nc*Nr))=abs(((HoptP-HoptM)/del)-dHoptdx(nc,m+Nr+(Nc*Nr)));
endfor
% Dopt
DoptP=Dopt+(del/2);
DoptM=Dopt-(del/2);
HoptP=Abcd2H(wplot(nc),Aopt,Bopt,Copt,DoptP);
HoptM=Abcd2H(wplot(nc),Aopt,Bopt,Copt,DoptM);
diff_Hoptx(1+Nc+Nr+(Nc*Nr))=abs(((HoptP-HoptM)/del)-dHoptdx(nc,1+Nc+Nr+(Nc*Nr)));
% Check dHoptdx
if max(diff_Hoptx) > 200*tol
  error("max(abs(((HoptP-HoptM)/del)-dHoptdx(nc,:)));)(%g*tol) > 200*tol",
        max(diff_Hoptx)/tol);
endif

% Check d2Hoptdwdx
[Hopt,dHoptdw,dHoptdx,d2Hoptdwdx]=Abcd2H(wplot,Aopt,Bopt,Copt,Dopt, ...
                                         dAoptdx,dBoptdx,dCoptdx,dDoptdx);
del=tol;
delw=del/2;
diff_dHoptdx=zeros(1,nplot);
[HoptP,dHoptdwP,dHoptdxP]=Abcd2H(wplot+delw,Aopt,Bopt,Copt,Dopt, ...
                                dAoptdx,dBoptdx,dCoptdx,dDoptdx);
[HoptM,dHoptdwM,dHoptdxM]=Abcd2H(wplot-delw,Aopt,Bopt,Copt,Dopt,...
                                dAoptdx,dBoptdx,dCoptdx,dDoptdx);
diff_dHoptdx=abs(((dHoptdxP-dHoptdxM)/del)-d2Hoptdwdx);
if max(max(diff_dHoptdx)) > 2000*tol
  error("max(max(abs(((dHoptdxP-dHoptdxM)/del)-d2Hoptdwdx))\
(%g*tol) > 2000*tol", max(max(diff_dHoptdx))/tol);
endif
  
% Check diagd2Hoptdx2
[Hopt,dHoptdw,dHoptdx,d2Hoptdwdx,diagd2Hoptdx2]=...
  Abcd2H(wplot(nc),Aopt,Bopt,Copt,Dopt,dAoptdx,dBoptdx,dCoptdx,dDoptdx);
% Aopt
del=tol;
diff_dHoptdx=zeros(1,length(dAoptdx));
nc=round((fc/0.5)*nplot);
for l=1:Nr
  for m=1:Nc
    AoptP=Aopt;
    AoptP(l,m)=AoptP(l,m)+(del/2);
    AoptM=Aopt;
    AoptM(l,m)=AoptM(l,m)-(del/2);
    [HoptP,dHoptdwP,dHoptdxP]=Abcd2H(wplot(nc),AoptP,Bopt,Copt,Dopt,...
                                     dAoptdx,dBoptdx,dCoptdx,dDoptdx);
    [HoptM,dHoptdwM,dHoptdxM]=Abcd2H(wplot(nc),AoptM,Bopt,Copt,Dopt,...
                                       dAoptdx,dBoptdx,dCoptdx,dDoptdx);
    diff_dHoptdx(m+(Nc*(l-1)))=...
    abs(((dHoptdxP(m+(Nc*(l-1)))-dHoptdxM(m+(Nc*(l-1))))/del)-...
        diagd2Hoptdx2(m+(Nc*(l-1))));
  endfor
endfor
% Bopt
for l=1:Nr
  BoptP=Bopt;
  BoptP(l)=BoptP(l)+(del/2);
  BoptM=Bopt;
  BoptM(l)=BoptM(l)-(del/2);
  [HoptP,dHoptdwP,dHoptdxP]=Abcd2H(wplot(nc),Aopt,BoptP,Copt,Dopt,...
                                   dAoptdx,dBoptdx,dCoptdx,dDoptdx);
  [HoptM,dHoptdwM,dHoptdxM]=Abcd2H(wplot(nc),Aopt,BoptM,Copt,Dopt,...
                                   dAoptdx,dBoptdx,dCoptdx,dDoptdx);
  diff_dHoptdx(l+(Nc*Nr))=...
    abs(((dHoptdxP(l+(Nc*Nr))-dHoptdxM(l+(Nc*Nr)))/del)-...
        diagd2Hoptdx2(l+(Nc*Nr)));
endfor
% Copt
for m=1:Nc
  CoptP=Copt;
  CoptP(m)=CoptP(m)+(del/2);
  CoptM=Copt;
  CoptM(m)=CoptM(m)-(del/2);
  [HoptP,dHoptdwP,dHoptdxP]=Abcd2H(wplot(nc),Aopt,Bopt,CoptP,Dopt,...
                                   dAoptdx,dBoptdx,dCoptdx,dDoptdx);
  [HoptM,dHoptdwM,dHoptdxM]=Abcd2H(wplot(nc),Aopt,Bopt,CoptM,Dopt,...
                                   dAoptdx,dBoptdx,dCoptdx,dDoptdx);
  diff_dHoptdx(m+Nr+(Nc*Nr))=...
    abs(((dHoptdxP(m+Nr+(Nc*Nr))-dHoptdxM(m+Nr+(Nc*Nr)))/del)-...
        diagd2Hoptdx2(m+Nr+(Nc*Nr)));
endfor
% Dopt
DoptP=Dopt+(del/2);
DoptM=Dopt-(del/2);
[HoptP,dHoptdwP,dHoptdxP]=Abcd2H(wplot(nc),Aopt,Bopt,Copt,DoptP,...
                                 dAoptdx,dBoptdx,dCoptdx,dDoptdx);
[HoptM,dHoptdwM,dHoptdxM]=Abcd2H(wplot(nc),Aopt,Bopt,Copt,DoptM,...
                                 dAoptdx,dBoptdx,dCoptdx,dDoptdx);
diff_dHoptdx(1+Nc+Nr+(Nc*Nr))=...
  abs(((dHoptdxP(1+Nc+Nr+(Nc*Nr))-dHoptdxM(1+Nc+Nr+(Nc*Nr)))/del)-...
      diagd2Hoptdx2(1+Nc+Nr+(Nc*Nr)));
% Check d2Hoptdx2
if max(diff_dHoptdx) > 500*tol
  error("max(abs(((dHoptdxP-dHoptdxM)/del)-diagd2Hoptdx2));)\
(%g*tol) > 500*tol",max(diff_dHoptdx)/tol);
endif

% Check diagd3Hoptdwdx2
[Hopt,dHoptdw,dHoptdx,d2Hoptdwdx,diagd2Hoptdx2,diagd3Hoptdwdx2]=...
  Abcd2H(wplot(nc),Aopt,Bopt,Copt,Dopt,dAoptdx,dBoptdx,dCoptdx,dDoptdx);
del=tol;
delw=del/2;
diff_dHoptdx=zeros(1,nplot);
[HoptP,dHoptdwP,dHoptdxP,d2HoptdwdxP,diagd2Hoptdx2P]=...
  Abcd2H(wplot(nc)+delw,Aopt,Bopt,Copt,Dopt,dAoptdx,dBoptdx,dCoptdx,dDoptdx);
[HoptM,dHoptdwM,dHoptdxM,d2HoptdwdxM,diagd2Hoptdx2M]=...
  Abcd2H(wplot(nc)-delw,Aopt,Bopt,Copt,Dopt,dAoptdx,dBoptdx,dCoptdx,dDoptdx);
diff_diagd2Hoptdx2=abs(((diagd2Hoptdx2P-diagd2Hoptdx2M)/del)-diagd3Hoptdwdx2);
if max(diff_diagd2Hoptdx2) > 25000*tol
  error("max(abs(((diagd2Hoptdx2P-diagd2Hoptdx2M)/del)-\
diagd3Hoptdwdx2(nc,:)))(%g*tol) > 25000*tol",
        max(max(diff_diagd2Hoptdx2))/tol);
endif

% Done
diary off
movefile Abcd2H_test.diary.tmp Abcd2H_test.diary;
