% yalmip_kyp_check_iir_lowpass_test.m
% Copyright (C) 2022-2025 Robert G. Jenssen

test_common;

strf="yalmip_kyp_check_iir_lowpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

fhandle=fopen(strcat(strf,".results"),"w");

%
% Elliptic low-pass filter
%
N=11;fap=0.15;dBap=0.02;fatl=0.1707;fas=0.1708;dBas=84;
[n,d]=ellip(N,dBap,dBas,fap*2);

% Frequency response
nplot=2^14;
[H,w]=freqz(n,d,nplot);

% Constants for frequency bandwidths
Phi=[-1,0;0,1];
c_p=2*cos(2*pi*fap);
Psi_p=[0,1;1,-c_p];
c_s=2*cos(2*pi*fas);
Psi_s=[0,-1;-1,c_s];
% Transition band is band-pass
e_t=e^(j*pi*(fap+fatl));
c_t=2*cos(pi*(fatl-fap));
Psi_t=[0,e_t;1/e_t,-c_t]; 

% Constants for squared-amplitude response
Asq_pu=1;
Asq_pl=10^(-dBap/10);
Asq_s=10^(-dBas/10);
Pi_pu=diag([ 1, -Asq_pu]); % |H(pass_band)|^2 < Asq_pu
Pi_pl=diag([-1,  Asq_pl]); % |H(pass_band)|^2 > Asq_pl
Pi_tu=diag([ 1, -Asq_pl]); % |H(transition_band)|^2 < Asq_pl
Pi_tl=diag([-1,  Asq_s]);  % |H(transition_band)|^2 > Asq_s
Pi_s =diag([ 1, -Asq_s]);  % |H(stop_band)|^2 < Asq_s

filter_type={["direct"],["schurNS"],["schurOneM"],["schurOneMPA"], ...
             ["schurOneMPADP"]};
