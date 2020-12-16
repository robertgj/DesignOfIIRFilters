% decimator_R2_interpolated_test.m
% Copyright (C) 2020 Robert G. Jenssen
%
% Example of an interpolated low-pass IIR decimator filter design using
% quasi-Newton optimisation with constraints on the coefficients.

test_common;

delete("decimator_R2_interpolated_test.diary");
delete("decimator_R2_interpolated_test.diary.tmp");
diary decimator_R2_interpolated_test.diary.tmp

strf="decimator_R2_interpolated_test";

tic;

verbose=false
tol_wise=1e-7
tol_mmse=1e-5
tol_pcls=1e-3
ctol=1e-5
maxiter=10000

% Filter specifications (frequencies are normalised to the sample rate)
U=0,V=0,M=12,Q=6,R=2
fap=0.09,dBap=0.25,Wap=1
Wat=0.001
fas=0.18,dBas=40,Was=10
ftp=0.12,tp=10,tpr=0.2,Wtp=0.1

% Interpolation factor
P=3;

% Initial filter guess
xi=[0.00005,[1,1,1,1,1,1], (7:12)*pi/12, 0.7*[1,1,1], (1:3)*pi/8]';
print_pole_zero(xi,U,V,M,Q,R,"xi");

% Frequency points
n=1000;

% Coefficient constraints
[xl,xu]=xConstraints(U,V,M,Q);
dmax=0.05;

% Amplitude constraints
fa=(0:(n-1))'*0.5/n;
wa=fa*2*pi;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
%Ad=[1;P*sin(wa(2:nap)/(P*2))./sin(wa(2:nap)/2);zeros(n-nap,1)];
Ad=[ones(nap,1);;zeros(n-nap,1)];
Adu=[(10^(dBap/40))*Ad(1:nap); ...
     (10^(dBap/40))*Ad(nap)*ones(nas-nap-1,1); ...
     (10^(-dBas/20))*ones(n-nas+1,1)];
