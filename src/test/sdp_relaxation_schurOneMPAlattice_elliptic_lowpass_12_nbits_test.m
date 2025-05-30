% sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_12_nbits_test.m
% Copyright (C) 2023-2025 Robert G. Jenssen

% SDP relaxation optimisation of a Schur parallel one-multiplier allpass
% lattice elliptic lowpass filter with 12-bit signed-digit coefficients each
% having 4 signed-digits.

test_common;

strf="sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_12_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

verbose=false;
ftol=1e-5
ctol=1e-8
maxiter=500

nbits=12;
nscale=2^(nbits-1);
ndigits=4;

dmax=inf;
rho=127/128

% Lowpass filter specification
fap=0.15
dBap=0.1
Wap=1
Wat=ftol
fas=0.18
dBas=70
Was=1e7

% Initial elliptic filter passband edge 0.15, passband ripple 0.02dB,
% and 84dB stopband attenuation. Resulting stopband edge is approx 0.17074.
[B,A]=ellip(11,0.02,84,2*0.15);

% Lattice decomposition of Da1 and Db1
[Da1,Db1]=tf2pa(B,A);
[A1k0,A1epsilon0,A1p0,~] = tf2schurOneMlattice(flipud(Da1(:)),Da1(:));
[A2k0,A2epsilon0,A2p0,~] = tf2schurOneMlattice(flipud(Db1(:)),Db1(:));
difference=false;

% Initialise coefficient range vectors
A1p_ones=ones(size(A1p0));
A2p_ones=ones(size(A2p0));
NA1k=length(A1k0);
NA2k=length(A2k0);
RA1k=1:NA1k;
RA2k=(NA1k+1):(NA1k+NA2k);

% Desired squared magnitude response
n=1000;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
wa=(0:(n-1))'*pi/n;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Sanity checks
nchka=[nap-1,nap,nap+1,nas-1,nas,nas+1]';
printf("0.5*wa(nchka)'/pi=[ ");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Group delay
wt=[];Td=[];Tdu=[];Tdl=[];Wt=[];

% Phase
wp=[];Pd=[];Pdu=[];Pdl=[];Wp=[];

% dAsqdw
wd=[];Dd=[];Ddu=[];Ddl=[];Wd=[];

% Linear constraints
k0=[A1k0(:);A2k0(:)];
k0_active=find(k0~=0);
k0_u=rho*ones(size(k0));
k0_l=-k0_u;

% Find initial mean-squared errror
Esq0=schurOneMPAlatticeEsq(A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                           difference,wa,Asqd,Wa)
printf("Initial Esq0=%g\n",Esq0);

% Allocate digits
ndigits_alloc=zeros(size(k0));
ndigits_alloc(k0_active)=ndigits;
k0_allocsd_digits=int16(ndigits_alloc);
printf("k0_allocsd_digits=[ ");printf("%2d ",k0_allocsd_digits);printf("]';\n");
print_polynomial(k0_allocsd_digits(RA1k),"A1k0_allocsd_digits", ...
                 strcat(strf,"_A1k0_allocsd.m"),"%2d");
print_polynomial(k0_allocsd_digits(RA2k),"A2k0_allocsd_digits", ...
                 strcat(strf,"_A2k0_allocsd.m"),"%2d");

% Find the signed-digit approximations to A1k0 and A2k0
[k0_sd,k0_sdu,k0_sdl]=flt2SD(k0,nbits,ndigits_alloc);
[k0_sd_digits,k0_sd_adders]=SDadders(k0_sd,nbits);
A1k0_sd=k0_sd(RA1k);
A2k0_sd=k0_sd(RA2k);
print_polynomial(A1k0_sd,"A1k0_sd",nscale);
print_polynomial(A1k0_sd,"A1k0_sd",strcat(strf,"_A1k0_sd_coef.m"),nscale);
print_polynomial(A2k0_sd,"A2k0_sd",nscale);
print_polynomial(A2k0_sd,"A2k0_sd",strcat(strf,"_A2k0_sd_coef.m"),nscale);

% Signed-digit MMSE error
Esq0_sd=schurOneMPAlatticeEsq(A1k0_sd,A1epsilon0,A1p_ones, ...
                              A2k0_sd,A2epsilon0,A2p_ones, ... 
                              difference,wa,Asqd,Wa);
printf("Esq0_sd=%g\n",Esq0_sd);