for impl=1:length(filter_type),
  if strcmp(char(filter_type(impl)),"direct")
    [A,B,C,D]=tf2Abcd(n,d);
    tol=1e-10;
    tolH=1e3*tol;
    tolPD=1e6*tol;
  elseif strcmp(char(filter_type(impl)),"schurNS")
    [s10,s11,s20,s00,s02,s22] = tf2schurNSlattice(n,d);
    [A,B,C,D]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
    tol=1e-11;
    tolH=1e2*tol;
    tolPD=2e2*tol;
  elseif strcmp(char(filter_type(impl)),"schurOneM")
    [k,epsilon,p,c,S] = tf2schurOneMlattice(n,d);
    [A,B,C,D]=schurOneMlattice2Abcd(k,epsilon,p,c);
    tol=1e-11;
    tolH=1e2*tol;
    tolPD=2e2*tol;
  elseif strcmp(char(filter_type(impl)),"schurOneMPA")
    [da,db]=tf2pa(n,d);
    [ka,epsilona,pa,ca]=tf2schurOneMlattice(flipud(da(:)),da(:));
    [Aa,Ba,Ca,Da]=schurOneMAPlattice2Abcd(ka,epsilona,pa);
    [kb,epsilonb,pb,cb]=tf2schurOneMlattice(flipud(db(:)),db(:));
    [Ab,Bb,Cb,Db]=schurOneMAPlattice2Abcd(kb,epsilonb,pb);
    A=zeros(N);
    A(1:rows(Aa),1:columns(Aa))=Aa;
    A(rows(Aa)+(1:rows(Ab)),columns(Aa)+(1:columns(Ab)))=Ab;
    B=[Ba;Bb];
    C=0.5*[Ca,Cb];
    D=0.5*(Da+Db);
    tol=1e-9;
    tolH=tol;
    tolPD=1e2*tol;
  elseif strcmp(char(filter_type(impl)),"schurOneMPADP")
    [da,db]=tf2pa(n,d);
    [ka,epsilona,pa,ca]=tf2schurOneMlattice(flipud(da(:)),da(:));
    [~,~,~,~,Aa,Ba,Ca,Da]=schurOneMlatticeDoublyPipelined2Abcd(ka,epsilona,ca);
    [kb,epsilonb,pb,cb]=tf2schurOneMlattice(flipud(db(:)),db(:));
    [~,~,~,~,Ab,Bb,Cb,Db]=schurOneMlatticeDoublyPipelined2Abcd(kb,epsilonb,cb);
    A=zeros(N);
    A(1:rows(Aa),1:columns(Aa))=Aa;
    A(rows(Aa)+(1:rows(Ab)),columns(Aa)+(1:columns(Ab)))=Ab;
    B=[Ba;Bb];
    C=0.5*[Ca,Cb];
    D=0.5*(Da+Db);
    tol=1e-9;
    tolH=tol;
    tolPD=1e3*tol;

    % In this case we scale the band edge frequencies by 1/2
    c_p=2*cos(2*pi*fap/2);
    Psi_p=[0,1;1,-c_p];
    % Stop band is band-pass
    e_s=e^(j*pi*(fas+0.5)/2);
    c_s=2*cos(pi*(0.5-fas)/2);
    Psi_s=[0,e_s;1/e_s,-c_s]; 
    % Transition band is band-pass
    e_t=e^(j*pi*(fap+fatl)/2);
    c_t=2*cos(pi*(fatl-fap)/2);
    Psi_t=[0,e_t;1/e_t,-c_t]; 
  else
    error("Unknown filter implementation");
  endif
     
  printf("\nChecking filter type %s:tol=%g,tolH=%g,tolPD=%g\n\n",
         char(filter_type(impl)),tol,tolH,tolPD); 
  fprintf(fhandle,"\nChecking filter type %s:tol=%g,tolH=%g,tolPD=%g\n\n",
         char(filter_type(impl)),tol,tolH,tolPD); 

  % Sanity checks
  [nn,dd]=Abcd2tf(A,B,C,D);
  if strcmp(char(filter_type(impl)),"schurOneMPADP")
    nn=nn(2+(1:2:((2*N)+1)));
    dd=dd(1:2:((2*N)+1));
  endif
  if max(abs(nn(:)-n(:))) > tol
    error("max(abs(nn(:)-n(:))) > tol");
  endif 
  if max(abs(dd(:)-d(:))) > tol
    error("max(abs(dd(:)-d(:))) > tol");
  endif
  HH=freqz(nn,dd,nplot);
  if max(abs(HH-H)) > tolH
    error("max(abs(HH-H)) > tolH");
  endif 
  
  
  %
  % Check lowpass filter amplitude constraints with KYP 
  %
  NN=rows(A);
  AB=[A,B;eye(NN),zeros(NN,1)];
  CD=[C,D;zeros(1,NN),1];
  
  Theta_pu=(CD')*Pi_pu*CD;
  P_pu=sdpvar(NN,NN,"symmetric","real");
  Q_pu=sdpvar(NN,NN,"symmetric","real");
  F_pu=((AB')*(kron(Phi,P_pu)+kron(Psi_p,Q_pu))*AB) + Theta_pu;

  Theta_pl=(CD')*Pi_pl*CD;
  P_pl=sdpvar(NN,NN,"symmetric","real");
  Q_pl=sdpvar(NN,NN,"symmetric","real");
  F_pl=((AB')*(kron(Phi,P_pl)+kron(Psi_p,Q_pl))*AB) + Theta_pl;

  Theta_s=(CD')*Pi_s*CD;
  P_s=sdpvar(NN,NN,"symmetric","real");
  Q_s=sdpvar(NN,NN,"symmetric","real");
  F_s=((AB')*(kron(Phi,P_s)+kron(Psi_s,Q_s))*AB) + Theta_s;
  
  Theta_tu=(CD')*Pi_tu*CD;
  P_tu=sdpvar(NN,NN,"symmetric","real");
  Q_tu=sdpvar(NN,NN,"symmetric","real");
  F_tu=((AB')*(kron(Phi,P_tu)+kron(Psi_t,Q_tu))*AB) + Theta_tu;

  Theta_tl=(CD')*Pi_tl*CD;
  P_tl=sdpvar(NN,NN,"symmetric","real");
  Q_tl=sdpvar(NN,NN,"symmetric","real");
  F_tl=((AB')*(kron(Phi,P_tl)+kron(Psi_t,Q_tl))*AB) + Theta_tl;

  % YALMIP settings
  Objective=[];
  Options=sdpsettings("solver","sedumi");

  % Solve for pass-band and stop-band constraints
  Constraints=[F_pu<=0,Q_pu>=0,F_pl<=0,Q_pl>=0,F_s<=0,Q_s>=0];
  sol=optimize(Constraints,Objective,Options);
  if (sol.problem==0)
  elseif (sol.problem==4)
    printf("\nYALMIP numerical problems!\n\n");
    fprintf(fhandle,"\nYALMIP numerical problems!\n\n");
  else  
    error("YALMIP problem %s",sol.info);
  endif
  
  % Check upper and lower transition band edge separately due to the message:
  % "SeDuMi had unexplained problems, maybe due to linear dependence?"
  % The direct form gives the following warning for the transition bands:
  % "The coefficient matrix is not full row rank, numerical problems may occur."
  
  % Upper edge of transition band
  Constraints=[F_tu<=0,Q_tu>=0];
  sol=optimize(Constraints,Objective,Options);
  if (sol.problem==0)
  elseif (sol.problem==4)
    printf("\nYALMIP numerical problems (upper edge trans. band)!\n\n");
    fprintf(fhandle,"\nYALMIP numerical problems (upper edge trans. band)!\n\n");
  else  
    error("YALMIP problem %s",sol.info);
  endif
  
  % Lower edge of transition band
  Constraints=[F_tl<=0,Q_tl>=0];
  sol=optimize(Constraints,Objective,Options);
  if (sol.problem==0)
  elseif (sol.problem==4)
    printf("\nYALMIP numerical problems (lower edge trans. band)!\n\n");
    fprintf(fhandle,"\nYALMIP numerical problems (lower edge trans. band)!\n\n");
  else  
    error("YALMIP problem %s",sol.info);
  endif

  %
  % Sanity checks
  %
  function val=check_positive_definite_with_tol(str,M,tol)
    if rows(M) ~= columns(M)
      error("Expect M square!");
    endif
    if tol<=0
      error("Expect tol>0 !");
    endif 
    if any(diag(M))<=0
      error("any(diag(M))<=0");
    endif
    if 0
      % Increase values of tolPD to use this!
      val=isdefinite(M+(tol*eye(size(M))));
    else
      eM=eigs(M,rows(M));
      if max(abs(imag(eM)))>tol
        error("eigenvalues of M not real !?!");
      endif
      reM=real(eM);
      if min(reM) < (-tol)
        error("%s not positive definite (tol=-%g) !?!",str,tol);
      endif
    endif
  endfunction

  check_positive_definite_with_tol("-F_pu",-value(F_pu),tolPD)
  check_positive_definite_with_tol("Q_pu",value(Q_pu),tolPD)

  check_positive_definite_with_tol("-F_pl",-value(F_pl),tolPD)
  check_positive_definite_with_tol("Q_pl",value(Q_pl),tolPD)
   
  check_positive_definite_with_tol("-F_s",-value(F_s),tolPD)
  check_positive_definite_with_tol("Q_s",value(Q_s),tolPD)
   
  check_positive_definite_with_tol("-F_tu",-value(F_tu),tolPD)
  check_positive_definite_with_tol("Q_tu",value(Q_tu),tolPD)

  check_positive_definite_with_tol("-F_tl",-value(F_tl),tolPD)
  check_positive_definite_with_tol("Q_tl",value(Q_tl),tolPD)
  
endfor

% Show result
fprintf(fhandle,"Test complete!\n");
fclose(fhandle);

% Done
diary off
eval(sprintf("movefile %s.diary.tmp %s.diary",strf,strf));
