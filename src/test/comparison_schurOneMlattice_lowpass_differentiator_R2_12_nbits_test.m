% comparison_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test.m 
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
strf=strcat("comparison_",strs);

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

eval(strcat("pop_relaxation_",strs,"_k_min_coef;"));
eval(strcat("pop_relaxation_",strs,"_c_min_coef;"));
pop_k=k_min;
pop_epsilon=exact_epsilon;
pop_c=c_min;
[pop_sd_digits,pop_sd_adders]=SDadders([pop_k;pop_c],nbits);

p_ones=ones(size(exact_k));

clear k_min epsilon_min c_min ;

% Frequency points
n=1000;
w=pi*(0:(n-1))'/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;
npp=ceil(fpp*n/0.5)+1;
ntp=ceil(ftp*n/0.5)+1;
ndp=ceil(fdp*n/0.5)+1;
Rap=1:nap;
Ras=nas:length(w);
Rpp=1:npp;
Rtp=1:ntp;
Rdp=1:ndp;

% Response of z=1
Azm1=2*sin(w/2);
Azm1sq=Azm1.^2;
dAzm1sqdw=2*sin(w);
Pzm1=(pi/2)-(w/2);
Tzm1=0.5;

% Desired responses
Ad=[w(1:nap)/2;zeros(n-nap,1)];
Asqd=Ad.^2;
dAsqddw=Ad;
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas+1,1)];
Pd=(pi*pp)-(w*tp);
Wp=[Wpp*ones(npp,1); zeros(n-npp,1)];
Td=[tp*ones(ntp,1);zeros(n-ntp,1)];
Wt=[Wtp*ones(ntp,1); zeros(n-ntp,1)];
Dd=[dAsqddw(1:ndp);zeros(n-ndp,1)];
Wd=[Wdp*ones(ndp,1); zeros(n-ndp,1)];
    
% Calculate "exact" response
exact_Csq=schurOneMlatticeAsq(w,exact_k,exact_epsilon,p_ones,exact_c);
exact_A=sqrt(exact_Csq).*Azm1;
exact_P=schurOneMlatticeP(w,exact_k,exact_epsilon,p_ones,exact_c)+Pzm1;
exact_T=schurOneMlatticeT(w,exact_k,exact_epsilon,p_ones,exact_c)+Tzm1;
exact_dCsqdw=schurOneMlatticedAsqdw(w,exact_k,exact_epsilon,p_ones,exact_c);
exact_dAsqdw=(exact_Csq.*dAzm1sqdw)+(exact_dCsqdw.*Azm1sq);

% Calculate "exact" errors
exact_A_pass_error=max(abs(exact_A-Ad)(Rap));
exact_A_stop_error=max(abs(exact_A-Ad)(Ras));
exact_P_pass_error=max(abs(exact_P-Pd)(Rpp));
exact_T_pass_error=max(abs(exact_T-Td)(Rtp));
exact_dAsqdw_pass_error=max(abs(exact_dAsqdw-dAsqddw)(Rdp));
exact_Esq=schurOneMlatticeEsq(exact_k,exact_epsilon,p_ones,exact_c, ...
                              w,Asqd,Wa,w,Td,Wt,w,Pd,Wp,w,Dd,Wd);

% Calculate branch-and-bound response
bandb_Csq=schurOneMlatticeAsq(w,bandb_k,bandb_epsilon,p_ones,bandb_c);
bandb_A=sqrt(bandb_Csq).*Azm1;
bandb_P=schurOneMlatticeP(w,bandb_k,bandb_epsilon,p_ones,bandb_c)+Pzm1;
bandb_T=schurOneMlatticeT(w,bandb_k,bandb_epsilon,p_ones,bandb_c)+Tzm1;
bandb_dCsqdw=schurOneMlatticedAsqdw(w,bandb_k,bandb_epsilon,p_ones,bandb_c);
bandb_dAsqdw=(bandb_Csq.*dAzm1sqdw)+(bandb_dCsqdw.*Azm1sq);

