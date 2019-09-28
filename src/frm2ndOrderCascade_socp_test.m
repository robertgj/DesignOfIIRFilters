% frm2ndOrderCascade_socp_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("frm2ndOrderCascade_socp_test.diary");
unlink("frm2ndOrderCascade_socp_test.diary.tmp");
diary frm2ndOrderCascade_socp_test.diary.tmp

tic;

verbose=false
maxiter=2000

% Filter specification
tol=1e-6 % Tolerance on coefficient update vector
n=1200 % Frequency points across the band
mn=10 % Model filter numerator order (mn+1 coefficients)
mr=10 % Model filter denominator order (mr coefficients)
na=33 % Model masking filter FIR length
nc=33 % Model complementary masking filter FIR length
M=9 % Decimation
Dmodel=7 % Model filter pass band group delay 
dmask=(max(na,nc)-1)/2 % Masking filter nominal delay
fpass=0.300 % Pass band edge
fstop=0.305 % Stop band edge
dBas=55 % Stop band attenuation
Wap=1 % Pass band weight
Wapextra=0 % Extra weight for extra pass band points
Wasextra=0 % Extra weight for extra stop band points
Was=9 % Stop band weight
tau=0.1 % Stability parameter
edge_factor=0.1 % Add extra frequencies near band edges
edge_ramp=0 % Linear change in extra weights over edge region

% Frequency vectors
[wpass,Hpass,Wpass,wstop,Hstop,Wstop,fadp,fads,faap,faas,facp,facs] = ...
frm_lowpass_vectors(n,M,Dmodel,dmask, ...
                    fpass,fstop,dBas,Wap,Wapextra,Wasextra,Was, ...
                    edge_factor,edge_ramp);

% Initial filters
x0.a=remez(mn,2*[0 fadp fads 0.5],[1 1 0 0]);
x0.d=[1;zeros(mr,1)];
x0.aa=remez(na-1,2*[0 faap faas 0.5],[1 1 0 0]);
x0.ac=remez(nc-1,2*[0 facp facs 0.5],[1 1 0 0]);

% SOCP loop for zero phase response
[x1,E,socp_iter,feasible] = ...
  frm2ndOrderCascade_socp(x0,M,Dmodel,tau,[wpass;wstop],abs([Hpass;Hstop]), ...
                          [Wpass;Wstop],maxiter,tol,verbose);
if feasible == 0 
  error("x1 infeasible");
endif

% Extract model filter polynomials
a=x1.a;
d=x1.d;
if mn > mr
  d=[d;zeros(mn-mr,1)];
elseif mn < mr
  a=[a;zeros(mr-mn,1)];
endif
aM=[a(1);kron(a(2:end),[zeros(M-1,1);1])];
dM=[d(1);kron(d(2:end),[zeros(M-1,1);1])];

% Extract masking filters
aa=x1.aa;
ac=x1.ac;
if na>nc
  aa=x1.aa;
  ac=[zeros((na-nc)/2,1);x1.ac; zeros((na-nc)/2,1)];
elseif na<nc
  aa=[zeros((nc-na)/2,1);x1.aa; zeros((nc-na)/2,1)];
  ac=x1.ac;
endif

% Overall numerator polynomial
aM_frm=[conv(aM,aa-ac);zeros(M*Dmodel,1)]+[zeros(M*Dmodel,1);conv(ac,dM)];

% Common strings for output plots
strf="frm2ndOrderCascade_socp_test";
strM=sprintf("%%s:M=%d,Dmodel=%d,fpass=%g,fstop=%g,Was=%g", ...
             M,Dmodel,fpass,fstop,Was);

% Plot response
nplot=512
[Hw_frm,wplot]=freqz(aM_frm,dM,nplot);
Tw_frm=grpdelay(aM_frm,dM,nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hw_frm)))
axis([0, 0.5, -70, 10]);
ylabel("Amplitude(dB)");
grid("on");
strt=sprintf(strM,"FRM filter response");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tw_frm)
axis([0, 0.5, 60, 100]);
xlabel("Frequency");
ylabel("Group delay(samples)");
grid("on");
print(strcat(strf,"_x1"),"-dpdflatex");
close
% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hw_frm)))
axis([0, 0.3, -0.4, 0.4]);
ylabel("Amplitude(dB)");
grid("on");
strt=sprintf(strM,"FRM filter passband response");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tw_frm)
axis([0, 0.3, 76, 84]);
xlabel("Frequency");
ylabel("Group delay(samples)");
grid("on");
print(strcat(strf,"_x1pass"),"-dpdflatex");
close