Adl=[(10^(-dBap/40))*Ad(1:nap);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Stop-band amplitude response constraints
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Phase response constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Sanity checks
nchka=[nap-1,nap,nap+1,nas-1,nas,nas+1]';
printf("fa(nchka)'=[ ");printf("%6.4g ",fa(nchka)');printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Adu(nchka)=[ ");printf("%6.4g ",Adu(nchka)');printf("];\n");
printf("Adl(nchka)=[ ");printf("%6.4g ",Adl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Initial filter
[x0,Ex0]=xInitHd(xi,U,V,M,Q,R, ...
                 wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp,maxiter,tol_wise);
print_pole_zero(x0,U,V,M,Q,R,"x0");

% MMSE pass
printf("\nFinding MMSE x1, Wap=%f,Was=%f,Wtp=%f\n", Wap, Was, Wtp);
[x1,Ex1,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
               wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,tol_mmse,verbose);
if feasible == 0 
  error("R=2 decimator x1 infeasible");
endif
print_pole_zero(x1,U,V,M,Q,R,"x1");

% PCLS pass 1
printf("\nFinding PCLS d1, dBap=%f,Wap=%f,dBas=%f,Was=%f,tpr=%f,Wtp=%f\n", 
       dBap, Wap, dBas, Was, tpr, Wtp);
[d1,E,slb_iter,sqp_iter,func_iter,feasible] = ...
  iir_slb(@iir_sqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
          wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,maxiter,tol_pcls,ctol,verbose)
if feasible == 0 
  error("d1 (pcls) infeasible");
endif
print_pole_zero(d1,U,V,M,Q,R,"d1");

% Find the actual band edges
A1=iirA(wa,d1,U,V,M,Q,R);
[~,ifap_actual]=max(find(A1>((10^(-dBap/20))-(10*ctol))));
fap_actual=fa(ifap_actual+1);
[~,ifas_actual]=max(find(abs(A1)>((10^(-dBas/20)))+(10*ctol)));
fas_actual=fa(ifas_actual-1);
% Design the FIR anti-aliasing filter
delf=(((2*0.5)-fas_actual)/P)-(fap_actual/P);
N=2+(floor(ceil(dBas/(22*(delf)))/2)*2);
b=remez(N,[0 (fap_actual/P) (fap_actual/P)+delf 0.5]*2,[1 1 0 0]);
b=b(:)';
% Scale the anti-aliasing filter
[N1,D1]=x2tf(d1,U,V,M,Q,R);
N1=N1;
H1=freqz(N1,D1,wa*P);
Hb=freqz(b,1,wa);
b_scale=max(abs(Hb.*H1));
b=b/b_scale;
Hb=freqz(b,1,wa);
              
% Calculate the overall response of the interpolated anti-aliased IIR filter
N1=N1(:)';
N1P=conv(b,[N1(1),kron(N1(2:end),[zeros(1,P-1),1])]);
D1=D1(:)';
D1P=[D1(1),kron(D1(2:end),[zeros(1,P-1),1])];
H1P=freqz(N1P,D1P,wa);
T1P=grpdelay(N1P,D1P,n);
N1D1_mult=(length(D1(2:end))/R)+length(N1)+(N/2)+1;

% Plot interpolated IIR filter against FIR anti-aliasing filter
plot(fa,20*log10(abs(H1)),fa,20*log10(abs(Hb)),"-.");
axis([0 0.5 -60 10])
grid("on");
ylabel("Amplitude(dB)")
xlabel("Frequency");
title(sprintf("R=%d IIR filter interpolated by P=%d and \
FIR anti-aliasing filter",R,P));
legend("Interpolated IIR","Anti-aliasing FIR");
legend("location","northeast");
legend("boxoff");
legend("left");
print(strcat(strf,"_fir_antialiasing"),"-dpdflatex");
close

% Plot overall amplitude response of the interpolated anti-aliased IIR filter
ax=plotyy(fa,20*log10(abs(H1P)),fa,20*log10(abs(H1P)));
axis(ax(1),[0 0.5 -0.4 0.4])
axis(ax(2),[0 0.5 -60 -40])
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
grid("on");
ylabel("Amplitude(dB)")
title("Interpolated and anti-aliased IIR filter");
xlabel("Frequency");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot pass-band detail of the interpolated anti-aliased IIR filter
subplot(211)
plot(fa,20*log10(abs(H1P)));
axis([0 0.04 -0.6 0.2])
grid("on");
ylabel("Amplitude(dB)")
title("Pass-band of interpolated and anti-aliased IIR filter");
subplot(212)
plot(wa*0.5/pi,T1P);
tpP=(tp*P)+(N/2);
axis([0 0.04 tpP+(2*tpr*[-1 1])])
grid("on");
ylabel("Delay(samples)")
xlabel("Frequency");
print(strcat(strf,"_passband_response"),"-dpdflatex");
close

% Plot the response of the interpolated IIR filter ...
subplot(411)
ax=plotyy(fa,20*log10(abs(H1P)),fa,20*log10(abs(H1P)));
axis(ax(1),[0 0.1 -0.4 0.4])
axis(ax(2),[0 0.1 -45 -25])
axis(ax(1),"tic","labely");
axis(ax(2),"tic","labely");
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
grid("on");
ylabel("Amplitude(dB)")
title(sprintf("Interpolated and anti-aliased IIR filter : \
%d multipliers and %g samples nominal delay",N1D1_mult,tpP));
% ... against that of:
%  1. an equivalent interpolated anti-aliased FIR
baa=remez(N,[0 (fap/P) ((1-fas)/P) 0.5]*2,[1 1 0 0]);
baa=baa(:)';
Neq=floor(ceil(dBas/(22*(fas-fap)))/2)*2;
tdeq=(Neq*P/2)+(N/2);
bbeq_mult=(Neq/2)+1+(N/2)+1;
beq=remez(Neq,[0 fap fas 0.5]*2,[1 1 0 0]);
beq=beq(:)';
bbeq=conv(baa,[beq(1),kron(beq(2:end),[zeros(1,P-1),1])]);
Hbbeq=freqz(bbeq,1,wa);
subplot(412)
ax=plotyy(fa,20*log10(abs(Hbbeq)),fa,20*log10(abs(Hbbeq)));
axis(ax(1),[0 0.1 -0.4 0.4])
axis(ax(2),[0 0.1 -45 -25])
axis(ax(1),"tic","labely");
axis(ax(2),"tic","labely");
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
grid("on");
ylabel("Amplitude(dB)")
title(sprintf("Equivalent interpolated and anti-aliased FIR filter : \
%d distinct multipliers and %g samples delay",bbeq_mult,tdeq));
%  2. an FIR filter with the same number of distinct multipliers
Nbb=2*(N1D1_mult-1);
bb=remez(Nbb,[0 fap/P fas/P 0.5]*2,[1 1 0 0]);
Hbb=freqz(bb,1,wa);
subplot(413)
ax=plotyy(fa,20*log10(abs(Hbb)),fa,20*log10(abs(Hbb)));
axis(ax(1),[0 0.1 -0.4 0.4])
axis(ax(2),[0 0.1 -45 -25])
axis(ax(1),"tic","labely");
axis(ax(2),"tic","labely");
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
grid("on");
ylabel("Amplitude(dB)")
title(sprintf("Direct-form FIR filter : %d distinct multipliers",(Nbb/2)+1));
%  3. an FIR filter with the same nominal delay
Nbbb=round(2*tpP);
bbb=remez(Nbbb,[0 fap/P fas/P 0.5]*2,[1 1 0 0]);
Hbbb=freqz(bbb,1,wa);
subplot(414)
ax=plotyy(fa,20*log10(abs(Hbbb)),fa,20*log10(abs(Hbbb)));
axis(ax(1),[0 0.1 -0.4 0.4])
axis(ax(2),[0 0.1 -45 -25])
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
grid("on");
ylabel("Amplitude(dB)")
xlabel("Frequency");
title(sprintf("Direct-form FIR filter : %g samples delay",(Nbbb/2)));
print(strcat(strf,"_remez_comparison"),"-dpdflatex");
close

% Save results
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"P=%d %% Interpolation factor\n",P);
fprintf(fid,"U=%d %% Number of real zeros\n",U);
fprintf(fid,"V=%d %% Number of real poles\n",V);
fprintf(fid,"M=%d %% Number of complex zeros\n",M);
fprintf(fid,"Q=%d %% Number of complex poles\n",Q);
fprintf(fid,"R=%d %% Denominator polynomial decimation factor\n",R);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"tol_wise=%g %% Tolerance on WISE relative coef. update\n",tol_wise);
fprintf(fid,"tol_mmse=%g %% Tolerance on MMSE relative coef. update\n",tol_mmse);
fprintf(fid,"tol_pcls=%g %% Tolerance on PCLS relative coef. update\n",tol_pcls);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"fap=%g %% Pass band amplitude response edge\n",fap);
fprintf(fid,"dBap=%d %% Pass band amplitude peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Pass band weight\n",Wap);
fprintf(fid,"ftp=%g %% Pass band group delay response edge\n",ftp);
fprintf(fid,"tp=%d %% Nominal filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Pass band group delay weight\n",Wtp);
fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
fprintf(fid,"dBas=%d %% Stop band minimum attenuation\n",dBas);
fprintf(fid,"Was=%d %% Stop band amplitude weight\n",Was);
fclose(fid);

