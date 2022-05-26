% state_variable_sensitivity_test.m
% Copyright (C) 2017-2021 Robert G. Jenssen

test_common;

delete("state_variable_sensitivity_test.diary");
delete("state_variable_sensitivity_test.diary.tmp");
diary state_variable_sensitivity_test.diary.tmp

verbose=false;

% Specify elliptic low pass filter
norder=5;
dBpass=1;
dBstop=40;
fpass=0.125;
fstop=0.15;
[n0,d0]=ellip(norder,dBpass,dBstop,2*fpass);

% Design minimum-noise state variable filter
[Adir,Bdir,Cdir,Ddir]=tf2Abcd(n0,d0);
[K,W]=KW(Adir,Bdir,Cdir,Ddir);
delta=1;
[Topt,Kopt,Wopt]=optKW(K,W,delta);
A=inv(Topt)*Adir*Topt;
B=inv(Topt)*Bdir;
C=Cdir*Topt;
D=Ddir;

%
% Check calculation of H with the resolvent
%
h=freqz(n0,d0,4);
h=h(2);
wpass=2*pi*fpass;
R=cell2mat(resolvent(wpass,A));
H=(C*R*B)+D;
if abs(h-H)>eps*556
  error("abs(h-H)>eps*556");
endif

%
% Find sensitivities of H(z) at the pass band edge
%
del=1e-6;

% Sensitivity of H wrt A
dHda=zeros(size(A));
diff_dHda=zeros(size(dHda));
for k=1:norder
  for l=1:norder
    dAda=zeros(size(A));
    dAda(k,l)=1;
    dHda(k,l)=C*R*dAda*R*B;
    HApdel2=(C*cell2mat(resolvent(wpass,A+(dAda*del/2)))*B)+D;
    HAmdel2=(C*cell2mat(resolvent(wpass,A-(dAda*del/2)))*B)+D;
    diff_dHda(k,l)=(HApdel2-HAmdel2)/del;
    if verbose
      printf("dHda(%d,%d)=%g+%gJ,abs(diff_dHda-dHda)=%g\n",
             k,l,real(dHda(k,l)),imag(dHda(k,l)),abs(diff_dHda(k,l)-dHda(k,l)));
    endif
  endfor
endfor
if max(max(abs(diff_dHda-dHda))) > del/3.27
  error("max(max(abs(diff_dHda-dHda))) > del/3.27");
endif

% Sensitivity of H wrt B
dHdb=C*R;
diff_dHdb=zeros(size(dHdb));
for k=1:norder
  dBdb=zeros(size(B));
  dBdb(k)=1;
  HBpdel2=(C*R*(B+(dBdb*del/2)))+D;
  HBmdel2=(C*R*(B-(dBdb*del/2)))+D;
  diff_dHdb(k)=(HBpdel2-HBmdel2)/del;
  if verbose
     printf("dHdb(%d)=%g+%gJ,abs(diff_dHdb-dHdb)=%g\n",
            k,real(dHdb(k)),imag(dHdb(k)),abs(diff_dHdb(k)-dHdb(k)));
  endif
endfor
if max(abs(diff_dHdb-dHdb)) > del/3970
  error("max(abs(diff_dHdb-dHdb)) > del/3970");
endif

% Sensitivity of H wrt C
dHdc=R*B;
diff_dHdc=zeros(size(dHdc));
for k=1:norder
  dCdc=zeros(size(C));
  dCdc(k)=1;
  HCpdel2=((C+(dCdc*del/2))*R*B)+D;
  HCmdel2=((C-(dCdc*del/2))*R*B)+D;
  diff_dHdc(k)=(HCpdel2-HCmdel2)/del;
  if verbose
     printf("dHdc(%d)=%g+%gJ,abs(diff_dHdc-dHdc)=%g\n",
            k,real(dHdc(k)),imag(dHdc(k)),abs(diff_dHdc(k)-dHdc(k)));
  endif
endfor
if max(abs(diff_dHdc-dHdc)) > del/2748
  error("max(abs(diff_dHdc-dHdc)) > del/2748");
endif

