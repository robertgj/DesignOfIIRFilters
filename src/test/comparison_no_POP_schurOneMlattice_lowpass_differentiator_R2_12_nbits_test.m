% comparison_no_POP_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test.m 
%
% Compare branch-and-bound, SOCP-relaxation and POP-relaxation search for the
% 12-bit, average of 3-signed-digit, coefficients of a low-pass differentiator
% filter implemented as the series combination of z=1 with a Schur
% one-multiplier lattice correction filter having transfer function denominator
% polynomial coefficients only in z^-2.
%
% Copyright (C) 2025 Robert G. Jenssen

test_common;

strs="schurOneMlattice_lowpass_differentiator_R2_12_nbits_test";
strf=strcat("comparison_no_POP_",strs);

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

nbits=12;
nscale=2^(nbits-1);
ndigits=3;

% Filter specification
nN=10; % Order of correction filter for (z-1)
R=2;   % Denominator polynomial in z^-2 only
fap=0.2;fas=0.4;Wap=1;Wat=0.0001;Was=1;
fpp=fap;pp=1.5;Wpp=1;
ftp=fap;tp=nN-1;Wtp=1;
fdp=fap;Wdp=1;

% Load filter coefficients
schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_k2_coef;
schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_epsilon2_coef;
schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_c2_coef;
exact_k=k2;
exact_epsilon=epsilon2;
exact_c=c2;
clear k2 epsilon2 c2 ;

eval(strcat("branch_bound_",strs,"_k_min_coef;"));
eval(strcat("branch_bound_",strs,"_c_min_coef;"));
bandb_k=k_min;
bandb_epsilon=exact_epsilon;
bandb_c=c_min;
[bandb_sd_digits,bandb_sd_adders]=SDadders([bandb_k;bandb_c],nbits);

eval(strcat("socp_relaxation_",strs,"_k_min_coef;"));
eval(strcat("socp_relaxation_",strs,"_epsilon_min_coef;"));
eval(strcat("socp_relaxation_",strs,"_c_min_coef;"));
socp_k=k_min;
socp_epsilon=epsilon_min;
socp_c=c_min;
[socp_sd_digits,socp_sd_adders]=SDadders([socp_k;socp_c],nbits);

p_ones=ones(size(exact_k));

clear k_min epsilon_min c_min ;

Nk=length(exact_k);
Nc=length(exact_c);
Rk=1:Nk;
Rc=(Nk+1):(Nk+Nc);

% Frequency points
n=1000;
f=(1:(n-1))'*0.5/n;
w=2*pi*f;
nap=ceil(fap*n/0.5);
nas=floor(fas*n/0.5);
Rap=1:nap;
Ras=nas:length(w);
npp=ceil(fpp*n/0.5);
ntp=ceil(ftp*n/0.5);
ndp=ceil(fdp*n/0.5);
Rap=1:nap;
Ras=nas:length(w);
Rpp=1:npp;
Rtp=1:ntp;
Rdp=1:ndp;

% Response of z=1
Azm1=2*sin(w/2);
Azm1sq=Azm1.^2;
dAzm1sqdw=2*sin(w);

% Pass and transition band amplitudes
wa=w;
Azm1=2*sin(wa/2);
Azm1sq=Azm1.^2;
dAzm1sqdw=2*sin(wa);
Ad=[wa(1:nap)/2;zeros(n-1-nap,1)];
Asqd=Ad.^2;
dAsqddw=Ad;
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas,1)];
% Sanity check
nachk=[1,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1];
printf("nachk=[");printf("%d ",nachk);printf(" ]\n");
printf("wa(nachk)*0.5/pi=[");printf("%g ",wa(nachk)*0.5/pi);printf(" ]\n");
printf("Ad(nachk)=[");printf("%g ",Ad(nachk));printf(" ]\n");
printf("Wa(nachk)=[");printf("%g ",Wa(nachk));printf(" ]\n");

% Phase
wp=w(Rpp);
Pzm1=(pi/2)-(wp/2);
Pd=(pi*pp)-(wp*tp);
Wp=Wpp*ones(size(wp));

% Group delay
wt=w(Rtp);
Tzm1=0.5;
Td=tp*ones(size(wt));
Wt=Wtp*ones(size(wt));

% dAsqdw 
wd=wa(Rdp);
Dd=dAsqddw(Rdp);
Wd=Wdp*ones(size(wd));
Cd=(Dd-(Asqd(Rdp).*cot(w(Rdp)/2)))./Azm1sq(Rdp);

