% iir_socp_slb_fir_lowpass_test.m
% Copyright (C) 2020 Robert G. Jenssen

test_common;

delete("iir_socp_slb_fir_lowpass_test.diary");
delete("iir_socp_slb_fir_lowpass_test.diary.tmp");
diary iir_socp_slb_fir_lowpass_test.diary.tmp

tic

tol=1e-4
ctol=1e-4
maxiter=10000
verbose=false

% Filter specifications
R=1;
N=56
fap=0.15
dBap=1
Wap=1
Wat=0.0001
ftp=0.15
td=15
tdr=1
Wtp=0.001
fas=0.2
dBas=50
Was=1

% Frequency vectors
n=1000;

% Desired frequency response
nap=ceil((n*fap)/0.5)+1;
nas=floor((n*fas)/0.5)+1;
fd=(0:(n-1))'*0.5/n;
wd=2*pi*fd;
Hd=[exp(-j*wd(1:nap)*td);zeros(n-nap,1)];
Wd=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Amplitude constraints
fa=(0:(n-1))'*0.5/n;
wa=2*pi*fa;
Ad=[ones(nap,1);zeros(n-nap,1)];
Adu=[ones(nas-1,1);(10^(-dBas/20))*ones(n-nas+1,1)];
Adl=[(10^(-dBap/20))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Sanity checks
nchka=[nap-1,nap,nap+1,nas-1,nas,nas+1]';
printf("fa(nchka)'=[ ");printf("%7.5g ",fa(nchka)');printf("];\n");
printf("Ad(nchka)=[ ");printf("%7.5g ",Ad(nchka)');printf("];\n");
printf("Adu(nchka)=[ ");printf("%7.5g ",Adu(nchka)');printf("];\n");
printf("Adl(nchka)=[ ");printf("%7.5g ",Adl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%7.5g ",Wa(nchka)');printf("];\n");

% Stop-band amplitude constraints
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
ft=(0:(ntp-1))'*0.5/n;
wt=2*pi*ft;
Td=td*ones(ntp,1);
Tdu=(td+(tdr/2))*ones(ntp,1);
Tdl=(td-(tdr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Sanity checks
nchkt=[1 2 ntp-1,ntp]';
printf("ft(nchkt)'=[ ");printf("%7.5g ",ft(nchkt)');printf("];\n");
printf("Td(nchkt)=[ ");printf("%7.5g ",Td(nchkt)');printf("];\n");
printf("Tdu(nchkt)=[ ");printf("%7.5g ",Tdu(nchkt)');printf("];\n");
printf("Tdl(nchkt)=[ ");printf("%7.5g ",Tdl(nchkt)');printf("];\n");
printf("Wt(nchkt)=[ ");printf("%7.5g ",Wt(nchkt)');printf("];\n");

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Common strings for output plots
strP=sprintf("%%s:fap=%g,dBap=%g,ftp=%g,td=%g,tdr=%g,fas=%g,dBas=%g,Was=%g",
             fap,dBap,ftp,td,tdr,fas,dBas,Was);
strf="iir_socp_slb_fir_lowpass_test";

% Initial coefficients
bi=remez(N,2*[0 fap fas 0.5],[1 1 0 0],[1 2]);

% Unconstrained minimisation
function intEH=ERROR_FIR(b,_wd,_Hd,_Wd)
  persistent wd Hd Wd
  persistent init_done=false
  % Sanity checks
  if (nargin ~= 1) && (nargin ~= 4)
    print_usage("intEH=ERROR_FIR(b[,wd,Hd,Wd])")
  endif
  if nargin == 4
    wd=_wd;Hd=_Hd;Wd=_Wd;
    if (length(wd) ~= length(Hd))
      error("Expected length(wd) == length(Hd)!");
    endif
    if (length(wd) ~= length(Wd))
      error("Expected length(wd) == length(Wd)!");
    endif
    init_done=true;
    if (nargout == 0) || isempty(b)
      return;
    endif
  endif
  % Trapezoidal integration of response error
  H = freqz(b, 1, wd);
  EH = Wd.*(abs(H-Hd).^2);
  intEH = sum(diff(wd).*(EH(1:(end-1))+EH(2:end)))/2;
endfunction

ERROR_FIR([],wd,Hd,Wd);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[b0,FVEC,INFO,OUTPUT]=fminunc(@ERROR_FIR,bi,opt);
if (INFO == 1)
  printf("Converged to a solution point.\n");
elseif (INFO == 2)
  printf("Last relative step size was less that TolX.\n");
elseif (INFO == 3)
  printf("Last relative decrease in function value was less than TolF.\n");
elseif (INFO == 0)
  printf("Iteration limit exceeded.\n");
elseif (INFO == -3)
  printf("The trust region radius became excessively small.\n");
else
  error("Unknown INFO value.\n");
endif
printf("Function value=%f\n", FVEC);
printf("fminunc iterations=%d\n", OUTPUT.iterations);
printf("fminunc successful=%d??\n", OUTPUT.successful);
printf("fminunc funcCount=%d\n", OUTPUT.funcCount);

% Convert b0 to gain-pole-zero form
[x0,U,V,M,Q]=tf2x(b0,1,tol);
print_pole_zero(x0,U,V,M,Q,R,"x0");
strt=sprintf(strP,"x0");
showZPplot(x0,U,V,M,Q,R,strt);
print(strcat(strf,"_initial_x0pz"),"-dpdflatex");
close
showResponse(x0,U,V,M,Q,R,strt);
subplot(212)
axis([0 0.5 0 2*td]);
print(strcat(strf,"_initial_x0"),"-dpdflatex");
close
showResponsePassBands(0,fap,-3,3,x0,U,V,M,Q,R,strt);
print(strcat(strf,"_initial_x0pass"),"-dpdflatex");
close

% Coefficient constraints
[xl,xu]=xConstraints(U,V,M,Q);
dmax=inf;

% MMSE pass
[x1,Ex1,socp_iter,func_iter,feasible] = ...
  iir_socp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
                wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,...
                wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
                maxiter,tol,verbose);
if ~feasible 
  error("x1 infeasible");
endif
print_pole_zero(x1,U,V,M,Q,R,"x1");
strt=sprintf(strP,"x1(MMSE)");
showZPplot(x1,U,V,M,Q,R,strt);
print(strcat(strf,"_mmse_x1pz"),"-dpdflatex");
close
showResponse(x1,U,V,M,Q,R,strt);
subplot(212)
axis([0 0.5 0 2*td]);
print(strcat(strf,"_mmse_x1"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-2,1,x1,U,V,M,Q,R,strt);
print(strcat(strf,"_mmse_x1pass"),"-dpdflatex");
hold off
close

% PCLS pass
[d1,Ed1,slb_iter,socp_iter,func_iter,feasible] = ...
  iir_slb(@iir_socp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,...
          wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
          maxiter,tol,ctol,verbose);
if ~feasible 
  error("d1 infeasible");
endif
strt=sprintf(strP,"d1(PCLS)");
showZPplot(d1,U,V,M,Q,R,strt);
print(strcat(strf,"_pcls_d1pz"),"-dpdflatex");
close
showResponse(d1,U,V,M,Q,R,strt);
subplot(212)
axis([0 0.5 0 2*td]);
print(strcat(strf,"_pcls_d1"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-2*dBap,dBap,d1,U,V,M,Q,R,strt);
print(strcat(strf,"_pcls_d1pass"),"-dpdflatex");
close

% Final amplitude at constraints
A=iirA(wa,d1,U,V,M,Q,R);
vAl=local_max(Adl-A);
vAu=local_max(A-Adu);
S=iirA(ws,d1,U,V,M,Q,R);
vSl=local_max(Sdl-S);
vSu=local_max(S-Sdu);
wAS=unique([wa(vAl);wa(vAu);ws(vSu);ws(vSl)]);
AS=iirA(wAS,d1,U,V,M,Q,R);
printf("d1:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:AS=[ ");printf("%f ",20*log10(AS'));printf(" ] (dB)\n");

% Final group-delay at constraints
T=iirT(wt,d1,U,V,M,Q,R);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wa(vTu)]);
TS=iirT(wTS,d1,U,V,M,Q,R);
printf("d1:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:TS=[ ");printf("%f ",TS');printf(" ] (samples)\n");

% Save results
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"U=%d %% Number of real zeros\n",U);
fprintf(fid,"V=%d %% Number of real poles\n",V);
fprintf(fid,"M=%d %% Number of complex zeros\n",M);
fprintf(fid,"Q=%d %% Number of complex poles\n",Q);
fprintf(fid,"R=%d %% Denominator polynomial decimation factor\n",R);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"tol=%g %% Tolerance on relative coefficient update size\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"fap=%g %% Pass band amplitude response edge\n",fap);
fprintf(fid,"dBap=%d %% Pass band amplitude peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Pass band amplitude weight\n",Wap);
fprintf(fid,"Wat=%d %% Transition band amplitude weight\n",Wat);
fprintf(fid,"ftp=%g %% Pass band group-delay response edge\n",ftp);
fprintf(fid,"td=%d %% Pass band group-delay\n",td);
fprintf(fid,"tdr=%d %% Pass band amplitude peak-to-peak ripple\n",tdr);
fprintf(fid,"Wtp=%d %% Pass band group-delay weight\n",Wtp);
fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
fprintf(fid,"dBas=%d %% Stop band minimum attenuation\n",dBas);
fprintf(fid,"Was=%d %% Stop band amplitude weight\n",Was);
fclose(fid);
print_pole_zero(d1,U,V,M,Q,R,"d1",strcat(strf,"_d1_coef.m"),"%11.8f");
[N1,D1]=x2tf(d1,U,V,M,Q,R);
print_polynomial(N1,"N1",strcat(strf,"_N1_coef.m"),"%11.8f");
print_polynomial(D1,"D1",strcat(strf,"_D1_coef.m"),"%11.8f");

% Done
toc;
save iir_socp_slb_fir_lowpass_test.mat N U V M Q R tol ctol ...
     fap dBap Wap ftp td tdr Wtp fas dBas Was bi b0 x0 d1

diary off
movefile iir_socp_slb_fir_lowpass_test.diary.tmp ...
         iir_socp_slb_fir_lowpass_test.diary;