% Solve the SDP problem with SeDuMi for all coefficients simultaneously
k0_sd_delta=(k0_sdu-k0_sdl)/2;
k0_sd_x=(k0_sdu+k0_sdl)/2;
k0_sd_active=find((k0_sd_x)~=0);
[A1k0_sdp,A2k0_sdp,sdp_iter,func_iter,feasible] = ...
  schurOneMPAlattice_sdp_mmse ...
    ([], ...
     k0_sd_x(RA1k),A1epsilon0,A1p0,k0_sd_x(RA2k),A2epsilon0,A2p0, ...
     difference, ...
     k0_sdu,k0_sdl,k0_sd_active,k0_sd_delta,...
     wa,Asqd,Asqdu,Asqdl,Wa, ...
     wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd,...
     maxiter,ftol,ctol,verbose);
if feasible==false
  error("schurOneMPAlattice_sdp_mmse failed!");
endif
k0_sdp=[A1k0_sdp(:);A2k0_sdp(:)];
[k0_sdp_digits,k0_sdp_adders]=SDadders(k0_sdp,nbits);
print_polynomial(A1k0_sdp,"A1k0_sdp",nscale);
print_polynomial(A1k0_sdp,"A1k0_sdp",strcat(strf,"_A1k0_sdp_coef.m"),nscale);
print_polynomial(A2k0_sdp,"A2k0_sdp",nscale);
print_polynomial(A2k0_sdp,"A2k0_sdp",strcat(strf,"_A2k0_sdp_coef.m"),nscale);

% SDP signed-digit MMSE error
Esq0_sdp=schurOneMPAlatticeEsq(A1k0_sdp,A1epsilon0,A1p_ones, ...
                               A2k0_sdp,A2epsilon0,A2p_ones, ...
                               difference, ...
                               wa,Asqd,Wa);

% Find coefficients with successive relaxation
k=zeros(size(k0));
k(k0_sd_active)=k0(k0_sd_active);
k_active=k0_sd_active;
k_hist=zeros(length(k_active));
k_active_max_n_hist=[];

