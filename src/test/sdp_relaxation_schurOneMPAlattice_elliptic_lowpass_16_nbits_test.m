% sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.m
% Copyright (C) 2019-2024 Robert G. Jenssen

% SDP relaxation optimisation of a Schur parallel one-multiplier allpass
% lattice elliptic lowpass filter with 16-bit signed-digit coefficients having
% an average of 5 signed-digits

test_common;

strf="sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

eval(strcat(strf,"_allocsd_Lim=false"));
eval(strcat(strf,"_allocsd_Ito=true"));

tic;

% Pass separate tolerances for the coefficient step and SeDuMi eps.
ftol=1e-8
ctol=2e-10
del.dtol=ctol;
del.stol=ctol;
warning("Using coef. delta tolerance=%g, SeDuMi eps=%g\n",del.dtol,del.stol);
maxiter=500
verbose=false;

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
NA1=length(A1k0);
NA2=length(A2k0);
R1=1:NA1;
R2=(NA1+1):(NA1+NA2);

% Lowpass filter specification
fap=0.15
fape=fap-0.05
dBap=0.06
Wap=1
Wape=1 % Extra passband weight increasing linearly from fape to fap
Wat=ftol
fas=0.171
fase=fas+0.05
dBas=78
Was=1e7
Wase=1 % Extra passband weight decreasing linearly from fas to fase