% Calculate branch-and-bound errors
bandb_A_pass_error=max(abs(bandb_A-Ad)(Rap));
bandb_A_stop_error=max(abs(bandb_A-Ad)(Ras));
bandb_P_pass_error=max(abs(bandb_P-Pd)(Rpp));
bandb_T_pass_error=max(abs(bandb_T-Td)(Rtp));
bandb_dAsqdw_pass_error=max(abs(bandb_dAsqdw-dAsqddw)(Rdp));
bandb_Esq=schurOneMlatticeEsq(bandb_k,bandb_epsilon,p_ones,bandb_c, ...
                              w,Asqd,Wa,w,Td,Wt,w,Pd,Wp,w,Dd,Wd);

% Calculate SOCP-relaxation response
socp_Csq=schurOneMlatticeAsq(w,socp_k,socp_epsilon,p_ones,socp_c);
socp_A=sqrt(socp_Csq).*Azm1;
socp_P=schurOneMlatticeP(w,socp_k,socp_epsilon,p_ones,socp_c)+Pzm1;
socp_T=schurOneMlatticeT(w,socp_k,socp_epsilon,p_ones,socp_c)+Tzm1;
socp_dCsqdw=schurOneMlatticedAsqdw(w,socp_k,socp_epsilon,p_ones,socp_c);
socp_dAsqdw=(socp_Csq.*dAzm1sqdw)+(socp_dCsqdw.*Azm1sq);

% Calculate SOCP-relaxation errors
socp_A_pass_error=max(abs(socp_A-Ad)(Rap));
socp_A_stop_error=max(abs(socp_A-Ad)(Ras));
socp_P_pass_error=max(abs(socp_P-Pd)(Rpp));
socp_T_pass_error=max(abs(socp_T-Td)(Rtp));
socp_dAsqdw_pass_error=max(abs(socp_dAsqdw-dAsqddw)(Rdp));
socp_Esq=schurOneMlatticeEsq(socp_k,socp_epsilon,p_ones,socp_c, ...
                             w,Asqd,Wa,w,Td,Wt,w,Pd,Wp,w,Dd,Wd);

% Calculate POP-relaxation response
pop_Csq=schurOneMlatticeAsq(w,pop_k,pop_epsilon,p_ones,pop_c);
pop_A=sqrt(pop_Csq).*Azm1;
pop_P=schurOneMlatticeP(w,pop_k,pop_epsilon,p_ones,pop_c)+Pzm1;
pop_T=schurOneMlatticeT(w,pop_k,pop_epsilon,p_ones,pop_c)+Tzm1;
pop_dCsqdw=schurOneMlatticedAsqdw(w,pop_k,pop_epsilon,p_ones,pop_c);
pop_dAsqdw=(pop_Csq.*dAzm1sqdw)+(pop_dCsqdw.*Azm1sq);

% Calculate POP-relaxation errors
pop_A_pass_error=max(abs(pop_A-Ad)(Rap));
pop_A_stop_error=max(abs(pop_A-Ad)(Ras));
pop_P_pass_error=max(abs(pop_P-Pd)(Rpp));
pop_T_pass_error=max(abs(pop_T-Td)(Rtp));
pop_dAsqdw_pass_error=max(abs(pop_dAsqdw-dAsqddw)(Rdp));
pop_Esq=schurOneMlatticeEsq(pop_k,pop_epsilon,p_ones,pop_c, ...
                            w,Asqd,Wa,w,Td,Wt,w,Pd,Wp,w,Dd,Wd);

