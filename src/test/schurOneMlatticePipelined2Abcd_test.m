% schurOneMlatticePipelined2Abcd_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test cases for the pipelined Schur one-multiplier lattice filter 

test_common;

strf="schurOneMlatticePipelined2Abcd_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% k empty
k=epsilon=c=[];
try
  [A,B,C,dd,Cap,ddap]=schurOneMlatticePipelined2Abcd(k,epsilon,c);
catch
  printf("%s\n", lasterr());
end_try_catch

% Various 
for Nk=1:11
  printf("\nTesting Nk=%d\n",Nk);
  tol=Nk*4*eps;
  dBap=0.02;dBas=84;fap=0.15;
  [n,d]=ellip(Nk,dBap,dBas,2*fap);
  [k,epsilon,~,c]=tf2schurOneMlattice(n,d);
  try
    [A,B,C,dd,Cap,ddap] = schurOneMlatticePipelined2Abcd(k,epsilon,c);
  catch
    err=lasterror();
    for e=1:length(err.stack)
      printf("Called %s at line %d\n", ...
             err.stack(e).name,err.stack(e).line);
    endfor
    error("%s\n", err.message);
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

  %
  % Check matrix coefficient cell arrays
  %
  try
    kk=k(1:(Nk-1)).*k(2:Nk);
    ck=c(2:Nk).*k(2:Nk);
    [A,B,C,dd,Cap,ddap,ABCD0,ABCDk,ABCDc,ABCDkk,ABCDck] = ...
       schurOneMlatticePipelined2Abcd(k,epsilon,c);
  catch
    err=lasterror();
    for e=1:length(err.stack)
      printf("Called %s at line %d\n", ...
             err.stack(e).name,err.stack(e).line);
    endfor
    error("%s\n", err.message);
  end_try_catch
  ABCD=[A,B;C,dd;Cap,ddap];
  cABCD=ABCD0;
  for s=1:Nk,
    cABCD=cABCD+(k(s)*ABCDk{s});
  endfor
  for s=1:(Nk+1),
    cABCD=cABCD+(c(s)*ABCDc{s});
  endfor
  for s=1:(Nk-1),
    cABCD=cABCD+(kk(s)*ABCDkk{s});
  endfor
  for s=1:(Nk-1),
    cABCD=cABCD+(ck(s)*ABCDck{s});
  endfor 
  if max(max(ABCD-cABCD))>eps
    error("max(max(ABCD-cABCD))>eps");
  endif

  % Repeat
  try
    % Approximate kk and ck
    kkr=round(kk*1024)/1024;
    ckr=round(ck*1024)/1024;
    
    [A,B,C,dd,Cap,ddap,ABCD0,ABCDk,ABCDc,ABCDkk,ABCDck] = ...
       schurOneMlatticePipelined2Abcd(k,epsilon,c,kkr,ckr);
  catch
    err=lasterror();
    for e=1:length(err.stack)
      printf("Called %s at line %d\n", ...
             err.stack(e).name,err.stack(e).line);
    endfor
    error("%s\n", err.message);
  end_try_catch
  ABCD=[A,B;C,dd;Cap,ddap];
  cABCD=ABCD0;
  for s=1:Nk,
    cABCD=cABCD+(k(s)*ABCDk{s});
  endfor
  for s=1:(Nk+1),
    cABCD=cABCD+(c(s)*ABCDc{s});
  endfor
  for s=1:(Nk-1),
    cABCD=cABCD+(kkr(s)*ABCDkk{s});
  endfor
  for s=1:(Nk-1),
    cABCD=cABCD+(ckr(s)*ABCDck{s});
  endfor 
  if max(max(ABCD-cABCD))>eps
    error("max(max(ABCD-cABCD))>eps");
  endif

  %
  % Check derivatives of A,etc wrt k,etc
  %
  
  % Approximate kk and ck
  kkr=round(kk*1024)/1024;
  ckr=round(ck*1024)/1024;

  [~,~,~,~,~,~,dAdx,dBdx,dCdx,dDdx,dCapdx,dDapdx] = ...
    schurOneMlatticePipelined2Abcd(k,epsilon,c,kkr,ckr); 

  Ax=[k(:);c(:);kkr(:);ckr(:)];
  
  Nk=length(k);
  Nc=length(c);
  Nkk=length(kkr);
  Nck=length(ckr);
  Nx=Nk+Nc+Nkk+Nck;

  Rk=1:Nk;
  Rc=(Nk+1):(Nk+Nc);
  Rkk=(Nk+Nc+1):(Nk+Nc+Nkk);
  Rck=(Nk+Nc+Nkk+1):(Nk+Nc+Nkk+Nck);
  
  dAdx_max_err=zeros(1,Nx);
  dBdx_max_err=zeros(1,Nx);
  dCdx_max_err=zeros(1,Nx);
  dDdx_max_err=zeros(1,Nx);
  dCapdx_max_err=zeros(1,Nx);
  dDapdx_max_err=zeros(1,Nx);
  
  delAx=zeros(size(Ax));
  del=1/(2^20);
  delAx(1)=del/2;
  
  for l=1:Nx
    AxP=Ax+delAx;
    [AP,BP,CP,DP,CapP,DapP] = schurOneMlatticePipelined2Abcd ...
                                (AxP(Rk),epsilon,AxP(Rc),AxP(Rkk),AxP(Rck));
    
    AxM=Ax-delAx;
    [AM,BM,CM,DM,CapM,DapM] = schurOneMlatticePipelined2Abcd ...
                                (AxM(Rk),epsilon,AxM(Rc),AxM(Rkk),AxM(Rck));

    delAx=circshift(delAx,1);
    
    dAdk_max_err(l)=max(max(abs(((AP-AM)/del)-dAdx{l})));
    dBdk_max_err(l)=max(abs(((BP-BM)/del)-dBdx{l}));
    dCdk_max_err(l)=max(abs(((CP-CM)/del)-dCdx{l}));
    dDdk_max_err(l)=max(abs(((DP-DM)/del)-dDdx{l}));
    dCapdk_max_err(l)=max(abs(((CapP-CapM)/del)-dCapdx{l}));
    dDapdk_max_err(l)=max(abs(((DapP-DapM)/del)-dDapdx{l}));
  endfor

  if max(dAdx_max_err) > eps
    error("max(dAdx_max_err) > eps");
  endif
  if max(dBdx_max_err) > eps
    error("max(dBdx_max_err) > eps");
  endif
  if max(dCdx_max_err) > eps
    error("max(dCdx_max_err) > eps");
  endif
  if max(dDdx_max_err) > eps
    error("max(dDdx_max_err) > eps");
  endif
  if max(dCapdx_max_err) > eps
    error("max(dCapdx_max_err) > eps");
  endif
  if max(dDapdx_max_err) > eps
    error("max(dDapdx_max_err) > eps");
  endif

endfor
  
% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