%
% Allocate signed-digits
%
ndigits_alloc=schurOneMlattice_allocsd_Lim ...
                (nbits,ndigits,exact_k,exact_epsilon,p_ones,exact_c, ...
                 wa,Asqd./Azm1sq,Wa, ...
                 wt,Td-Tzm1,Wt, ...
                 wp,Pd-Pzm1,Wp, ...
                 wd,Cd,Wd);
k_allocsd_digits=int16(ndigits_alloc(Rk));
c_allocsd_digits=int16(ndigits_alloc(Rc));
printf("k_allocsd_digits=[ ");printf("%2d ",k_allocsd_digits);printf("]';\n");
print_polynomial(k_allocsd_digits,"k_allocsd_digits", ...
                 strcat(strf,"_k_allocsd_digits.m"),"%2d");
printf("c_allocsd_digits=[ ");printf("%2d ",c_allocsd_digits);printf("]';\n");
print_polynomial(c_allocsd_digits,"c_allocsd_digits", ...
                 strcat(strf,"_c_allocsd_digits.m"),"%2d");

% Find the signed-digit approximations to exact_k and exact_c
[sd_kc,sdu_kc,sdl_kc]=flt2SD([exact_k;exact_c],nbits,ndigits);
[sd_sd_digits,sd_sd_adders]=SDadders(sd_kc,nbits);
sd_k=sd_kc(Rk);
sd_epsilon=exact_epsilon;
sd_c=sd_kc(Rc);
print_polynomial(sd_k,"sd_k",nscale);
print_polynomial(sd_k,"sd_k",strcat(strf,"_sd_k_coef.m"),nscale);
print_polynomial(sd_c,"sd_c",nscale);
print_polynomial(sd_c,"sd_c",strcat(strf,"_sd_c_coef.m"),nscale);

[sd_Lim_kc,sdu_Lim_kc,sdl_Lim_kc]=flt2SD([exact_k;exact_c],nbits,ndigits_alloc);
[sd_Lim_sd_digits,sd_Lim_sd_adders]=SDadders(sd_Lim_kc,nbits);
sd_Lim_k=sd_Lim_kc(Rk);
sd_Lim_epsilon=exact_epsilon;
sd_Lim_c=sd_Lim_kc(Rc);
print_polynomial(sd_Lim_k,"sd_Lim_k",nscale);
print_polynomial(sd_Lim_k,"sd_Lim_k",strcat(strf,"_sd_Lim_k_coef.m"),nscale);
print_polynomial(sd_Lim_c,"sd_Lim_c",nscale);
print_polynomial(sd_Lim_c,"sd_Lim_c",strcat(strf,"_sd_Lim_c_coef.m"),nscale);
    
% Calculate "exact" response
exact_Csq=schurOneMlatticeAsq(wa,exact_k,exact_epsilon,p_ones,exact_c);
exact_A=sqrt(exact_Csq).*Azm1;
exact_P=schurOneMlatticeP(wp,exact_k,exact_epsilon,p_ones,exact_c)+Pzm1;
exact_T=schurOneMlatticeT(wt,exact_k,exact_epsilon,p_ones,exact_c)+Tzm1;
exact_dCsqdw=schurOneMlatticedAsqdw(wd,exact_k,exact_epsilon,p_ones,exact_c);
exact_dAsqdw=(exact_Csq(Rdp).*dAzm1sqdw(Rdp))+(exact_dCsqdw.*Azm1sq(Rdp));

% Calculate "exact" errors
exact_A_pass_error=max(abs(exact_A-Ad)(Rap));
exact_A_stop_error=max(abs(exact_A-Ad)(Ras));
exact_P_pass_error=max(abs(exact_P-Pd)/pi);
exact_T_pass_error=max(abs(exact_T-Td));
exact_dAsqdw_pass_error=max(abs(exact_dAsqdw-dAsqddw(Rdp)));
exact_Esq=schurOneMlatticeEsq ...
            (exact_k,exact_epsilon,p_ones,exact_c, ...
             wa,Asqd./Azm1sq,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp,wd,Cd,Wd);

% Calculate signed-digit response
sd_Csq=schurOneMlatticeAsq(wa,sd_k,sd_epsilon,p_ones,sd_c);
sd_A=sqrt(sd_Csq).*Azm1;
sd_P=schurOneMlatticeP(wp,sd_k,sd_epsilon,p_ones,sd_c)+Pzm1;
sd_T=schurOneMlatticeT(wt,sd_k,sd_epsilon,p_ones,sd_c)+Tzm1;
sd_dCsqdw=schurOneMlatticedAsqdw(wd,sd_k,sd_epsilon,p_ones,sd_c);
sd_dAsqdw=(sd_Csq(Rdp).*dAzm1sqdw(Rdp))+(sd_dCsqdw.*Azm1sq(Rdp));