print_pole_zero(xi,U,V,M,Q,R,"xi",strcat(strf,"_xi_coef.m"));
print_pole_zero(d1,U,V,M,Q,R,"d1",strcat(strf,"_d1_coef.m"));
print_polynomial(N1,"N1",strcat(strf,"_N1_coef.m"));
print_polynomial(D1,"D1",strcat(strf,"_D1_coef.m"));
print_polynomial(b,"b",strcat(strf,"_b_coef.m"));
print_polynomial(baa,"baa",strcat(strf,"_baa_coef.m"));
print_polynomial(beq,"beq",strcat(strf,"_beq_coef.m"));
print_polynomial(bb,"bb",strcat(strf,"_bb_coef.m"));
print_polynomial(bbb,"bbb",strcat(strf,"_bbb_coef.m"));

fid=fopen(strcat(strf,"_actual_passband.tab"),"wt");
fprintf(fid,"$%g$",fap_actual);
fclose(fid);
fid=fopen(strcat(strf,"_actual_stopband.tab"),"wt");
fprintf(fid,"$%g$",fas_actual);
fclose(fid);
fid=fopen(strcat(strf,"_distinct_multipliers.tab"),"wt");
fprintf(fid,"$%d$",N1D1_mult);
fclose(fid);
fid=fopen(strcat(strf,"_nominal_delay.tab"),"wt");
fprintf(fid,"$%g$",tpP);
fclose(fid);
fid=fopen(strcat(strf,"_b_scale.tab"),"wt");
fprintf(fid,"$%g$",b_scale);
fclose(fid);
fid=fopen(strcat(strf,"_bbeq_distinct_multipliers.tab"),"wt");
fprintf(fid,"$%d$",bbeq_mult);
fclose(fid);
fid=fopen(strcat(strf,"_bbeq_delay.tab"),"wt");
fprintf(fid,"$%g$",tdeq);
fclose(fid);
fid=fopen(strcat(strf,"_fir_distinct_multipliers.tab"),"wt");
fprintf(fid,"$%d$",(Nbb/2)+1);
fclose(fid);
fid=fopen(strcat(strf,"_fir_delay.tab"),"wt");
fprintf(fid,"$%g$",(Nbbb/2));
fclose(fid);

save decimator_R2_interpolated_test.mat n U V M Q R P fap fas ftp tp ...
     dBap dBas tpr Wap Was Wtp tol_wise tol_wise tol_mmse tol_pcls ctol ...
     x0 x1 d1 N1 D1 N1P D1P b b_scale baa beq bb bbb

% Done
toc;
diary off
movefile decimator_R2_interpolated_test.diary.tmp ...
         decimator_R2_interpolated_test.diary;
