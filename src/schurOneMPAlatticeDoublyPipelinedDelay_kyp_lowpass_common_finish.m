% schurOneMPAlatticeDoublyPipelinedDelay_kyp_lowpass_common_finish.m
% Copyright (C) 2024-2025 Robert G. Jenssen

% Find all-pass denominator polynomial
Dap=schurOneMAPlattice2tf(k);

Asq=schurOneMPAlatticeAsq(wplot,k,k1,k1,kDD,kDD1,kDD1);
printf("10*log10(min(Asq))(pass)=%g,10*log10(max(Asq))(stop)=%g\n", ...
        10*log10(min(Asq(1:nap))),10*log10(max(Asq(nas:end))));

[Esq,gradEsq,diagHessEsq]= ...
  schurOneMPAlatticeEsq(k,k1,k1,kDD,kDD1,kDD1,diff,wplot,Ad,Wa);
printf("Esq=%g\n",Esq);
print_polynomial(gradEsq(1:N),"gradEsq","%g");
print_polynomial(diagHessEsq(1:N),"diagHessEsq","%g");

% Calculate response
[Hap,wplot]=freqz(flipud(Dap(:)),Dap(:),nplot);
NDD=[zeros(DD,1);1];
[HDD,wplot]=freqz(NDD,1,nplot);
H_p=(Hap-HDD)/2;
logH_p=20*log10(abs(H_p));
H_s=(Hap+HDD)/2;
logH_s=20*log10(abs(H_s));

[Tap,wplot]=delayz(flipud(Dap(:)),Dap(:),nplot);
TDD=DD*ones(size(Tap));
T=(Tap+TDD)/2;

% Plot response
subplot(211)
[ax,h1,h2]=plotyy(fplot,logH_s,fplot,logH_s);
ylabel("Amplitude(dB)");
axis(ax(1),[0 0.5 -0.2 0.1]);
axis(ax(2),[0 0.5 -60 -30]);
grid("on");
tstr=sprintf("Response of parallel all-pass filter and delay : N=%d, DD=%d", ...
             N, DD);
title(tstr);
subplot(212)
plot(fplot,T);
ylabel("Delay(samples)");
axis([0 0.5 0 10]);
grid("on");
xlabel("Frequency");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot amplitude error response
ax=plotyy(fplot,logH_p,fplot,logH_s);
ylabel("Amplitude error(dB)");
xlabel("Frequency");
axis(ax(1),[0 0.5 -30 0]);
axis(ax(2),[0 0.5 -60 -30]);
grid("on");
tstr=sprintf("Amplitude error of parallel all-pass filter and delay : N=%d, DD=%d",N, DD);
title(tstr);
print(strcat(strf,"_error_response"),"-dpdflatex");
close

% Plot convergence
list_len=length(list_norm_dk);
if list_len ~= length(list_Esq)
  error("list_len ~= length(list_Esq)");
endif
[ax,h1,h2]=plotyy(1:list_len,list_norm_dk,1:list_len,list_Esq);
set(h1,"linestyle","-");
set(h2,"linestyle","-.");
legend("$\\mathnorm{\\Delta_{\\boldsymbol{k}}}$","$\\mathcal{E}^2$");
legend("box","off");
legend("location","northeast");
ylabel(ax(1),"$\\mathnorm{\\Delta_{\\boldsymbol{k}}}$");
ylabel(ax(2),"$\\mathcal{E}^2$");
xlabel("Iteration");
axis(ax(1),[0 list_len 0 0.004]);
axis(ax(2),[0 list_len 0 0.00004]);
grid("on");
tstr=sprintf(["Convergence of parallel all-pass filter and delay : ", ...
              "N=%d, DD=%d"], N, DD);
title(tstr);
print(strcat(strf,"_convergence"),"-dpdflatex");
close

% Plot Objective
list_len=length(list_norm_dz);
if list_len ~= length(list_Objective)
  error("list_len ~= length(list_Objective)");