% Desired squared magnitude response
n=1000;
nape=floor(n*fape/0.5)+1;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
nase=ceil(n*fase/0.5)+1;
wa=(0:(n-1))'*pi/n;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];
Wae=[zeros(nape,1); ...
    Wape*((0:(nap-nape-1))'/(nap-nape)); ...
    Wat*ones(nas-nap-1,1)
    Wase*(((nase-nas-1):-1:0)'/(nase-nas)); ...
    zeros(n-nase+1,1)];

% Sanity checks
nchka=[nap-1,nap,nap+1,nas-1,nas,nas+1]';
printf("0.5*wa(nchka)'/pi=[ ");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");
printf("Wae(nchka)=[ ");printf("%6.4g ",Wae(nchka)');printf("];\n");

% Linear constraints
dmax=inf;
rho=127/128
k0=[A1k0(:);A2k0(:)];
k0_active=find(k0~=0);
k0_u=rho*ones(size(k0));
k0_l=-k0_u;

% Find initial mean-squared errror
Esq0=schurOneMPAlatticeEsq(A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                           difference,wa,Asqd,Wa)
printf("Initial Esq0=%g\n",Esq0);

% Allocate digits
nbits=16;
nscale=2^(nbits-1);
ndigits=5;
if sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test_allocsd_Lim
  ndigits_alloc=schurOneMPAlattice_allocsd_Lim ...
                  (nbits,ndigits,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                   difference,wa,Asqd,ones(size(Wa)));
elseif ...
  sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test_allocsd_Ito
    ndigits_alloc=schurOneMPAlattice_allocsd_Ito ...
                    (nbits,ndigits,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,...
                     difference,wa,Asqd,Wa);
else
  ndigits_alloc=zeros(size(k0));
  ndigits_alloc(k0_active)=ndigits;
endif
k0_allocsd_digits=int16(ndigits_alloc);
printf("k0_allocsd_digits=[ ");printf("%2d ",k0_allocsd_digits);printf("]';\n");
print_polynomial(k0_allocsd_digits(R1),"A1k0_allocsd_digits", ...
                 strcat(strf,"_A1k0_allocsd.m"),"%2d");
print_polynomial(k0_allocsd_digits(R2),"A2k0_allocsd_digits", ...
                 strcat(strf,"_A2k0_allocsd.m"),"%2d");

% Find the signed-digit approximations to A1k0 and A2k0
[k0_sd,k0_sdu,k0_sdl]=flt2SD(k0,nbits,ndigits_alloc);
[k0_digits_sd,k0_adders_sd]=SDadders(k0_sd,nbits);
A1k0_sd=k0_sd(R1);
A2k0_sd=k0_sd(R2);
Esq0_sd=schurOneMPAlatticeEsq(A1k0_sd,A1epsilon0,A1p_ones, ...
                              A2k0_sd,A2epsilon0,A2p_ones, ... 
                              difference,wa,Asqd,Wa)
print_polynomial(A1k0_sd,"A1k0_sd",nscale);
print_polynomial(A1k0_sd,"A1k0_sd", ...
                 strcat(strf,"_A1k0_sd_coef.m"),nscale);
print_polynomial(A2k0_sd,"A2k0_sd",nscale);
print_polynomial(A2k0_sd,"A2k0_sd", ...
                 strcat(strf,"_A2k0_sd_coef.m"),nscale);

% Solve the SDP problem with SeDuMi
k0_sd_delta=(k0_sdu-k0_sdl)/2;
k0_sd_x=(k0_sdu+k0_sdl)/2;
k0_sd_x_active=find((k0_sd_x)~=0);
[A1k0_sd_sdp,A2k0_sd_sdp,sdp_iter,func_iter,feasible] = ...
  sdp_relaxation_schurOneMPAlattice_mmse([], ...
                              k0_sd_x(R1),A1epsilon0,A1p0, ...
                              k0_sd_x(R2),A2epsilon0,A2p0, ...
                              difference,k0_u,k0_l,k0_sd_x_active,k0_sd_delta,...
                              wa,Asqd,Asqdu,Asqdl,Wa+Wae, ...
                              [],[],[],[],[],[],[],[],[],[],[],[],[],[],[], ...
                              maxiter,del,ctol,verbose);
if feasible==false
  error("sdp_relaxation_schurOneMPAlattice_mmse failed!");
endif
k0_sd_sdp=[A1k0_sd_sdp(:);A2k0_sd_sdp(:)];
[k0_digits_sd_sdp,k0_adders_sd_sdp]=SDadders(k0_sd_sdp,nbits);
Esq0_sd_sdp=schurOneMPAlatticeEsq(A1k0_sd_sdp,A1epsilon0,A1p_ones, ...
                                  A2k0_sd_sdp,A2epsilon0,A2p_ones, ...
                                  difference,wa,Asqd,Wa);
print_polynomial(A1k0_sd_sdp,"A1k0_sd_sdp",nscale);
print_polynomial(A1k0_sd_sdp,"A1k0_sd_sdp", ...
                 strcat(strf,"_A1k0_sd_sdp_coef.m"),nscale);
print_polynomial(A2k0_sd_sdp,"A2k0_sd_sdp",nscale);
print_polynomial(A2k0_sd_sdp,"A2k0_sd_sdp", ...
                 strcat(strf,"_A2k0_sd_sdp_coef.m"),nscale);

% Find coefficients with successive relaxation
k=zeros(size(k0));
k(k0_sd_x_active)=k0(k0_sd_x_active);
k_active=k0_sd_x_active;
k_hist=zeros(length(k_active));
k_active_max_n_hist=[];

% Fix one coefficient at each iteration 
while 1
  
  % Find the signed-digit filter coefficients 
  [k_sd,k_sdu,k_sdl]=flt2SD(k,nbits,ndigits);
  
  % Run the SeDuMi problem to find the SDP solution for the current coefficients
  k_sdul=k_sdu-k_sdl;
  k_sd_delta=k_sdul/2;
  k_sd_x=k_sdl+k_sd_delta;
  k_sd_x_active=find((k_sd_x)~=0);
  [A1k_sd_sdp,A2k_sd_sdp,socp_iter,func_iter,feasible] = ...
    sdp_relaxation_schurOneMPAlattice_mmse([], ...
                                k_sd_x(R1),A1epsilon0,A1p0, ...
                                k_sd_x(R2),A2epsilon0,A2p0, ...
                                difference, ...
                                k0_u,k0_l,k_sd_x_active,k_sd_delta, ...
                                wa,Asqd,Asqdu,Asqdl,Wa+Wae, ...
                                [],[],[],[],[],[],[],[],[],[],[],[],[],[],[], ...
                                maxiter,del,ctol,verbose);
  if feasible==false
    error("sdp_relaxation_schurOneMPAlattice_mmse failed!");
  endif

  % Ito et al. suggest ordering the search by max(k_sdu-k_sdl)
  [k_max,k_max_n]=max(k_sdul(k_active));
  coef_n=k_active(k_max_n);

  % Fix the coefficient with the largest k_sdul to the SDP value
  k_sd_sdp=[A1k_sd_sdp(:);A2k_sd_sdp(:)];
  k(coef_n)=k_sd_sdp(coef_n);
  k_active_max_n_hist=[k_active_max_n_hist,k_active(k_max_n)]
  k_hist(:,length(k_active_max_n_hist))=k;
  k_active(k_max_n)=[];
  printf("\nFixed k(%d)=%g/%d\n",coef_n,k(coef_n)*nscale,nscale);
  printf("k=[ ");printf("%g ",k'*nscale);printf("]/%d;\n",nscale);
  printf("k_active=[ ");printf("%d ",k_active);printf("];\n\n");
  
  % Check if done
  if length(k_active)==0
    k0_sd_min=k;
    % Adders
    [k0_digits_sd_min,k0_adders_sd_min]=SDadders(k0_sd_min,nbits);
    printf("%d signed-digits used\n",k0_digits_sd_min);
    printf("%d %d-bit adders used for coefficient multiplications\n",
           k0_adders_sd_min,nbits);
    fid=fopen(strcat(strf,"_kmin_digits.tab"),"wt");
    fprintf(fid,"$%d$",k0_digits_sd_min);
    fclose(fid);
    fid=fopen(strcat(strf,"_kmin_adders.tab"),"wt");
    fprintf(fid,"$%d$",k0_adders_sd_min);
    fclose(fid);
    % Coefficients
    A1k0_sd_min=k0_sd_min(R1);
    A2k0_sd_min=k0_sd_min(R2);
    Esq0_sd_min=schurOneMPAlatticeEsq(A1k0_sd_min,A1epsilon0,A1p0, ...
                                      A2k0_sd_min,A2epsilon0,A2p0, ...
                                      difference,wa,Asqd,Wa);
    print_polynomial(A1k0_sd_min,"A1k0_sd_min",nscale);
    print_polynomial(A1k0_sd_min,"A1k0_sd_min", ...
                     strcat(strf,"_A1k0_sd_min_coef.m"),nscale);
    print_polynomial(A2k0_sd_min,"A2k0_sd_min",nscale);
    print_polynomial(A2k0_sd_min,"A2k0_sd_min", ...
                     strcat(strf,"_A2k0_sd_min_coef.m"),nscale);
    break;
  endif
  
  % Relaxation: try to solve the SOCP problem for the active coefficients
  try
    [nextA1k,nextA2k,slb_iter,opt_iter,func_iter,feasible] = ...
      schurOneMPAlattice_slb(@schurOneMPAlattice_socp_mmse, ...
                             k(R1),A1epsilon0,A1p0,k(R2),A2epsilon0,A2p0, ...
                             difference,k0_u,k0_l,k_active,dmax, ...
                             wa,Asqd,Asqdu,Asqdl,Wa+Wae, ...
                             [],[],[],[],[],[],[],[],[],[],[],[],[],[],[], ...
                             maxiter,del,ctol,verbose);
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


% Calculate response
Asq_k0=schurOneMPAlatticeAsq(wa,A1k0,A1epsilon0,A1p0, ...
                             A2k0,A2epsilon0,A2p0,difference);
Asq_k0_sd=schurOneMPAlatticeAsq(wa,A1k0_sd,A1epsilon0,A1p_ones, ...
                                A2k0_sd,A2epsilon0,A2p_ones,difference);
Asq_k0_sd_sdp=schurOneMPAlatticeAsq(wa,A1k0_sd_sdp,A1epsilon0,A1p_ones, ...
                                    A2k0_sd_sdp,A2epsilon0,A2p_ones,difference);
Asq_k0_sd_min=schurOneMPAlatticeAsq(wa,A1k0_sd_min,A1epsilon0,A1p_ones, ...
                                    A2k0_sd_min,A2epsilon0,A2p_ones,difference);

% Amplitude and delay at local peaks
vAl=local_max(Asqdl-Asq_k0_sd_min);
vAu=local_max(Asq_k0_sd_min-Asqdu);
wAsqS=wa(unique([vAl;vAu;1;end]));
AsqS=Asq_k0_sd_min(unique([vAl;vAu;1;end]));
printf("k0_sd_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k0_sd_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

% Find maximum pass band response
rpb=[1:nap];
max_pb_Asq_k0=10*log10(max(abs(Asq_k0(rpb))))
max_pb_Asq_k0_sd=10*log10(max(abs(Asq_k0_sd(rpb))))
max_pb_Asq_k0_sd_sdp=10*log10(max(abs(Asq_k0_sd_sdp(rpb))))
max_pb_Asq_k0_sd_min=10*log10(max(abs(Asq_k0_sd_min(rpb))))

% Find minimum pass band response
min_pb_Asq_k0=10*log10(min(abs(Asq_k0(rpb))))
min_pb_Asq_k0_sd=10*log10(min(abs(Asq_k0_sd(rpb))))
min_pb_Asq_k0_sd_sdp=10*log10(min(abs(Asq_k0_sd_sdp(rpb))))
min_pb_Asq_k0_sd_min=10*log10(min(abs(Asq_k0_sd_min(rpb))))

% Find maximum stop band response
rsb=[nas:n];
max_sb_Asq_k0=10*log10(max(abs(Asq_k0(rsb))))
max_sb_Asq_k0_sd=10*log10(max(abs(Asq_k0_sd(rsb))))
max_sb_Asq_k0_sd_sdp=10*log10(max(abs(Asq_k0_sd_sdp(rsb))))
max_sb_Asq_k0_sd_min=10*log10(max(abs(Asq_k0_sd_min(rsb))))

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Initial & %7.2e & %4.1f & & \\\\\n",Esq0,max_sb_Asq_k0);
fprintf(fid,"%d-bit %d-signed-digit(Ito) & %7.2e & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,max_sb_Asq_k0_sd,k0_digits_sd,k0_adders_sd);
fprintf(fid,"%d-bit %d-signed-digit(SDP) & %7.2e & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd_sdp,max_sb_Asq_k0_sd_sdp, ...
        k0_digits_sd_sdp,k0_adders_sd_sdp);
fprintf(fid,"%d-bit %d-signed-digit(min) & %7.2e & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd_min,max_sb_Asq_k0_sd_min, ...
        k0_digits_sd_min,k0_adders_sd_min);
fclose(fid);

% Plot stop band amplitude response
plot(wa*0.5/pi,10*log10(abs(Asq_k0)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd)),"linestyle",":", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd_sdp)),"linestyle","--", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([fap, 0.5, -100, -40]);
strt=sprintf("Parallel allpass lattice elliptic lowpass filter stop-band \
(nbits=%d,ndigits=%d) : fas=%g",nbits,ndigits,fas);
title(strt);
legend("Initial","s-d(Ito)","s-d(SDP)","s-d(min)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_stop"),"-dpdflatex");
close

% Plot pass band amplitude response
plot(wa*0.5/pi,10*log10(abs(Asq_k0)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd)),"linestyle",":", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd_sdp)),"linestyle","--", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0, fas, -0.10, 0.02]);
strt=sprintf("Parallel allpass lattice elliptic lowpass filter pass-band \
amplitude nbits=%d,ndigits=%d) : fap=%g",nbits,ndigits,fap);
title(strt);
legend("Initial","s-d(Ito)","s-d(SDP)","s-d(min)");
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
Asq_k0_sd_sdp_wap=Asq_k0_sd_sdp(Rfap);
Asq_k0_sd_min_wap=Asq_k0_sd_min(Rfap);
Rfas=(nas-50):n;
was=wa(Rfas);
Asq_k0_was=Asq_k0(Rfas);
Asq_k0_sd_was=Asq_k0_sd(Rfas);
Asq_k0_sd_sdp_was=Asq_k0_sd_sdp(Rfas);
Asq_k0_sd_min_was=Asq_k0_sd_min(Rfas);
[ax,h1,h2]=plotyy(wap*0.5/pi, ...
                  10*log10([Asq_k0_wap,Asq_k0_sd_wap, ...
                            Asq_k0_sd_sdp_wap,Asq_k0_sd_min_wap]),...
                  was*0.5/pi, ...
                  10*log10([Asq_k0_was,Asq_k0_sd_was, ...
                            Asq_k0_sd_sdp_was,Asq_k0_sd_min_was]));
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
legend("Initial","s-d(Ito)","s-d(SDP)","s-d(min)");
legend("location","northeast");
legend("boxoff");
legend("left");
strt=sprintf("Parallel allpass lattice elliptic lowpass filter \
amplitude nbits=%d,ndigits=%d) : fap=%g, fas=%g",nbits,ndigits,fap,fas);
title(strt);
grid("on");
print(strcat(strf,"_dual"),"-dpdflatex"); 
close