% Plot amplitude pass-band response error
ha=plot(w*0.5/pi,[exact_A,bandb_A,socp_A,pop_A]-Ad);
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([0 fap 0.001*[-1,1]]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude error");
strt=sprintf(["Schur one-multiplier lattice lowpass differentiator filter", ...
              " (ndigits=%d,nbits=%d) : fap=%g,fas=%g"], ...
             nbits,ndigits,fap,fas);
title(strt);
legend("Exact","B-and-B","SOCP-relax","POP-relax");
legend("location","southwest");
legend("boxoff");
legend("left");
print(strcat(strf,"_pass_error"),"-dpdflatex");
close

% Plot amplitude stop-band response error
ha=plot(w*0.5/pi,[exact_A,bandb_A,socp_A,pop_A]-Ad);
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([fas 0.5 0 0.008]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude error");
strt=sprintf(["Schur one-multiplier lattice lowpass differentiator filter", ...
              " (ndigits=%d,nbits=%d) : fap=%g,fas=%g"], ...
             nbits,ndigits,fap,fas);
title(strt);
legend("Exact","B-and-B","SOCP-relax","POP-relax");
legend("location","northeast");
legend("boxoff");
legend("left");
print(strcat(strf,"_stop_error"),"-dpdflatex");
close

% Plot phase pass-band response
ha=plot(w*0.5/pi,([exact_P,bandb_P,socp_P,pop_P]+(w*tp))/pi);
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
title(strt);
legend("Exact","B-and-B","SOCP-relax","POP-relax");
legend("location","southwest");
legend("boxoff");
legend("left");
print(strcat(strf,"_pass_phase"),"-dpdflatex");
close

% Plot delay pass-band response
ha=plot(w*0.5/pi,[exact_T,bandb_T,socp_T,pop_T]);
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
title(strt);
legend("Exact","B-and-B","SOCP-relax","POP-relax");
legend("location","southwest");
legend("boxoff");
legend("left");
print(strcat(strf,"_pass_delay"),"-dpdflatex");
close

% Plot dAsqdw pass-band response
ha=plot(w*0.5/pi,[exact_dAsqdw,bandb_dAsqdw,socp_dAsqdw,pop_dAsqdw]-dAsqddw);
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([0 fdp 0.01*[-1 1]]);
grid("on");
xlabel("Frequency");
ylabel("$\\frac{d|A|^{2}}{d\\omega}$");
strt=sprintf(["Schur one-multiplier lattice lowpass differentiator filter", ...
              " (ndigits=%d,nbits=%d) : fap=%g,fas=%g"], ...
             nbits,ndigits,fap,fas);
title(strt);
legend("Exact","B-and-B","SOCP-relax","POP-relax");
legend("location","southwest");
legend("boxoff");
legend("left");
print(strcat(strf,"_pass_dAsqdw"),"-dpdflatex");
close

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %6.4f & %8.2e & %8.2e & %8.2e & %8.2e & & \\\\\n", ...
        exact_Esq,exact_A_pass_error,exact_A_stop_error,exact_P_pass_error, ...
        exact_T_pass_error);
fprintf(fid,"Branch-and-bound & %6.4f & %8.2e & %8.2e & %8.2e & %8.2e & %d & %d \\\\\n", ...
        bandb_Esq,bandb_A_pass_error,bandb_A_stop_error,bandb_P_pass_error, ...
        bandb_T_pass_error,bandb_sd_digits,bandb_sd_adders);
fprintf(fid,"SOCP-relaxation & %6.4f & %8.2e & %8.2e & %8.2e & %8.2e & %d & %d \\\\\n", ...
        socp_Esq,socp_A_pass_error,socp_A_stop_error,socp_P_pass_error, ...
        socp_T_pass_error,socp_sd_digits,socp_sd_adders);
fprintf(fid,"POP-relaxation & %6.4f & %8.2e & %8.2e & %8.2e & %8.2e & %d & %d \\\\\n", ...
        pop_Esq,pop_A_pass_error,pop_A_stop_error,pop_P_pass_error, ...
        pop_T_pass_error,pop_sd_digits,pop_sd_adders);
fclose(fid);

% Done 
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