% Sensitivity of H wrt D
dHdd=1;
HDpdel2=(C*R*B)+(D+(del/2));
HDmdel2=(C*R*B)+(D-(del/2));
diff_dHdd=(HDpdel2-HDmdel2)/del;
if verbose
  printf("dHdd=%g+%gJ,abs(diff_dHdd-dHdd)=%g\n",
         real(dHdd),imag(dHdd),abs(diff_dHdd-dHdd));
endif
if abs(diff_dHdd-dHdd) > del/34775
  error("abs(diff_dHdd-dHdd) > del/34775");
endif

%
% Sensitivity of abs(H)^2
%

% Sensitivity of abs(H)^2 wrt A
dAsqda=zeros(size(A));
diff_dAsqda=zeros(size(dAsqda));
for k=1:norder
  for l=1:norder
    dAsqda(k,l)=2*((imag(H)*imag(dHda(k,l)))+(real(H)*real(dHda(k,l))));
    dAda=zeros(size(A));
    dAda(k,l)=1;
    AsqApdel2=abs((C*cell2mat(resolvent(wpass,A+(dAda*del/2)))*B)+D)^2;
    AsqAmdel2=abs((C*cell2mat(resolvent(wpass,A-(dAda*del/2)))*B)+D)^2;
    diff_dAsqda(k,l)=(AsqApdel2-AsqAmdel2)/del;
    if verbose
      printf("dAsqda(%d,%d)=%g+%gJ,abs(diff_dAsqda-dAsqda)=%g\n",
             k,l,real(dAsqda(k,l)),imag(dAsqda(k,l)),
             abs(diff_dAsqda(k,l)-dAsqda(k,l)));
    endif
  endfor
endfor
if max(max(abs(diff_dAsqda-dAsqda))) > del/208
  error("max(max(abs(diff_dAsqda-dAsqda))) > del/208");
endif

% Sensitivity of abs(H)^2 wrt B
dAsqdb=zeros(size(B));
diff_dAsqdb=zeros(size(dAsqdb));
for k=1:norder
  dAsqdb(k)=2*((imag(H)*imag(dHdb(k)))+(real(H)*real(dHdb(k))));
  dBdb=zeros(size(B));
  dBdb(k)=1;
  AsqBpdel2=abs((C*R*(B+(dBdb*del/2)))+D)^2;
  AsqBmdel2=abs((C*R*(B-(dBdb*del/2)))+D)^2;
  diff_dAsqdb(k)=(AsqBpdel2-AsqBmdel2)/del;
  if verbose
     printf("dAsqdb(%d)=%g+%gJ,abs(diff_dAsqdb-dAsqdb)=%g\n",
            k,real(dAsqdb(k)),imag(dAsqdb(k)),abs(diff_dAsqdb(k)-dAsqdb(k)));
  endif
endfor
if max(abs(diff_dAsqdb-dAsqdb)) > del/2559
  error("max(abs(diff_dAsqdb-dAsqdb)) > del/2559");
endif

% Sensitivity of abs(H)^2 wrt C
dAsqdc=zeros(size(C));
diff_dAsqdc=zeros(size(dAsqdc));
for k=1:norder
  dAsqdc(k)=2*((imag(H)*imag(dHdc(k)))+(real(H)*real(dHdc(k))));
  dCdc=zeros(size(C));
  dCdc(k)=1;
  AsqCpdel2=abs(((C+(dCdc*del/2))*R*B)+D)^2;
  AsqCmdel2=abs(((C-(dCdc*del/2))*R*B)+D)^2;
  diff_dAsqdc(k)=(AsqCpdel2-AsqCmdel2)/del;
  if verbose
     printf("dAsqdc(%d)=%g+%gJ,abs(diff_dAsqdc-dAsqdc)=%g\n",
            k,real(dAsqdc(k)),imag(dAsqdc(k)),abs(diff_dAsqdc(k)-dAsqdc(k)));
  endif
endfor
if max(abs(diff_dAsqdc-dAsqdc)) > del/1439
  error("max(abs(diff_dAsqdc-dAsqdc)) > del/1439");
endif

%
% Sensitivity of dH/dw
%