% Plot coefficient histories
plot(0:length(k0),([k0,k_hist]-k0)'*nscale);
axis([0 length(k0)]);
title(sprintf("Parallel allpass lattice elliptic lowpass filter : \
%d bit %d signed-digit coefficient difference from exact", nbits,ndigits));
xlabel("Relaxation step");
ylabel("Bits difference from exact");
str_active=sprintf("The coefficients [A1k,A2k] were fixed in the order : %d",
                   k_active_max_n_hist(1));
for l=2:length(k_active_max_n_hist)
  str_active=strcat(str_active, sprintf(", %d",k_active_max_n_hist(l)));
endfor
text(0.5,-140,str_active,'fontsize',8);
print(strcat(strf,"_coef_hist"),"-dpdflatex"); 
close
      
% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"difference=%d %% Use difference of all-pass filters\n",difference);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"m1=%d %% All-pass filter 1 order\n",NA1-1);
fprintf(fid,"m2=%d %% All-pass filter 2 order\n",NA2-1);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wape=%d %% Extra amplitude pass band weight\n",Wape);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%d %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fprintf(fid,"Wase=%d %% Extra amplitude stop band weight\n",Wase);
fclose(fid);

% Save results
eval(sprintf("save %s.mat \
      ftol ctol nbits nscale ndigits ndigits_alloc n fap dBap Wap fas dBas Was \
      A1k0 A1epsilon0 A1p0 A2k0 A2epsilon0 A2p0 \
      A1k0_sd A2k0_sd A1k0_sd_sdp A2k0_sd_sdp A1k0_sd_min A2k0_sd_min",strf));
       
% Done
toc;
diary off
movefile(sprintf("%s.diary.tmp",strf),sprintf("%s.diary",strf));