endif
[ax,h1,h2]=plotyy(1:list_len,list_norm_dz, ...
                  1:list_len,list_Objective);
set(h1,"linestyle","-");
set(h2,"linestyle","-.");
legend("$\\mathnorm{\\Delta_{\\boldsymbol{z}}}$","Objective");
legend("box","off");
legend("location","northeast");
ylabel(ax(1),"$\\mathnorm{\\Delta_{\\boldsymbol{k}}}$");
ylabel(ax(2),"Objective");
xlabel("Iteration");
axis(ax(1),[0 list_len 0 0.8]);
axis(ax(2),[0 list_len 0 4e-5]);
grid("on");
tstr=sprintf("Objective of parallel all-pass filter and delay : N=%d, DD=%d",...
             N, DD);
title(tstr);
print(strcat(strf,"_Objective"),"-dpdflatex");
close

% Plot amplitude pass-band min. and stop-band max.
list_len=length(list_Asq_min);
if list_len ~= length(list_Asq_max)
  error("list_len ~= length(list_Asq_max)");
endif
[ax,h1,h2]=plotyy(1:list_len,10*log10(list_Asq_min), ...
                  1:list_len,10*log10(list_Asq_max));
set(h1,"linestyle","-");
set(h2,"linestyle","-.");
legend("$A_{min. pass}$(dB)","$A_{max}$(dB)");
legend("box","off");
legend("location","northwest");
ylabel(ax(1),"Pass-band amplitude(dB)");
ylabel(ax(2),"Maximum stop-band amplitude(dB)");
xlabel("Iteration");
axis(ax(1),[0 list_len -0.5 0]);
axis(ax(2),[0 list_len -45 -40]);
grid("on");
tstr=sprintf(["Pass-band min. and stop-band max. (dB) of ", ...
 "parallel all-pass filter and delay : N=%d, DD=%d"],N, DD);
title(tstr);
print(strcat(strf,"_Asq_min_max"),"-dpdflatex");
close

% Plot poles and zeros
Da=schurOneMAPlattice2tf(k,k1,k1);
Na=0.5*(conv([zeros(1,(DD)),1],Da)+[fliplr(Da),zeros(1,(DD))]);
zplane(Na,[zeros(1,length(Na)-length(Da)),Da])
tstr=sprintf(["Pole-zero plot of parallel all-pass filter and delay : ", ...
 "N=%d, DD=%d"], N, DD);
title(tstr);
grid("on");
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Save the results
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"tol=%g %% General tolerance\n",tol);
fprintf(fid,"maxiter_kyp=%d %% Maximum number of KYP iterations\n",maxiter_kyp);
fprintf(fid,"use_hessEsq=%d %% Use 2nd order approx. to Esq\n",use_hessEsq);
fprintf(fid,"N=%d %% Allpass filter order\n",N);
fprintf(fid,"DD=%d %% Parallel delay order\n",DD);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fclose(fid);

print_polynomial(Da0,"Da0");
print_polynomial(Da0,"Da0",strcat(strf,"_Da0_coef.m"));
print_polynomial(k0,"k0");
print_polynomial(k0,"k0",strcat(strf,"_k0_coef.m"));
print_polynomial(k,"k");
print_polynomial(k,"k",strcat(strf,"_k_coef.m"));

print_polynomial(list_Objective,"list_Objective");
print_polynomial(list_norm_dz,"list_norm_dz");
print_polynomial(list_norm_dk,"list_norm_dk");
print_polynomial(list_Esq,"list_Esq");
print_polynomial(list_Esq_p,"list_Esq_p");
print_polynomial(list_Esq_s,"list_Esq_s");
print_polynomial(list_Asq_min,"list_Asq_min");
print_polynomial(list_Asq_max,"list_Asq_max");
for u=1:length(list_k)
  print_polynomial(list_k{u},sprintf("list_k{%d}",u));
endfor

% Done
eval(sprintf("save %s.mat tol k0 N DD fap Wap fas Was k",strf));