% Fix one coefficient at each iteration 
while 1
  
  % Find the signed-digit filter coefficients 
  [k_sd,k_sdu,k_sdl]=flt2SD(k,nbits,ndigits);
  
  % Find the SDP solution for the current coefficients
  k_delta=(k_sdu-k_sdl)/2;
  k_active=find((k_delta)~=0);
  k_sd_x=k;
  k_sd_x(k_active)=(k_sdu(k_active)+k_sdl(k_active))/2;
  [A1k_sdp,A2k_sdp,socp_iter,func_iter,feasible] = ...
    schurOneMPAlattice_sdp_mmse ...
      ([], ...
       k_sd_x(RA1k),A1epsilon0,A1p0,k_sd_x(RA2k),A2epsilon0,A2p0, ...
       difference, ...
       k_sdu,k_sdl,k_active,k_delta, ...
       wa,Asqd,Asqdu,Asqdl,Wa, ...
       wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
       maxiter,ftol,ctol,verbose);
  if feasible==false
    error("schurOneMPAlattice_sdp_mmse failed!");
  endif

  % Ito et al. suggest ordering the search by max(k_sdu-k_sdl)
  [k_max,k_max_n]=max(k_delta(k_active));
  coef_n=k_active(k_max_n);

  % Fix the coefficient with the largest k_sdul to the SDP value
  k_sdp=[A1k_sdp(:);A2k_sdp(:)];
  k(coef_n)=k_sdp(coef_n);
  k_active_max_n_hist=[k_active_max_n_hist,k_active(k_max_n)]
  k_hist(:,length(k_active_max_n_hist))=k;
  k_active(k_max_n)=[];
  printf("\nFixed k(%d)=%g/%d\n",coef_n,k(coef_n)*nscale,nscale);
  printf("k=[ ");printf("%g ",k'*nscale);printf("]/%d;\n",nscale);
  printf("k_active=[ ");printf("%d ",k_active);printf("];\n\n");
  
  % Check if done
  if length(k_active)==0
    k_min=k;
    break;
  endif
  
  % Relaxation: try to solve the SOCP problem for the active coefficients
  try
    [nextA1k,nextA2k,slb_iter,opt_iter,func_iter,feasible] = ...
       schurOneMPAlattice_slb(@schurOneMPAlattice_socp_mmse, ...
                              k(RA1k),A1epsilon0,A1p0, ...
                              k(RA2k),A2epsilon0,A2p0, ...
                              difference, ...
                              k0_u,k0_l,k_active,dmax, ...
                              wa,Asqd,Asqdu,Asqdl,Wa, ...
                              wt,Td,Tdu,Tdl,Wt, ...
                              wp,Pd,Pdu,Pdl,Wp, ...
                              wd,Dd,Ddu,Ddl,Wd, ...
                              maxiter,ftol,ctol,verbose);
    k=[nextA1k(:);nextA2k(:)];
  catch
    feasible=false;
    err=lasterror();
    fprintf(stderr,"%s\n", err.message);
    for e=1:length(err.stack)
      fprintf(stderr,"Called %s at line %d\n", ...
              err.stack(e).name,err.stack(e).line);
    endfor
  end_try_catch

  % If this problem was not solved then give up
  if ~feasible
    error("SOCP problem infeasible!");
  endif

endwhile

% Adders
[k_min_digits,k_min_adders]=SDadders(k_min,nbits);
printf("%d signed-digits used\n",k_min_digits);
fid=fopen(strcat(strf,"_k_min_digits.tab"),"wt");
fprintf(fid,"$%d$",k_min_digits);
fclose(fid);
printf("%d %d-bit adders used for coefficient multiplications\n", ...
       k_min_adders,nbits);
fid=fopen(strcat(strf,"_k_min_adders.tab"),"wt");
fprintf(fid,"$%d$",k_min_adders);
fclose(fid);
% Coefficients
A1k_min=k_min(RA1k);
A2k_min=k_min(RA2k);
print_polynomial(A1k_min,"A1k_min",nscale);
print_polynomial(A1k_min,"A1k_min",strcat(strf,"_A1k_min_coef.m"),nscale);
print_polynomial(A2k_min,"A2k_min",nscale);
print_polynomial(A2k_min,"A2k_min",strcat(strf,"_A2k_min_coef.m"),nscale);

% k_min signed-digit MMSE error
Esq_min=schurOneMPAlatticeEsq(A1k_min,A1epsilon0,A1p0, ...
                              A2k_min,A2epsilon0,A2p0, ...
                              difference,wa,Asqd,Wa);

% Calculate response
Asq_k0=schurOneMPAlatticeAsq(wa,A1k0,A1epsilon0,A1p0, ...
                             A2k0,A2epsilon0,A2p0,difference);
Asq_k0_sd=schurOneMPAlatticeAsq(wa,A1k0_sd,A1epsilon0,A1p_ones, ...
                                A2k0_sd,A2epsilon0,A2p_ones,difference);
Asq_k0_sdp=schurOneMPAlatticeAsq(wa,A1k0_sdp,A1epsilon0,A1p_ones, ...
                                 A2k0_sdp,A2epsilon0,A2p_ones,difference);
Asq_k_min=schurOneMPAlatticeAsq(wa,A1k_min,A1epsilon0,A1p_ones, ...
                                A2k_min,A2epsilon0,A2p_ones,difference);

% Amplitude and delay at local peaks
vAl=local_max(Asqdl-Asq_k_min);
vAu=local_max(Asq_k_min-Asqdu);
wAsqS=wa(unique([vAl;vAu;1;end]));
AsqS=Asq_k_min(unique([vAl;vAu;1;end]));
printf("k_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

% Find maximum pass band response
rpb=[1:nap];
max_pb_Asq_k0=10*log10(max(abs(Asq_k0(rpb))))
max_pb_Asq_k0_sd=10*log10(max(abs(Asq_k0_sd(rpb))))
max_pb_Asq_k0_sdp=10*log10(max(abs(Asq_k0_sdp(rpb))))
max_pb_Asq_k_min=10*log10(max(abs(Asq_k_min(rpb))))
% Find minimum pass band response
min_pb_Asq_k0=10*log10(min(abs(Asq_k0(rpb))))
min_pb_Asq_k0_sd=10*log10(min(abs(Asq_k0_sd(rpb))))
min_pb_Asq_k0_sdp=10*log10(min(abs(Asq_k0_sdp(rpb))))
min_pb_Asq_k_min=10*log10(min(abs(Asq_k_min(rpb))))
% Find maximum stop band response
rsb=[nas:n];
max_sb_Asq_k0=10*log10(max(abs(Asq_k0(rsb))))
max_sb_Asq_k0_sd=10*log10(max(abs(Asq_k0_sd(rsb))))
max_sb_Asq_k0_sdp=10*log10(max(abs(Asq_k0_sdp(rsb))))
max_sb_Asq_k_min=10*log10(max(abs(Asq_k_min(rsb))))

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Initial & %7.2e & %4.1f & & \\\\\n",Esq0,max_sb_Asq_k0);
fprintf(fid,"%d-bit %d-signed-digit & %7.2e & %4.1f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_sd,max_sb_Asq_k0_sd,k0_sd_digits,k0_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(SDP) & %7.2e & %4.1f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_sdp,max_sb_Asq_k0_sdp,k0_sdp_digits,k0_sdp_adders);
fprintf(fid,"%d-bit %d-signed-digit(min) & %7.2e & %4.1f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq_min,max_sb_Asq_k_min,k_min_digits,k_min_adders);
fclose(fid);

% Plot stop band amplitude response
plot(wa*0.5/pi,10*log10(abs(Asq_k0)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd)),"linestyle",":", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sdp)),"linestyle","--", ...
     wa*0.5/pi,10*log10(abs(Asq_k_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([fap, 0.5, -100, -40]);
strt=sprintf(["Parallel allpass lattice elliptic lowpass filter stop-band ", ...
 "(nbits=%d,ndigits=%d) : fas=%g"],nbits,ndigits,fas);
title(strt);
legend("Initial","s-d","s-d(SDP)","s-d(min)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_stop"),"-dpdflatex");
close

% Plot pass band amplitude response
plot(wa*0.5/pi,10*log10(abs(Asq_k0)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd)),"linestyle",":", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sdp)),"linestyle","--", ...
     wa*0.5/pi,10*log10(abs(Asq_k_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0, fas, -0.10, 0.02]);
strt=sprintf(["Parallel allpass lattice elliptic lowpass filter pass-band ", ...
 "amplitude nbits=%d,ndigits=%d) : fap=%g"],nbits,ndigits,fap);
title(strt);
legend("Initial","s-d","s-d(SDP)","s-d(min)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_pass"),"-dpdflatex");
close