% Sensitivity of H wrt wpass
dHdw=-j*exp(j*wpass)*C*R*R*B;
Rwpdel2=cell2mat(resolvent(wpass+(del/2),A));
Rwmdel2=cell2mat(resolvent(wpass-(del/2),A));
HRpdel2=(C*Rwpdel2*B)+D;
HRmdel2=(C*Rwmdel2*B)+D;
diff_dHdw=(HRpdel2-HRmdel2)/del;
if verbose
  printf("dHdw=%g+%gJ,abs(diff_dHdw-dHdw)=%g\n",
         real(dHdw),imag(dHdw),abs(diff_dHdw-dHdw));
endif
if abs(diff_dHdd-dHdd) > del/95
  error("abs(diff_dHdd-dHdd) > del/95");
endif

% Sensitivity of dH/dw wrt A
d2Hdadw=zeros(size(A));
diff_dHdaw=zeros(size(dAsqda));
for k=1:norder
  for l=1:norder
    dAda=zeros(size(A));
    dAda(k,l)=1;
    d2Hdadw(k,l)=-j*exp(j*wpass)*C*R*((R*dAda)+(dAda*R))*R*B;
    dHdawpdel2=C*Rwpdel2*dAda*Rwpdel2*B;
    dHdawmdel2=C*Rwmdel2*dAda*Rwmdel2*B;
    diff_dHdaw(k,l)=(dHdawpdel2-dHdawmdel2)/del;
    if verbose
      printf("d2Hdadw(%d,%d)=%g+%gJ,abs(diff_dHdaw-d2Hdadw)=%g\n",
             k,l,real(d2Hdadw(k,l)),imag(d2Hdadw(k,l)),
             abs(diff_dHdaw(k,l)-d2Hdadw(k,l)));
    endif
  endfor
endfor
if max(max(abs(diff_dHdaw-d2Hdadw))) > del/3.04
  error("max(max(abs(diff_dHdaw-d2Hdadw))) > del/3.04");
endif

% Sensitivity of dH/dw wrt B
d2Hdbdw=-j*exp(j*wpass)*C*R*R;
diff_dHdbw=((C*Rwpdel2)-(C*Rwmdel2))/del;
for k=1:norder
  if verbose
    printf("d2Hdbdw(%d)=%g+%gJ,abs(diff_dAsqdbw-d2Hdbdw)=%g\n",
           k,real(d2Hdbdw(k)),imag(d2Hdbdw(k)),abs(diff_dHdbw(k)-d2Hdbdw(k)));
  endif
endfor
if max(max(abs(diff_dHdbw-d2Hdbdw))) > del/42
  error("max(max(abs(diff_dHdbw-d2Hdbdw))) > del/42");
endif

% Sensitivity of dH/dw wrt C
d2Hdcdw=-j*exp(j*wpass)*R*R*B;
diff_dHdcw=((Rwpdel2*B)-(Rwmdel2*B))/del;
for k=1:norder
  if verbose
    printf("d2Hdcdw(%d)=%g+%gJ,abs(diff_dHdcw-d2Hdcdw)=%g\n",
           k,real(d2Hdcdw(k)),imag(d2Hdcdw(k)),abs(diff_dHdcw(k)-d2Hdcdw(k)));
  endif
endfor
if max(max(abs(diff_dHdcw-d2Hdcdw))) > del/19.4
  error("max(max(abs(diff_dHdcw-d2Hdcdw))) > del/19.4");
endif

%
% Check calculation of T with the resolvent
%
if 0
  diff_T=-(atan2(imag(HRpdel2),real(HRpdel2))- ...
           atan2(imag(HRmdel2),real(HRmdel2)))/del;
  t=grpdelay(n0,d0,32);
  t=t(9);
  if abs(t-diff_T)>del/172
    error("abs(t-diff_T)>del/172");
  endif
else
  diff_T=-(atan2(imag(HRpdel2),real(HRpdel2))- ...
           atan2(imag(HRmdel2),real(HRmdel2)))/del;
  T=-((real(H)*imag(dHdw))-(imag(H)*real(dHdw)))/(abs(H)^2);
  if abs(T-diff_T)>del/169
    error("abs(T-diff_T)>del/169");
  endif
endif

% Done
diary off
movefile state_variable_sensitivity_test.diary.tmp state_variable_sensitivity_test.diary;
