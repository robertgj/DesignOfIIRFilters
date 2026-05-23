% schurOneMlattice2F_test.m
% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="schurOneMlattice2F_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

fap=0.1;fas=0.25;dBap=1;dBas=20;tol=10*eps;

for Nk=1:7,
  
  %
  % Create a filter
  %
  [n,d]=ellip(Nk,dBap,dBas,2*fap);
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);

  for w=1:3
    if w==1
      [A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,ones(size(k)),ones(size(k)),c);
      F=schurOneMlattice2F(k,ones(size(k)),ones(size(k)),c);
    elseif w==2
      [A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,epsilon,ones(size(k)),c);
      F=schurOneMlattice2F(k,epsilon,ones(size(k)),c);
    else
      [A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,epsilon,p,c);
      F=schurOneMlattice2F(k,epsilon,p,c);
    endif
    % Sanity checks
    if length(F) ~= Nk+1
      error("length(F) ~= Nk+1");
    endif
    
    ABCapDapCD=F{1};
    for l=2:Nk,
      ABCapDapCD=F{l}*ABCapDapCD;
    endfor
    
    ABCD=F{Nk+1}([1:Nk,Nk+2],:)*ABCapDapCD;
    if max(max(abs(ABCD-[A,B;C,D]))) > tol
      error("max(max(abs(ABCD-[A,B;C,D]))) > tol");
    endif
    
    ABCapDap=F{Nk+1}(1:(Nk+1),:)*ABCapDapCD;
    if max(max(abs(ABCapDap-[A,B;Cap,Dap]))) > tol
      error("max(max(abs(ABCapDap-[A,B;Cap,Dap]))) > tol");
    endif
    
    ABCapDapCD=F{Nk+1}*ABCapDapCD;
    if max(max(abs(ABCapDapCD-[A,B;Cap,Dap;C,D]))) > tol
      error("max(max(abs(ABCapDapCD-[A,B;Cap,Dap;C,D]))) > tol");
    endif
  endfor
  
  % Tapped lattice
  [ntl,dtl]=Abcd2tf(ABCD(1:Nk,1:Nk),ABCD(1:Nk,Nk+1), ...
                    ABCD(Nk+1,1:Nk),ABCD(Nk+1,Nk+1));
  if max(max(abs(n-ntl))) > tol
    error("max(max(abs(n-ntl))) > tol");
  endif
  if max(max(abs(d-dtl))) > tol
    error("max(max(abs(d-dtl))) > tol");
  endif
  
  % All-pass lattice
  [nap,dap]=Abcd2tf(ABCapDap(1:Nk,1:Nk),ABCapDap(1:Nk,Nk+1), ...
                    ABCapDap(Nk+1,1:Nk),ABCapDap(Nk+1,Nk+1));
  if max(max(abs(d-fliplr(nap)))) > tol
    error("max(max(abs(d-fliplr(nap)))) > tol");
  endif
  if max(max(abs(d-dap))) > tol
    error("max(max(abs(d-dap))) > tol");
  endif
  
endfor

%
% Done
%
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