% Dual plot of amplitude response
Rfap=1:(nap+50);
wap=wa(Rfap);
Asq_k0_wap=Asq_k0(Rfap);
Asq_k0_sd_wap=Asq_k0_sd(Rfap);
Asq_k0_sdp_wap=Asq_k0_sdp(Rfap);
Asq_k_min_wap=Asq_k_min(Rfap);
Rfas=(nas-50):n;
was=wa(Rfas);
Asq_k0_was=Asq_k0(Rfas);
Asq_k0_sd_was=Asq_k0_sd(Rfas);
Asq_k0_sdp_was=Asq_k0_sdp(Rfas);
Asq_k_min_was=Asq_k_min(Rfas);
[ax,h1,h2]=plotyy(wap*0.5/pi,10*log10([Asq_k0_wap,Asq_k0_sd_wap, ...
                                       Asq_k0_sdp_wap,Asq_k_min_wap]),...
                  was*0.5/pi,10*log10([Asq_k0_was,Asq_k0_sd_was, ...
                                       Asq_k0_sdp_was,Asq_k_min_was]));
% Hack to set line colour and style 
h1c=get(h1,"color");
for c=1:4
  set(h2(c),"color",h1c{c});
endfor
set(h1(1),"linestyle","-");
set(h1(2),"linestyle",":");
set(h1(3),"linestyle","--");
set(h1(4),"linestyle","-.");
set(h2(1),"linestyle","-");
set(h2(2),"linestyle",":");
set(h2(3),"linestyle","--");
set(h2(4),"linestyle","-.");
axis(ax(1),[0, 0.5, -0.1, 0.02]);
axis(ax(2),[0, 0.5, -100, -40]);
ylabel(ax(1),"Amplitude(dB)");
ylabel(ax(2),"Amplitude(dB)");
% End of hack
xlabel("Frequency");
grid("on");
legend("Initial","s-d","s-d(SDP)","s-d(min)");
legend("location","northeast");
legend("boxoff");
legend("left");
strt=sprintf(["Parallel allpass lattice elliptic lowpass filter ", ...
 "amplitude nbits=%d,ndigits=%d) : fap=%g, fas=%g"],nbits,ndigits,fap,fas);
title(strt);
grid("on");
print(strcat(strf,"_dual"),"-dpdflatex"); 
close

% Plot coefficient histories
plot(0:length(k0),([k0,k_hist]-k0)'*nscale);
axis([0 length(k0)]);
title(sprintf(["Parallel allpass lattice elliptic lowpass filter : ", ...
 "%d bit %d signed-digit coefficient difference from exact"], nbits,ndigits));
xlabel("Relaxation step");
ylabel("Bits difference from exact");
str_active=sprintf("The coefficients [A1k,A2k] were fixed in the order : %d", ...
                   k_active_max_n_hist(1));
for l=2:length(k_active_max_n_hist)
  str_active=strcat(str_active, sprintf(", %d",k_active_max_n_hist(l)));
endfor
text(0.5,-140,str_active,"fontsize",8);
print(strcat(strf,"_coef_hist"),"-dpdflatex"); 
close
      
% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coefficient update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"difference=%d %% Use difference of all-pass filters\n",difference);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"m1=%d %% All-pass filter 1 order\n",NA1k-1);
fprintf(fid,"m2=%d %% All-pass filter 2 order\n",NA2k-1);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%g %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fclose(fid);

% Save results
eval(sprintf(["save %s.mat ftol ctol nbits nscale ndigits ndigits_alloc ", ...
              "n fap dBap Wap fas dBas Was ", ...
              "A1k0 A1epsilon0 A1p0 A2k0 A2epsilon0 A2p0 ", ...
              "A1k0_sd A2k0_sd A1k0_sdp A2k0_sdp A1k_min A2k_min"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
