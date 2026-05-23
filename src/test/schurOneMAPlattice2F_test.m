% schurOneMAPlattice2F_test.m
% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="schurOneMAPlattice2F_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

fap=0.1;fas=0.25;dBap=2;dBas=20;tol=100*eps;

for Nk=1:7,
  
  %
  % Create a filter
  %
  [n,d]=ellip(Nk,dBap,dBas,2*fap);
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);

  for w=1:3,
    if w==1
      [A,B,Cap,Dap]=schurOneMAPlattice2Abcd(k,ones(size(k)),ones(size(k)));
      F=schurOneMAPlattice2F(k,ones(size(k)),ones(size(k)));
      [~,F0,Fl]=schurOneMAPlattice2F(k);
    elseif w==2
      [A,B,Cap,Dap]=schurOneMAPlattice2Abcd(k,epsilon,ones(size(k)));
      F=schurOneMAPlattice2F(k,epsilon,ones(size(k)));
      [~,F0,Fl]=schurOneMAPlattice2F(k,epsilon);
    else
      [A,B,Cap,Dap]=schurOneMAPlattice2Abcd(k,epsilon,p);
      F=schurOneMAPlattice2F(k,epsilon,p);
      [~,F0,Fl]=schurOneMAPlattice2F(k,epsilon,p);
    endif
    
    % Sanity checks
    if length(F) ~= Nk+1
      error("length(F) ~= Nk+1");
    endif
    if length(F0) ~= Nk+1
      error("length(F0) ~= Nk+1");
    endif
    if length(Fl) ~= Nk+1
      error("length(Fl) ~= Nk+1");
    endif

    kk=[0;k(:)];
    for l=1:(Nk+1),
      Fchk=F0{l}+(kk(l)*Fl{l});
      if max(max(abs(F{l}-Fchk))) > tol
        error("max(max(abs(F{%d}-Fchk))) > tol",l);
      endif
    endfor
    
    ABCapDap=F{1};
    for l=2:(Nk+1),
      ABCapDap=F{l}*ABCapDap;
    endfor
    if max(max(abs(ABCapDap-[A,B;Cap,Dap]))) > tol
      error("max(max(abs(ABCapDap-[A,B;Cap,Dap]))) > tol");
    endif

    [nap,dap]=Abcd2tf(ABCapDap(1:Nk,1:Nk),ABCapDap(1:Nk,Nk+1), ...
                      ABCapDap(Nk+1,1:Nk),ABCapDap(Nk+1,Nk+1));
    if max(max(abs(d-fliplr(nap)))) > tol
      error("max(max(abs(d-fliplr(nap)))) > tol");
    endif
    if max(max(abs(d-dap))) > tol
      error("max(max(abs(d-dap))) > tol");
    endif
    
  endfor

endfor

%
% Done
%
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
