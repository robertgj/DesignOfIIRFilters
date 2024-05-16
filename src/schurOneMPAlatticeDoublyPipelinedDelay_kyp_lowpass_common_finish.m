% schurOneMPAlatticeDoublyPipelinedDelay_kyp_lowpass_common_finish.m
% Copyright (C) 2024 Robert G. Jenssen

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
set(h1,'linestyle','-');
set(h2,'linestyle','--');
legend("$A^{2}_{min}(dB)$","$A^{2}_{max}(dB)$");
legend("box","off");
legend("location","northeast");
axis(ax(1),[0 0.5 -0.5 0]);
axis(ax(2),[0 0.5 -65 -40]);
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
[ax,h1,h2]=plotyy(1:length(list_norm_dk),list_norm_dk,1:length(list_Esq),list_Esq);
set(h1,'linestyle','-');
set(h2,'linestyle','--');
legend("norm($\\Delta_{\\boldsymbol{k}}$)","$\\mathcal{E}^2$");
legend("box","off");
legend("location","northeast");
ylabel(ax(1),"norm($\\Delta_{\\boldsymbol{k}}$)");
ylabel(ax(2),"$\\mathcal{E}^2$");
xlabel("Iteration");
axis(ax(1),[0 maxiter_kyp]);
axis(ax(2),[0 maxiter_kyp]);
grid("on");
tstr=sprintf("Convergence of parallel all-pass filter and delay : N=%d, DD=%d",N, DD);
title(tstr);
print(strcat(strf,"_convergence"),"-dpdflatex");
close

% Plot amplitude min,max
[ax,h1,h2]=plotyy(1:length(list_Asq_min),10*log10(list_Asq_min), ...
                  1:length(list_Asq_max),10*log10(list_Asq_max));
set(h1,'linestyle','-');
set(h2,'linestyle','--');
legend("$A^{2}_{min}(dB)$","$A^{2}_{max}(dB)$");
legend("box","off");
legend("location","northeast");
ylabel(ax(1),"$A^{2}_{min}(dB)$");
ylabel(ax(2),"$A^{2}_{max}(dB)$");
xlabel("Iteration");
axis(ax(1),[0 maxiter_kyp -0.5 0]);
axis(ax(2),[0 maxiter_kyp -45 -40]);
grid("on");
tstr=sprintf("Convergence of parallel all-pass filter \
pass-band $A^{2}_{min}$ and stop-band $A^{2}_{max}$ : N=%d, DD=%d",N, DD);
title(tstr);
print(strcat(strf,"_Asq_min_max"),"-dpdflatex");
close

% Save the results
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"tol=%g %% General used tolerance\n",tol);
fprintf(fid,"N=%d %% Allpass filter order\n",N);
fprintf(fid,"DD=%d %% Parallel delay order\n",DD);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fclose(fid);

print_polynomial(k0,"k0");
print_polynomial(k0,"k0",strcat(strf,"_k0_coef.m"));
print_polynomial(k,"k");
print_polynomial(k,"k",strcat(strf,"_k_coef.m"));

print_polynomial(list_norm_dk,"list_norm_dk");
print_polynomial(list_Esq,"list_Esq");
print_polynomial(list_Asq_min,"list_Asq_min");
print_polynomial(list_Asq_max,"list_Asq_max");

% Done
eval(sprintf("save %s.mat k0 N DD fap Wap fas Was k",strf));