% Calculate signed-digit errors
sd_A_pass_error=max(abs(sd_A-Ad)(Rap));
sd_A_stop_error=max(abs(sd_A-Ad)(Ras));
sd_P_pass_error=max(abs(sd_P-Pd)/pi);
sd_T_pass_error=max(abs(sd_T-Td));
sd_dAsqdw_pass_error=max(abs(sd_dAsqdw-dAsqddw(Rdp)));
sd_Esq=schurOneMlatticeEsq ...
         (sd_k,sd_epsilon,p_ones,sd_c, ...
          wa,Asqd./Azm1sq,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp,wd,Cd,Wd);

% Calculate signed-digit Lim response
sd_Lim_Csq=schurOneMlatticeAsq(wa,sd_Lim_k,sd_Lim_epsilon,p_ones,sd_Lim_c);
sd_Lim_A=sqrt(sd_Lim_Csq).*Azm1;
sd_Lim_P=schurOneMlatticeP(wp,sd_Lim_k,sd_Lim_epsilon,p_ones,sd_Lim_c)+Pzm1;
sd_Lim_T=schurOneMlatticeT(wt,sd_Lim_k,sd_Lim_epsilon,p_ones,sd_Lim_c)+Tzm1;
sd_Lim_dCsqdw=schurOneMlatticedAsqdw(wd,sd_Lim_k,sd_Lim_epsilon,p_ones,sd_Lim_c);
sd_Lim_dAsqdw=(sd_Lim_Csq(Rdp).*dAzm1sqdw(Rdp))+(sd_Lim_dCsqdw.*Azm1sq(Rdp));

% Calculate signed-digit Lim errors
sd_Lim_A_pass_error=max(abs(sd_Lim_A-Ad)(Rap));
sd_Lim_A_stop_error=max(abs(sd_Lim_A-Ad)(Ras));
sd_Lim_P_pass_error=max(abs(sd_Lim_P-Pd)/pi);
sd_Lim_T_pass_error=max(abs(sd_Lim_T-Td));
sd_Lim_dAsqdw_pass_error=max(abs(sd_Lim_dAsqdw-dAsqddw(Rdp)));
sd_Lim_Esq=schurOneMlatticeEsq ...
             (sd_Lim_k,sd_Lim_epsilon,p_ones,sd_Lim_c, ...
              wa,Asqd./Azm1sq,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp,wd,Cd,Wd);

% Calculate branch-and-bound response
bandb_Csq=schurOneMlatticeAsq(wa,bandb_k,bandb_epsilon,p_ones,bandb_c);
bandb_A=sqrt(bandb_Csq).*Azm1;
bandb_P=schurOneMlatticeP(wp,bandb_k,bandb_epsilon,p_ones,bandb_c)+Pzm1;
bandb_T=schurOneMlatticeT(wt,bandb_k,bandb_epsilon,p_ones,bandb_c)+Tzm1;
bandb_dCsqdw=schurOneMlatticedAsqdw(wd,bandb_k,bandb_epsilon,p_ones,bandb_c);
bandb_dAsqdw=(bandb_Csq(Rdp).*dAzm1sqdw(Rdp))+(bandb_dCsqdw.*Azm1sq(Rdp));

% Calculate branch-and-bound errors
bandb_A_pass_error=max(abs(bandb_A-Ad)(Rap));
bandb_A_stop_error=max(abs(bandb_A-Ad)(Ras));
bandb_P_pass_error=max(abs(bandb_P-Pd)/pi);
bandb_T_pass_error=max(abs(bandb_T-Td));
bandb_dAsqdw_pass_error=max(abs(bandb_dAsqdw-dAsqddw(Rdp)));
bandb_Esq=schurOneMlatticeEsq ...
            (bandb_k,bandb_epsilon,p_ones,bandb_c, ...
             wa,Asqd./Azm1sq,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp,wd,Cd,Wd);