% Plot model filter response
Hw_model=freqz(aM,dM,nplot);
Tw_model=grpdelay(aM,dM,nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hw_model)))
axis([0, 0.5, -15, 15]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
strt=sprintf(strM,"FRM model filter");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tw_model)
axis([0, 0.5, 0, 200]);
xlabel("Frequency");
ylabel("Group delay(samples)");
grid("on");
print(strcat(strf,"_x1model"),"-dpdflatex");
close

% Plot masking filter response
Hw_aa=freqz(aa,1,nplot);
Hw_ac=freqz(ac,1,nplot);
subplot(111);
plot(wplot*0.5/pi,20*log10(abs(Hw_aa)),'-',...
     wplot*0.5/pi,20*log10(abs(Hw_ac)),'--');
legend("Mask","Comp","location","northeast");
legend("boxoff");
axis([0, 0.5, -60, 10]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
strt=sprintf(strM,"FRM masking filters");
title(strt);
print(strcat(strf,"_x1mask"),"-dpdflatex");
close

% Compare with remez
br=remez(((M*Dmodel)+dmask)*2,[0 fpass fstop 0.5]*2,[1,1,0,0],[1 Was]);
Hbr=freqz(br,1,nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs([Hbr Hw_frm])))
axis([0, fpass, -5, 5]);
ylabel("Passband amplitude(dB)");
xlabel("Passband frequency");
grid("on");
subplot(212);
plot(wplot*0.5/pi,20*log10(abs([Hbr Hw_frm])))
axis([fstop, 0.5, -60, -30]);
xlabel("Stopband frequency");
ylabel("Stopband amplitude(dB)");
grid("on");
print(strcat(strf,"_remez_comparison"),"-dpdflatex");
close

% Save the results
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%5.1g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"mn=%d %% Model filter numerator order (mn+1 coefficients)\n",mn);
fprintf(fid,"mr=%d %% Model filter denominator order (mr coefficients)\n",mr);
fprintf(fid,"na=%d %% Model masking filter FIR length\n",na);
fprintf(fid,"nc=%d %% Model complementary masking filter FIR length\n",nc);
fprintf(fid,"M=%d %% Decimation\n",M);
fprintf(fid,"Dmodel=%d %% Model filter pass band group delay \n",Dmodel);
fprintf(fid,"dmask=%d %% Masking filter nominal delay\n",dmask);
fprintf(fid,"fpass=%5.3g %% Pass band edge\n",fpass);
fprintf(fid,"fstop=%5.3g %% Stop band edge\n",fstop);
fprintf(fid,"dBas=%d %% Stop band attenuation\n",dBas);
fprintf(fid,"Wap=%d %% Pass band weight\n",Wap);
fprintf(fid,"Wapextra=%d %% Extra weight for extra pass band points\n",Wapextra);
fprintf(fid,"Wasextra=%d %% Extra weight for extra stop band points\n",Wasextra);
fprintf(fid,"Was=%d %% Stop band weight\n",Was);
fprintf(fid,"tau=%3.1g %% Stability parameter\n",tau);
fprintf(fid,"edge_factor=%3.1g %% Add extra frequencies near band edges\n",
        edge_factor);
fprintf(fid,"edge_ramp=%d %% Linear change in extra weights over edge region\n",
        edge_ramp);
fclose(fid);

print_polynomial(a,"a");
print_polynomial(a,"a",strcat(strf,"_a_coef.m"));
print_polynomial(d,"d");
print_polynomial(d,"d",strcat(strf,"_d_coef.m"));
print_polynomial(aa,"aa");
print_polynomial(aa,"aa",strcat(strf,"_aa_coef.m"));
print_polynomial(ac,"ac");
print_polynomial(ac,"ac",strcat(strf,"_ac_coef.m"));

save frm2ndOrderCascade_socp_test.mat ...
     a d aa ac M Dmodel dmask mn mr na nc fpass fstop Was tau edge_factor tol

% Done
toc;
diary off
movefile frm2ndOrderCascade_socp_test.diary.tmp ...
         frm2ndOrderCascade_socp_test.diary;
