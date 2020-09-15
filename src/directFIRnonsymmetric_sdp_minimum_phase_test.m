% directFIRnonsymmetric_sdp_minimum_phase_test.m
%
%                  !!!WARNING!!!
%
%   I DO NOT GET SENSIBLE RESULTS FROM THIS SCRIPT
%
%                  !!!WARNING!!!
%
% See Section 3.2 of SeDuMi_1_3/doc/SeDuMi_Guide_105R5.pdf
% This script solves the SDP relaxation problem:
%   minimise     sum((N+2-k)*(x(k)^2)        for k=1:(N+1)
%   subject to   sum(x(l)*x(l+k-1)) >= r(k)  for l=1:(N+2-k)
%                XX=[X x; x' 1] > 0          for X=x*(x')
% For example, with N=2 and k=1:(N+1), the function to be minimised is:
%   sum(((N+1):-1:1).*(x(1:N+1).^2))
% and the inequality constraints are:
%   ones(1,3)*[x(1)*x(1) x(1)*x(2) x(1)*x(3); ... 
%              x(2)*x(2) x(2)*x(3) 0        ; ... 
%              x(3)*x(3) 0         0        ;] >= [r(3) r(2) r(1)]
% and the vectorised SDP constraint is applied to:
%   XX = [1     x(1)      x(2)      x(3)      ; ...
%         x(1)  x(1)*x(1) x(1)*x(2) x(1)*x(3) ; ...
%         x(2)  x(2)*x(1) x(2)*x(2) x(2)*x(3) ; ...
%         x(3)  x(3)*x(1) x(3)*x(2) x(3)*x(3) ;]
% The corresponding vector of unknowns is:
%   [x(1)      x(2)      x(3)       ...
%    x(1)*x(1) x(2)*x(2) x(3)*x(3)  ...
%    x(1)*x(2) x(2)*x(3)            ...
%    x(1)*x(3)]'
% Section V of "Use SeDuMi to Solve LP, SDP and SCOP Problems: Remarks
% and Examples" by W. S. Lu (available at
% http://www.ece.uvic.ca/~wslu/Talk/SeDuMi-Remarks.pdf ) show how to
% set up this problem for solution with SeDuMi. 

test_common;

delete("directFIRnonsymmetric_sdp_minimum_phase_test.diary");
delete("directFIRnonsymmetric_sdp_minimum_phase_test.diary.tmp");
diary directFIRnonsymmetric_sdp_minimum_phase_test.diary.tmp

strf="directFIRnonsymmetric_sdp_minimum_phase_test";

% Design a low-pass filter
N=20;fap=0.1;fas=0.15;
h=remez(N,[0 fap fas 0.5]*2,[1 1 0 0]);
h=h(:);
rh=conv(h,flipud(h));

nplot=1024;
[H,w]=freqz(h,1,nplot);
plot(w*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_h_response"),"-dpdflatex");
close();

option_SDP_relaxation=false;
if option_SDP_relaxation
  
  % Set up SeDuMi linear constraints
  N1N4=(N+1)*(N+4)/2;
  A=zeros(N+1,N1N4);
  NS=N+2;
  for k=1:(N+1)
    A(k,(NS:(NS+N+1-k)))=ones(N+2-k,1);
    NS=NS+N+1-k+1;
  endfor
  b=rh((N+1):-1:1);

  % Set up SeDuMi SDP constraints
  F=zeros(N+2,N+2);
  F0=F;
  F0(1,1)=1;
  ct=vec(F0);
  At=zeros((N+2)^2,N1N4);
  for k=1:(N+1)
    Fk=F;
    Fk(1,k+1)=1;
    Fk(k+1,1)=1;
    At(:,k)=vec(Fk);
  endfor
  for k=1:(N+1)
    for l=1:(N+2-k);
      Fk=F;
      Fk(l+k,l+1)=1;
      Fk(l+1,l+k)=1;
      At(:,N+k+l)=vec(Fk);
    endfor
  endfor

  % Call SeDuMi
  Att=-[A;At];
  btt=-[zeros(1,N+1),((N+1):-1:1),zeros(1,N*(N+1)/2)]';
  ctt=-[b;ct]';
  K.l=N+1;
  K.s=N+2;
  pars.fid = 0;
  [x,y,info] = sedumi(Att,btt,ctt,K,pars);

  % Recover the positive definite matrix
  XX=diag(x(1:(N+1)));
  NS=N+2;
  for k=1:N
    XX=XX+diag(x(NS:(NS+N-k)),k)+diag(x(NS:(NS+N-k)),-k);
    NS=NS+N-k+1;
  endfor
  XX=[1 x(1:N+1)';x(1:N+1) XX];
  printf("isdefinite(XX)=%d\n",isdefinite(XX));
  
else

  % Set up SeDuMi linear constraints
  N1N2=(N+1)*(N+2)/2;
  A=zeros(N+1,N1N2);
  NS=1;
  for k=1:(N+1)
    A(k,(NS:(NS+N+1-k)))=ones(N+2-k,1);
    NS=NS+N+1-k+1;
  endfor
  b=rh((N+1):-1:1);

  % Set up SeDuMi SDP constraints
  F=zeros(N+1,N+1);
  ct=vec(F);
  At=zeros((N+1)^2,N1N2);
  for k=1:(N+1)
    for l=1:(N+2-k);
      Fk=F;
      Fk(l+k-1,l)=1;
      Fk(l,l+k-1)=1;
      At(:,k+l-1)=vec(Fk);
    endfor
  endfor

  % Call SeDuMi
  Att=-[A;At];
  btt=-[((N+1):-1:1),zeros(1,N*(N+1)/2)]';
  ctt=-[b;ct]';
  K.l=N+1;
  K.s=N+1;
  pars.fid = 0;
  [x,y,info] = sedumi(Att,btt,ctt,K,pars);

  % Recover the positive definite matrix
  XX=diag(x(1:(N+1)));
  NS=N+2;
  for k=1:N
    XX=XX+diag(x(NS:(NS+N-k)),k)+diag(x(NS:(NS+N-k)),-k);
    NS=NS+N-k+1;
  endfor
  printf("isdefinite(XX)=%d\n",isdefinite(XX));
  
endif

% Compare solutions
printf("info.numerr = %d\n",info.numerr);
printf("info.dinf   = %d\n",info.dinf);
printf("info.pinf   = %d\n",info.pinf);
printf("btt'*y=%g\n",btt'*y);
printf("ctt(:)'*x=%g\n",ctt(:)'*x);

% Plot solution
g=x(1:(N+1));
g=g/sum(g);
nplot=1024;
[G,w]=freqz(g,1,nplot);
plot(w*0.5/pi,20*log10(abs(G)));
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_g_response"),"-dpdflatex");
close();

% Save the filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"N=%d %% filter order\n",N);
fprintf(fid,"fap=%g %% Pass band amplitude response edge\n",fap);
fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
fclose(fid);

% Save results
print_polynomial(h,"h",strcat(strf,"_h_coef.m"));
print_polynomial(g,"g",strcat(strf,"_g_coef.m"));
save directFIRnonsymmetric_sdp_minimum_phase_test.mat N fap fas h g

% Done
diary off
movefile directFIRnonsymmetric_sdp_minimum_phase_test.diary.tmp ...
         directFIRnonsymmetric_sdp_minimum_phase_test.diary;