% Calculate SOCP-relaxation response
socp_Csq=schurOneMlatticeAsq(wa,socp_k,socp_epsilon,p_ones,socp_c);
socp_A=sqrt(socp_Csq).*Azm1;
socp_P=schurOneMlatticeP(wp,socp_k,socp_epsilon,p_ones,socp_c)+Pzm1;
socp_T=schurOneMlatticeT(wt,socp_k,socp_epsilon,p_ones,socp_c)+Tzm1;
socp_dCsqdw=schurOneMlatticedAsqdw(wd,socp_k,socp_epsilon,p_ones,socp_c);
socp_dAsqdw=(socp_Csq(Rdp).*dAzm1sqdw(Rdp))+(socp_dCsqdw.*Azm1sq(Rdp));

% Calculate SOCP-relaxation errors
socp_A_pass_error=max(abs(socp_A-Ad)(Rap));
socp_A_stop_error=max(abs(socp_A-Ad)(Ras));
socp_P_pass_error=max(abs(socp_P-Pd)/pi);
socp_T_pass_error=max(abs(socp_T-Td));
socp_dAsqdw_pass_error=max(abs(socp_dAsqdw-dAsqddw(Rdp)));
socp_Esq=schurOneMlatticeEsq ...
           (socp_k,socp_epsilon,p_ones,socp_c, ...
            wa,Asqd./Azm1sq,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp,wd,Cd,Wd);

% Plot amplitude response
[ax,ha,hs] = plotyy...
    (wa(Rap)*0.5/pi, ...
     [exact_A(Rap),sd_A(Rap),bandb_A(Rap),socp_A(Rap)]-Ad(Rap), ...
     wa(Ras)*0.5/pi, ...
     [exact_A(Ras),sd_A(Ras),bandb_A(Ras),socp_A(Ras)]-Ad(Ras));
% Copy line colour
hac=get(ha,"color");
hls={"-",":","--","-."};
for c=1:4
  set(hs(c),"color",hac{c});
  set(ha(c),"linestyle",hls{c});
  set(hs(c),"linestyle",hls{c});
endfor
set(ax(1),"ycolor","black");
set(ax(2),"ycolor","black");
axis(ax(1),[0 0.5 0.001*[-1,1]]);
axis(ax(2),[0 0.5 0.01*[-1,1]]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude error");
legend("F-P","S-D","B-and-B","SOCP-relax");
legend("location","south");
legend("boxoff");
legend("left");
strt=sprintf(["Schur one-multiplier lattice lowpass differentiator filter", ...
              " (ndigits=%d,nbits=%d) : fap=%g,fas=%g,tp=%g"], ...
             nbits,ndigits,fap,fas,tp);
% title(strt);
print(strcat(strf,"_amplitude"),"-dpdflatex");
close

% Plot amplitude pass-band response error
ha=plot(wa*0.5/pi,[exact_A,sd_A,bandb_A,socp_A]-Ad);
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([0 fap 0.002*[-1,1]]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude error");
strt=sprintf(["Schur one-multiplier lattice lowpass differentiator filter", ...
              " (ndigits=%d,nbits=%d) : fap=%g,fas=%g"], ...
             nbits,ndigits,fap,fas);
% title(strt);
legend("F-P","S-D","B-and-B","SOCP-relax");
legend("location","southwest");
legend("boxoff");
legend("left");
print(strcat(strf,"_pass"),"-dpdflatex");
close

% Plot amplitude stop-band response error
ha=plot(wa*0.5/pi,[exact_A,sd_A,bandb_A,socp_A]-Ad);
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([fas 0.5 0 0.01]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude error");
strt=sprintf(["Schur one-multiplier lattice lowpass differentiator filter", ...
              " (ndigits=%d,nbits=%d) : fap=%g,fas=%g"], ...
             nbits,ndigits,fap,fas);
% title(strt);
legend("F-P","S-D","B-and-B","SOCP-relax");
legend("location","north");
legend("boxoff");
legend("left");
print(strcat(strf,"_stop"),"-dpdflatex");
close

% Plot phase pass-band response
ha=plot(wp*0.5/pi,([exact_P,sd_P,bandb_P,socp_P]+(wp*tp))/pi);
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([0 fpp pp+0.0004*[-1 1]]);
grid("on");
xlabel("Frequency");
ylabel("Phase(rad./$\\pi$)");
strt=sprintf(["Schur one-multiplier lattice lowpass differentiator filter", ...
              " (ndigits=%d,nbits=%d) : fap=%g,fas=%g"], ...
             nbits,ndigits,fap,fas);
% title(strt);
legend("F-P","S-D","B-and-B","SOCP-relax");
legend("location","north");
legend("boxoff");
legend("left");
print(strcat(strf,"_phase"),"-dpdflatex");
close

% Plot delay pass-band response for signed-digits
ha=plot(wt*0.5/pi,[exact_T,sd_T,bandb_T,socp_T]);
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([0 ftp tp+0.01*[-1 1]]);
grid("on");
xlabel("Frequency");
ylabel("Delay(samples)");
strt=sprintf(["Schur one-multiplier lattice lowpass differentiator filter", ...
              " (ndigits=%d,nbits=%d) : fap=%g,fas=%g"], ...
             nbits,ndigits,fap,fas);
% title(strt);
legend("F-P","S-D","B-and-B","SOCP-relax");
legend("location","southwest");
legend("boxoff");
legend("left");
print(strcat(strf,"_delay"),"-dpdflatex");
close

% Plot dAsqdw pass-band response
ha=plot(wd*0.5/pi,[exact_dAsqdw,sd_dAsqdw,bandb_dAsqdw,socp_dAsqdw]-dAsqddw(Rdp));
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([0 fdp 0.01*[-1 1]]);
grid("on");
xlabel("Frequency");
ylabel("$\\frac{d|A|^{2}}{d\\omega}$ error");
strt=sprintf(["Schur one-multiplier lattice lowpass differentiator filter", ...
              " (ndigits=%d,nbits=%d) : fap=%g,fas=%g"], ...
             nbits,ndigits,fap,fas);
% title(strt);
legend("F-P","S-D","B-and-B","SOCP-relax");
legend("location","southwest");
legend("boxoff");
legend("left");
print(strcat(strf,"_dAsqdw"),"-dpdflatex");
close

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid, ...
        "Floating-point &%8.2e&%8.2e&%8.2e&%8.2e&%8.2e&&\\\\\n", ...
        exact_Esq,exact_A_pass_error,exact_A_stop_error, ...
        exact_P_pass_error,exact_T_pass_error);
fprintf(fid, ...
        "Signed-Digit &%8.2e&%8.2e&%8.2e&%8.2e&%8.2e&%d&%d\\\\\n", ...
        sd_Esq,sd_A_pass_error,sd_A_stop_error, ...
        sd_P_pass_error,sd_T_pass_error, ...
        sd_sd_digits,sd_sd_adders);
fprintf(fid, ...
        "Signed-Digit(Lim) &%8.2e&%8.2e&%8.2e&%8.2e&%8.2e&%d&%d\\\\\n", ...
        sd_Lim_Esq,sd_Lim_A_pass_error,sd_Lim_A_stop_error, ...
        sd_Lim_P_pass_error,sd_Lim_T_pass_error,sd_Lim_sd_digits, ...
        sd_Lim_sd_adders);
fprintf(fid, ...
        "Branch-and-bound &%8.2e&%8.2e&%8.2e&%8.2e&%8.2e&%d&%d\\\\\n", ...
        bandb_Esq,bandb_A_pass_error,bandb_A_stop_error, ...
        bandb_P_pass_error,bandb_T_pass_error, ...
        bandb_sd_digits,bandb_sd_adders);
fprintf(fid, ...
        "SOCP-relaxation &%8.2e&%8.2e&%8.2e&%8.2e&%8.2e&%d&%d\\\\\n", ...
        socp_Esq,socp_A_pass_error,socp_A_stop_error, ...
        socp_P_pass_error,socp_T_pass_error, ...
        socp_sd_digits,socp_sd_adders);
fclose(fid);

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"nN=%d %% Correction filter order\n",nN);
fprintf(fid,"n=%d%% Frequency points across the band\n",n);
fprintf(fid,"fap=%g %% Amplitude pass band upper edge\n",fap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Wat=%g %% Amplitude transition band weight\n",Wat);
fprintf(fid,"fas=%g %% Amplitude stop band lower edge\n",fas);
fprintf(fid,"Was=%g %% Amplitude stop band weight(PCLS)\n",Was);
fprintf(fid,"fpp=%g %% Phase pass band upper edge\n",fpp);
fprintf(fid,"pp=%g %% Nominal pass band phase(rad./pi)\n",pp);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fprintf(fid,"ftp=%g %% Delay pass band upper edge\n",ftp);
fprintf(fid,"tp=%g %% Pass band group delay\n",tp);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"fdp=%g %% Correction filter pass band dCsqdw upper edge\n",fdp);
fprintf(fid,"Wdp=%g %% Correction filter pass band dCsqdw weight\n",Wdp);
fclose(fid);

% Done 
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
